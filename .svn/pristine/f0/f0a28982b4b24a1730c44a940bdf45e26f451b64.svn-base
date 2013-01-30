# coding: utf8
module DeviceBack
  module DataBaseOperationHelper

    # 获取要查询的日期和对应的时间段
    def get_date_and_time_slot_to_query(startdate, startt, enddate, endt)
      starttime = "#{startdate} #{startt}" # starttime和endtime的格式如'2012-05-12 12:30:00'
      endtime = "#{enddate} #{endt}"
      date_and_time_slot_map = {}
      start_time = starttime.to_time
      end_time = endtime.to_time
      zero_clock_of_start = start_time - (start_time.hour * 3600 + start_time.min * 60 + start_time.sec) # 起始日期的零点
      zero_clock_of_end = end_time - (end_time.hour * 3600 + end_time.min * 60 + end_time.sec)   # 结束日期的零点
      days_interval = ((zero_clock_of_end - zero_clock_of_start)/(24*3600)).to_i # 起始日期和结束日期间隔的天数
      ATT::KeyLog.debug("days_interval = #{days_interval}")
      if days_interval == 0 # 起始日期和结束日期是同一天
        date = start_time.strftime("%Y%m%d")
        start_clock = start_time.strftime("%H:%M:%S")
        end_clock = end_time.strftime("%H:%M:%S")
        date_and_time_slot_map[date] = [ start_clock, end_clock ]
      else # # 起始日期和结束日期跨天了
        start_date = start_time.strftime("%Y%m%d")
        start_clock = start_time.strftime("%H:%M:%S")
        end_date = end_time.strftime("%Y%m%d")
        end_clock = end_time.strftime("%H:%M:%S")

        date_and_time_slot_map[start_date] = [ start_clock, "23:59:59" ] # 起始日期
        date_and_time_slot_map[end_date] = [ "00:00:00", end_clock ] # 结束日期
        if days_interval > 1
          for index in 1..days_interval-1
            zero_clock_of_temp_date = zero_clock_of_start + index * 24 * 3600
            temp_date = zero_clock_of_temp_date.strftime("%Y%m%d")
            date_and_time_slot_map[temp_date] = [ "00:00:00", "23:59:59" ] # 中间日期
          end
        end
      end
      date_and_time_slot_map.each do |date, time_slot|
        ATT::KeyLog.debug("#{date} => [#{time_slot[0]}, #{time_slot[1]}]")
      end
    end
    
    # 将期望的数据转换成对应的保存在数据库中的数据
    # 每条期望记录的格式如 '类型#协议#源区域#源IP#源端口#目的区域#目的IP#目的端口#漏洞ID#漏洞名称#匹配策略名#严重等级#动作'
    # 若某个字段忽略不检查,使用'-'表示,如 'web#TCP#-#2.2.2.2#-#-#3.3.3.3#-#-#-#-#-#-'
    # 将仅检查类型是web,协议是TCP,源IP是2.2.2.2,目的IP是3.3.3.3的记录是否存在
    # sql查询出的字段: attack_type, protocol, src_zone, src_ip, src_port, dst_zone, dst_ip, dst_port, hole_id, policy_id, level, net_action
    def convert_ips_data_hoped_into_in_db( records_hoped, device_name )
      records_hoped_in_db = [] # 二维数组
      temp_record_array = records_hoped.split(RECORD_DEMILTER) # 若干条期望记录,以'&'分隔
      temp_record_array.each do |record_hoped|
        attr_array = record_hoped.split(ATTRIBUTE_DELIMITER) # 期望记录中,每个字段以#分隔
        unless attr_array.size == ATTR_COUNT_OF_IPS_LOG_HOPED # 期望记录中的某个记录不是ATTR_COUNT_OF_IPS_LOG_HOPED个字段
          ATT::KeyLog.error("期望记录格式错误,应含#{ATTR_COUNT_OF_IPS_LOG_HOPED}个字段,实际含#{attr_array.size}个字段")
          return_fail
        end
        attack_name, protocol, src_zone_crc, src_ip, src_port,dst_zone_crc = attr_array[0..5] # 赋初值
        dst_ip, dst_port, hole_id, hole_name, policy_name_crc, serious_level_num, action_num = attr_array[6..ATTR_COUNT_OF_IPS_LOG_HOPED-1]# 赋初值
        attack_name = attr_array[0].to_hole_type_id unless attr_array[0] == IGNORE_ATTR_REPLACEMENT # 将漏洞类型名称转换成漏洞类型id
        protocol = protocol_text_to_number(attr_array[1]) unless attr_array[1] == IGNORE_ATTR_REPLACEMENT # 将协议文本转换成协议号
        src_zone_crc = Zlib.crc32(attr_array[2]) unless attr_array[2] == IGNORE_ATTR_REPLACEMENT # 源区域名称转换成crc
        src_ip = attr_array[3].to_dec unless attr_array[3] == IGNORE_ATTR_REPLACEMENT # 源IP转换成crc
        dst_zone_crc = Zlib.crc32(attr_array[5]) unless attr_array[5] == IGNORE_ATTR_REPLACEMENT # 源区域名称转换成crc
        dst_ip = attr_array[6].to_dec unless attr_array[6] == IGNORE_ATTR_REPLACEMENT # 目的IP转换成crc
        hole_name = hole_id_to_name(attr_array[8], device_name) unless attr_array[9] == IGNORE_ATTR_REPLACEMENT # 漏洞ID转换成漏洞名称
        policy_name_crc = Zlib.crc32(attr_array[10]) unless attr_array[10] == IGNORE_ATTR_REPLACEMENT # 策略名转换成crc
        serious_level_num = attr_array[11].to_level_num unless attr_array[11] == IGNORE_ATTR_REPLACEMENT # 严重等级转换成对应的数字
        action_num = attr_array[12].to_action_num unless attr_array[12] == IGNORE_ATTR_REPLACEMENT # 动作转换成对应的数字
        result_array = [attack_name, protocol, src_zone_crc, src_ip, src_port,dst_zone_crc, dst_ip, dst_port, hole_id, hole_name, policy_name_crc, serious_level_num, action_num ]
        ATT::KeyLog.debug("#{record_hoped} => #{result_array.join(ATTRIBUTE_DELIMITER)}")
        records_hoped_in_db << result_array
      end
      return records_hoped_in_db
    end
    
    # 将协议文本转换成协议号
    def protocol_text_to_number( protocol_text )
      protocol_map = {"ICMP" => 1, "TCP" => 6, "UDP" => 17}
      if protocol_map.has_key?("#{protocol_text}")
        return protocol_map["#{protocol_text}"]
      else
        ATT::KeyLog.error("未知的协议:#{protocol_text}")
        return_fail
      end
    end
    # 漏洞ID转换成漏洞名称
    def hole_id_to_name( hole_id, device_name )
      if $hole_id_and_name.nil?
        $hole_id_and_name = {}
        ips_holes = AF::DataBase.exec_sql("select * from CfgIPSHoleInfo", device_name)
        ips_holes.each do |row|
          $hole_id_and_name[row[1]] = row[3] # 键是IPS漏洞ID,值是IPS漏洞名称
        end
        #$hole_id_and_name.each do |id, name|
        #  ATT::KeyLog.debug("#{id} => #{name}")
        #end
      end
      hole_name = $hole_id_and_name[hole_id]
      if hole_name.nil?
        ATT::KeyLog.error("不存在漏洞ID:#{hole_id}")
        return "-"
      else
        ATT::KeyLog.debug("漏洞类型ID:#{hole_id},对应的漏洞名称是:#{hole_name}")
        return hole_name
      end
    end

    # 检查期望的记录是否在查询结果中
    # records_hoped_in_db是二维数组类型,其中的第一维数组含13个字段, records_queried是Mysql::RecordSet类型,其中的第一维数组含12个字段
    def check_ips_records_hoped_exist(records_hoped_in_db, records_queried, device_name)
      # 先将类型是Mysql::RecordSet的查询结果转换成二维数组
      temp_record_array_queried = []
      records_queried.each do |row|
        temp_row_str = row.join(ATTRIBUTE_DELIMITER)
        temp_row_array = temp_row_str.split(ATTRIBUTE_DELIMITER)
        temp_row_array.insert(9, hole_id_to_name( temp_row_array[8], device_name )) # 在查询结果中插入漏洞名称字段
        temp_record_array_queried << temp_row_array
      end
      # 至此, records_hoped_in_db 与 temp_record_array_queried, 都是二维数组,且第一维数组都含13个字段
      compare_records_hoped_and_queried(records_hoped_in_db, temp_record_array_queried )
    end
    # 将期望的数据转换成对应的保存在数据库中的数据
    # 每条期望记录的格式如 '攻击类型#源区域#源IP#目的IP#匹配策略名#描述#严重等级#动作'
    # 若某个字段忽略不检查,使用'-'表示,如 '内网DOS攻击#-#2.2.2.2#3.3.3.3#-#每源IP，200包/秒#-#-'
    # 将仅检查内网DOS攻击,源IP是2.2.2.2,目的IP是3.3.3.3,描述是'每源IP，200包/秒'的记录是否存在
    # sql查询出的字段: attack_type, src_zone, src_ip, dst_ip, policy_id, stat_obj, rate, level, net_action
    def convert_dos_data_hoped_into_in_db( records_hoped, device_name )
      records_hoped_in_db = [] # 二维数组
      temp_record_array = records_hoped.split(RECORD_DEMILTER) # 若干条期望记录,以'&'分隔
      temp_record_array.each do |record_hoped|
        attr_array = record_hoped.split(ATTRIBUTE_DELIMITER) # 期望记录中,每个字段以#分隔
        unless attr_array.size == ATTR_COUNT_OF_DOS_LOG_HOPED # 期望记录中的某个记录不是ATTR_COUNT_OF_DOS_LOG_HOPED个字段
          ATT::KeyLog.error("期望记录格式错误,应含#{ATTR_COUNT_OF_DOS_LOG_HOPED}个字段,实际含#{attr_array.size}个字段")
          return_fail
        end
        dos_attack_id, src_zone_crc, src_ip, dst_ip, policy_name_crc, description, serious_level_num, action_num = attr_array[0..ATTR_COUNT_OF_DOS_LOG_HOPED-1] # 赋初值
        
        dos_attack_id = dos_attack_name_to_id(dos_attack_id, device_name) unless dos_attack_id == IGNORE_ATTR_REPLACEMENT # 将DOS攻击类型名称转换成id
        src_zone_crc = Zlib.crc32(src_zone_crc) unless src_zone_crc == IGNORE_ATTR_REPLACEMENT # 源区域名称转换成crc
        src_ip = src_ip.to_dec unless src_ip == IGNORE_ATTR_REPLACEMENT # 源IP转换成crc
        dst_ip = dst_ip.to_dec unless dst_ip == IGNORE_ATTR_REPLACEMENT # 目的IP转换成crc
        policy_name_crc = Zlib.crc32(policy_name_crc) unless policy_name_crc == IGNORE_ATTR_REPLACEMENT # 策略名转换成crc
        stat_obj_id = rate = "-" # 统计对象和速率,赋初值
        unless description == IGNORE_ATTR_REPLACEMENT
          stat_obj_text,rate_text = description.split("，")
          stat_obj_text,rate_text = description.split(",") if rate_text.nil?
          stat_obj_id = stat_obj_text_to_id(stat_obj_text) # '每源IP'
          rate = rate_text.strip.to_i # 取'200包/秒'中的200
        end
        serious_level_num = serious_level_num.to_level_num unless serious_level_num == IGNORE_ATTR_REPLACEMENT # 严重等级转换成对应的数字
        action_num = action_num.to_action_num unless action_num == IGNORE_ATTR_REPLACEMENT # 动作转换成对应的数字
        result_array = [dos_attack_id, src_zone_crc, src_ip, dst_ip, policy_name_crc, stat_obj_id, rate, serious_level_num, action_num ]
        ATT::KeyLog.debug("#{record_hoped} => #{result_array.join(ATTRIBUTE_DELIMITER)}")
        records_hoped_in_db << result_array
      end
      return records_hoped_in_db
    end

    # 将期望的数据转换成对应的保存在数据库中的数据
    # 每条期望记录的格式如 '攻击类型#源区域#源IP#目的IP#匹配策略名#严重等级#动作'
    # 若某个字段忽略不检查,使用'-'表示,如 '敏感信息防护#-#2.2.2.2#3.3.3.3#-#-#-'
    # 将仅检查内网DOS攻击,源IP是2.2.2.2,目的IP是3.3.3.3,的记录是否存在
    # sql查询出的字段: attack_type, src_zone, src_ip, dst_ip, policy_id, level, net_action
    # => 王沃伦添加
    def convert_waf_data_hoped_into_in_db( records_hoped, device_name )
      records_hoped_in_db = [] # 二维数组
      temp_record_array = records_hoped.split(RECORD_DEMILTER) # 若干条期望记录,以'&'分隔
      temp_record_array.each do |record_hoped|
        attr_array = record_hoped.split(ATTRIBUTE_DELIMITER) # 期望记录中,每个字段以#分隔
        unless attr_array.size == ATTR_COUNT_OF_WAF_LOG_HOPED # 期望记录中的某个记录不是ATTR_COUNT_OF_DOS_LOG_HOPED个字段
          ATT::KeyLog.error("期望记录格式错误,应含#{ATTR_COUNT_OF_WAF_LOG_HOPED}个字段,实际含#{attr_array.size}个字段")
          return_fail
        end
        dos_attack_id, src_zone_crc, src_ip, dst_ip, policy_name_crc, serious_level_num, action_num = attr_array[0..ATTR_COUNT_OF_WAF_LOG_HOPED-1] # 赋初值
        
        dos_attack_id = waf_attack_name_to_id(dos_attack_id) unless dos_attack_id == IGNORE_ATTR_REPLACEMENT # 将DOS攻击类型名称转换成id
        src_zone_crc = Zlib.crc32(src_zone_crc) unless src_zone_crc == IGNORE_ATTR_REPLACEMENT # 源区域名称转换成crc
        src_ip = src_ip.to_dec unless src_ip == IGNORE_ATTR_REPLACEMENT # 源IP转换成crc
        dst_ip = dst_ip.to_dec unless dst_ip == IGNORE_ATTR_REPLACEMENT # 目的IP转换成crc
        policy_name_crc = Zlib.crc32(policy_name_crc) unless policy_name_crc == IGNORE_ATTR_REPLACEMENT # 策略名转换成crc
        serious_level_num = serious_level_num.to_level_num unless serious_level_num == IGNORE_ATTR_REPLACEMENT # 严重等级转换成对应的数字
        action_num = action_num.to_action_num unless action_num == IGNORE_ATTR_REPLACEMENT # 动作转换成对应的数字
        result_array = [dos_attack_id, src_zone_crc, src_ip, dst_ip, policy_name_crc, serious_level_num, action_num ]
        ATT::KeyLog.debug("完成构造查询数据转换数据库数据 : #{record_hoped} => #{result_array.join(ATTRIBUTE_DELIMITER)}")
        records_hoped_in_db << result_array
      end
      return records_hoped_in_db
    end
    
    # 将DOS攻击类型名称转换成id
    def dos_attack_name_to_id(dos_attack_name, device_name)
      dos_attack_name_and_id_map = 
        {"IP地址扫描" => 1, "端口扫描" => 2, "ICMP洪水攻击" => 3, "UDP洪水攻击" => 4, "SYN洪水攻击" => 5, "DNS洪水攻击" => 6,
        "ARP洪水攻击" => 7, "未知协议类型" => 8, "TearDrop攻击" => 9, "IP数据块分片传输" => 10, "LAND攻击防护" => 11, "WinNuke攻击" => 12,
        "Smurf攻击" => 13, "超大ICMP数据" => 14, "错误的IP报文选项" => 15, "IP时间戳选项报文" => 16,
        "IP安全选项报文" => 17, "IP数据流选项报文" => 18, "IP记录路由选项报文" => 19, "IP宽松源路由选项报文" => 20, "IP严格源路由选项报文" => 21,
        "SYN数据分片传输" => 22, "TCP报头标志位全为0" => 23, "SYN和FIN标志位同时为1" => 24, "仅FIN标志位为1" => 25,
        "黑名单中的IP报文" => 26, "内网DOS攻击" => 27}

      if dos_attack_name_and_id_map.has_key?("#{dos_attack_name}")
        return dos_attack_name_and_id_map["#{dos_attack_name}"]
      else
        ATT::KeyLog.error("未知的DOS攻击:#{dos_attack_name}")
        return_fail
      end
    end
    # 统计对象文本转换成id
    def stat_obj_text_to_id(stat_obj_text)
      stat_obj_map = {"每源IP" => 1, "每目的IP" => 2, "所有接口" => 3, "" => 0}
      if stat_obj_map.has_key?("#{stat_obj_text}")
        return stat_obj_map["#{stat_obj_text}"]
      else
        ATT::KeyLog.error("未知的统计对象:#{stat_obj_text}")
        return 0
      end
    end
    # => 王沃伦添加
    # 将WAF攻击类型名称转换成id
    def waf_attack_name_to_id(dos_attack_name)
      if WAF_ATTACK_NAME_AND_ID_MAP.has_key?("#{dos_attack_name}")
        return WAF_ATTACK_NAME_AND_ID_MAP["#{dos_attack_name}"]
      else
        ATT::KeyLog.error("WAF输入的攻击类型未知~~ :#{dos_attack_name}")
        return_fail
      end
    end

    # 检查期望的记录是否在查询结果中
    # records_hoped_in_db是二维数组类型,其中的第一维数组含9个字段, records_queried是Mysql::RecordSet类型,其中的第一维数组含9个字段
    def check_dos_records_hoped_exist(records_hoped_in_db, records_queried, devicename)
      # 先将类型是Mysql::RecordSet的查询结果转换成二维数组
      temp_record_array_queried = []
      records_queried.each do |row|
        temp_row_str = row.join(ATTRIBUTE_DELIMITER)
        temp_row_array = temp_row_str.split(ATTRIBUTE_DELIMITER)
        temp_record_array_queried << temp_row_array
      end
      # 至此, records_hoped_in_db 与 temp_record_array_queried, 都是二维数组,且第一维数组都含9个字段
      compare_records_hoped_and_queried(records_hoped_in_db, temp_record_array_queried )
    end

    # 检查期望的记录是否在查询结果中
    # records_hoped_in_db是二维数组类型,其中的第一维数组含7个字段, records_queried是Mysql::RecordSet类型,其中的第一维数组含7个字段
    def check_waf_records_hoped_exist(records_hoped_in_db, records_queried )
      # 先将类型是Mysql::RecordSet的查询结果转换成二维数组
      temp_record_array_queried = []
      records_queried.each do |row|
        temp_row_str = row.join(ATTRIBUTE_DELIMITER)
        temp_row_array = temp_row_str.split(ATTRIBUTE_DELIMITER)
        temp_record_array_queried << temp_row_array
      end
      # 至此, records_hoped_in_db 与 temp_record_array_queried, 都是二维数组,且第一维数组都含7个字段
      compare_records_hoped_and_queried(records_hoped_in_db, temp_record_array_queried )
    end
    
    # 对比期望记录和查询出的记录, 两个参数都是二维数组, 且第一维数组包含的字段个数一致
    def compare_records_hoped_and_queried(records_hoped_in_db, temp_record_array_queried )
      records_hoped_in_db.each do |one_record_hoped| # 期望记录中,挨个记录检查
        part_attrs_record_array_queried = [] # 一维数组,在查询结果中,抽取若干个字段,抽取哪些字段由期望记录中非忽略检查的字段决定
        index_array = [] # 非忽略检查字段在所有查询字段中的索引
        one_record_hoped.each_index do |index|
          unless one_record_hoped[index] == IGNORE_ATTR_REPLACEMENT
            #ATT::KeyLog.debug("index = #{index}")
            index_array << index
          end
        end

        part_attrs_of_hoped = [] # 期望的一条记录中,抽取出的若干字段组成的一维数组
        index_array.each do |index|
          part_attrs_of_hoped << one_record_hoped[index]
        end
        part_attrs_of_hoped_text = part_attrs_of_hoped.join(ATTRIBUTE_DELIMITER) # 一维数组 => 字符串

        temp_record_array_queried.each do |row|
          part_attrs_of_queried = [] # 查询出的一条记录中,抽取出的若干字段组成的一维数组
          index_array.each do |index|
            #ATT::KeyLog.debug("row[#{index}] => #{row[index]}")
            part_attrs_of_queried << row[index]
          end
          #ATT::KeyLog.debug("#{part_attrs_of_queried.join(ATTRIBUTE_DELIMITER)}")
          part_attrs_record_array_queried << part_attrs_of_queried.join(ATTRIBUTE_DELIMITER) # 一维数组 => 字符串
        end

        unless part_attrs_record_array_queried.include?(part_attrs_of_hoped_text)
          ATT::KeyLog.error("查询结果中不包含期望记录,实际查询结果是:\n")
          part_attrs_record_array_queried.each do |temp_record|
            ATT::KeyLog.error(temp_record)
          end
          ATT::KeyLog.error("期望记录是:\n#{part_attrs_of_hoped_text}")
          return_fail
        end
      end
      return_ok
    end

  end
end
