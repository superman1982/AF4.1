# coding: utf8
=begin rdoc
作用: 设备后台数据库操作
维护记录:
维护人      时间                  行为
gsj     2012-05-18              创建
=end
require 'lib/data_base'
require 'zlib'

module DeviceBack


=begin rdoc
类名: 数据库操作
描述: 封装设备后台查询内置数据中心日志的操作
=end
  class DataBaseOperation < ATT::Base

=begin rdoc
关键字名: 查询IPS日志
描述: 查询内置数据中心内IPS日志
维护人: gsj
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>startdate,name=>起始日期,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的起始日期,格式如'2011-12-07'"
id=>starttime,name=>起始时间,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的起始时间,格式如'12:30:00'"
id=>enddate,name=>结束日期,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的结束日期,格式如'2011-12-07'"
id=>endtime,name=>结束时间,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的结束时间,格式如'12:30:00'"
id=>log_exist,name=>期望有无日志,type=>s,must=>false,default=>"有",value=>"有|无",descrip=>"起始时间和结束时间内,期望有无日志"
id=>records_hoped,name=>期望记录,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望有日志时,每条期望记录的格式如'类型#协议#源区域#源IP#源端口#目的区域#目的IP#目的端口#漏洞ID#漏洞名称#匹配策略名#严重等级#动作',若某个字段忽略不检查,使用'-',如'web#TCP#-#2.2.2.2#-#-#3.3.3.3#-#-#-#-#-#-',将仅检查类型是web,协议是TCP,源IP是2.2.2.2,目的IP是3.3.3.3的记录是否存在.多条记录间用'&'分隔"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>"期望结果"
=end
    def query_ips_log(hash)
      sleep 10 # 等待数据写入数据库
      date_time_slot_map = get_date_and_time_slot_to_query(hash[:startdate],hash[:starttime],hash[:enddate],hash[:endtime]) # 返回hash类型,{date1 => [start_time,end_time],date2 => [start_time,end_time]}
      sql_array = []
      date_time_slot_map.each do |date, time_slot|
        temp_sql = "select attack_type, protocol, src_zone, src_ip, src_port, dst_zone, dst_ip, dst_port, hole_id, policy_id, level, net_action from I#{date} where record_time > '#{time_slot[0]}' and record_time < '#{time_slot[1]}'"
        sql_array << temp_sql
      end
      begin
        records_queried = AF::DataBase.exec_sql(sql_array.join(" union "), hash[:devicename])
      rescue Exception
        ATT::KeyLog.error("查询出错:#{$!.class}/#{$!.message}")
        return_fail
      end
      record_count_queried = records_queried.num_rows # 查询出的记录条数
      ATT::KeyLog.debug("查询结果中包含: #{record_count_queried}条记录")
      if record_count_queried == 0 && hash[:log_exist] == "无"
        return_ok
      elsif record_count_queried != 0 && hash[:log_exist] == "有"
        return_ok if hash[:records_hoped].empty? # 期望有日志,但不检查期望记录的内容
        records_hoped_in_db = convert_ips_data_hoped_into_in_db(hash[:records_hoped], hash[:devicename]) # 将期望的数据转换成对应的保存在数据库中的数据
        check_ips_records_hoped_exist(records_hoped_in_db, records_queried, hash[:devicename]) # 检查期望的记录是否在查询结果中
      else
        ATT::KeyLog.error("期望#{hash[:log_exist]}日志,实际查询结果包含:#{record_count_queried}条记录")
        return_fail
      end
    end

=begin rdoc
关键字名: 查询DOS攻击日志
描述: 查询内置数据中心内DOS攻击日志
维护人: gsj
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>startdate,name=>起始日期,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的起始日期,格式如'2011-12-07'"
id=>starttime,name=>起始时间,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的起始时间,格式如'12:30:00'"
id=>enddate,name=>结束日期,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的结束日期,格式如'2011-12-07'"
id=>endtime,name=>结束时间,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的结束时间,格式如'12:30:00'"
id=>log_exist,name=>期望有无日志,type=>s,must=>false,default=>"有",value=>"有|无",descrip=>"起始时间和结束时间内,期望有无日志"
id=>records_hoped,name=>期望记录,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望有日志时,每条期望记录的格式如'攻击类型#源区域#源IP#目的IP#匹配策略名#描述#严重等级#动作',若某个字段忽略不检查,使用'-',如'内网DOS攻击#-#2.2.2.2#3.3.3.3#-#每源IP，200包/秒#-#-',将仅检查内网DOS攻击,源IP是2.2.2.2,目的IP是3.3.3.3,描述是'每源IP，200包/秒'的记录是否存在.多条记录间用'&'分隔"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>"期望结果"
=end
    def query_dos_defence_log( hash )
      sleep 10 # 等待数据写入数据库
      date_time_slot_map = get_date_and_time_slot_to_query(hash[:startdate],hash[:starttime],hash[:enddate],hash[:endtime]) # 返回hash类型,{date1 => [start_time,end_time],date2 => [start_time,end_time]}
      sql_array = []
      date_time_slot_map.each do |date, time_slot|
        temp_sql = "select attack_type, src_zone, src_ip, dst_ip, policy_id, stat_obj, rate, level, net_action from D#{date} where record_time > '#{time_slot[0]}' and record_time < '#{time_slot[1]}'"
        sql_array << temp_sql
      end
      begin
        records_queried = AF::DataBase.exec_sql(sql_array.join(" union "), hash[:devicename])
      rescue Exception
        ATT::KeyLog.error("查询出错:#{$!.class}/#{$!.message}")
        return_fail
      end
      record_count_queried = records_queried.num_rows # 查询出的记录条数
      ATT::KeyLog.debug("查询结果中包含: #{record_count_queried}条记录")
      if record_count_queried == 0 && hash[:log_exist] == "无"
        return_ok
      elsif record_count_queried != 0 && hash[:log_exist] == "有"
        return_ok if hash[:records_hoped].empty? # 期望有日志,但不检查期望记录的内容
        records_hoped_in_db = convert_dos_data_hoped_into_in_db(hash[:records_hoped], hash[:devicename]) # 将期望的数据转换成对应的保存在数据库中的数据
        check_dos_records_hoped_exist(records_hoped_in_db, records_queried, hash[:devicename]) # 检查期望的记录是否在查询结果中
      else
        ATT::KeyLog.error("期望#{hash[:log_exist]}日志,实际查询结果包含:#{record_count_queried}条记录")
        return_fail
      end
    end
    
=begin rdoc
关键字名: 查询WEB应用防护日志
描述: 查询内置数据中心内 WEB应用防护日志
维护人: 王沃伦
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>startdate,name=>起始日期,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的起始日期,格式如'2011-12-07'"
id=>starttime,name=>起始时间,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的起始时间,格式如'12:30:00'"
id=>enddate,name=>结束日期,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的结束日期,格式如'2011-12-07'"
id=>endtime,name=>结束时间,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的结束时间,格式如'12:30:00'"
id=>log_exist,name=>期望有无日志,type=>s,must=>false,default=>"有",value=>"有|无",descrip=>"起始时间和结束时间内,期望有无日志"
id=>records_hoped,name=>期望记录,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望有日志时,每条期望记录的格式如'攻击类型#源区域#源IP#目的IP#匹配策略名#严重等级#动作',若某个字段忽略不检查,使用'-',如'敏感信息防护#-#2.2.2.2#3.3.3.3#-#-#-',将仅检查敏感信息防护,源IP是2.2.2.2,目的IP是3.3.3.3的记录是否存在.多条记录间用'&'分隔"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>"期望结果"
=end
    def query_waf_defence_log( hash )
      sleep 10 # 等待数据写入数据库
      date_time_slot_map = get_date_and_time_slot_to_query(hash[:startdate],hash[:starttime],hash[:enddate],hash[:endtime]) # 返回hash类型,{date1 => [start_time,end_time],date2 => [start_time,end_time]}
      sql_array = []
      date_time_slot_map.each do |date, time_slot|
        temp_sql = "select attack_type, src_zone, src_ip, dst_ip, policy_id, level, net_action from X#{date} where record_time > '#{time_slot[0]}' and record_time < '#{time_slot[1]}'"
        sql_array << temp_sql
      end
      begin
        records_queried = AF::DataBase.exec_sql(sql_array.join(" union "), hash[:devicename])
      rescue Exception
        ATT::KeyLog.error("查询出错:#{$!.class}/#{$!.message}")
        return_fail
      end
      record_count_queried = records_queried.num_rows # 查询出的记录条数
      ATT::KeyLog.debug("查询结果中包含: #{record_count_queried}条记录")
      if record_count_queried == 0 && hash[:log_exist] == "无"
        return_ok
      elsif record_count_queried != 0 && hash[:log_exist] == "有"
        return_ok if hash[:records_hoped].empty? # 期望有日志,但不检查期望记录的内容
        records_hoped_in_db = convert_waf_data_hoped_into_in_db(hash[:records_hoped], hash[:devicename]) # 将期望的数据转换成对应的保存在数据库中的数据
        check_waf_records_hoped_exist(records_hoped_in_db, records_queried) # 检查期望的记录是否在查询结果中
      else
        ATT::KeyLog.error("期望#{hash[:log_exist]}日志,实际查询结果包含:#{record_count_queried}条记录")
        return_fail
      end
    end
    
  end
end
