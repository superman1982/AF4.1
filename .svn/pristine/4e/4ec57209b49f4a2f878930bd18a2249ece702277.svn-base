# coding: utf8
=begin rdoc
作用: 日志查询页面上的操作
维护记录:
维护人      时间                  行为
gsj      2011-12-08             创建
=end
require 'keywords/keyword/device_data_center'

module DeviceDataCenter


=begin rdoc
类名: 日志查询
描述: 日志查询
=end
  class LogQuery < ATT::Base

=begin rdoc
关键字名: 应用控制日志查询
描述: 应用控制日志查询
参数:
id=>startdate,name=>起始日期,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的起始日期,格式如'2011-12-07',默认是设备的昨天"
id=>starttime,name=>起始时间,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的起始时间,格式如'12:30',默认是0点0分"
id=>enddate,name=>结束日期,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的结束日期,格式如'2011-12-07',默认是设备的昨天"
id=>endtime,name=>结束时间,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"查询条件中的结束时间,格式如'12:30',默认是23点59分"
id=>source_zone,name=>源区域,type=>s,must=>false,default=>"所有区域",value=>"{text}",descrip=>"源区域,只能选择一个"
id=>source_type,name=>源用户类型,type=>s,must=>false,default=>"所有",value=>"所有|IP|用户|组",descrip=>"源用户类型"
id=>source_ip,name=>源IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源用户类型选择IP时,输入的IP地址,可以是单个IP,IP范围,网段,多个时使用&分割"
id=>source_user,name=>源用户,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源用户类型选择用户时,输入的某个用户"
id=>source_usergrp,name=>源组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源用户类型选择用户组时,选择的用户组的全路径,如/test/"
id=>sub_grp,name=>包含子组,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"源用户类型选择用户组时,是否勾选包含子组"
id=>dest_zone,name=>目的区域,type=>s,must=>false,default=>"所有区域",value=>"{text}",descrip=>"目的区域,只能选择一个"
id=>dest_ip,name=>目的IP,type=>s,must=>false,default=>"所有",value=>"{text}",descrip=>"目的IP,可以是单个IP,IP范围,网段,多个时使用&分割"
id=>service_app,name=>服务应用,type=>s,must=>false,default=>"全部",value=>"全部|服务|应用",descrip=>"服务/应用,选择服务还是应用,还是全部"
id=>services,name=>预定义服务类型,type=>s,must=>false,default=>"所有",value=>"{text}",descrip=>"服务/应用选择服务时,预定义服务选择所有还是自定义服务"
id=>protocol,name=>协议,type=>s,must=>false,default=>"ICMP",value=>"ICMP|TCP|UDP",descrip=>"服务/应用选择服务,预定义服务选择自定义服务时,选择的协议"
id=>port,name=>端口号,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"服务/应用选择服务,预定义服务选择自定义服务时,输入的端口号,多个时使用&分割"
id=>apps,name=>应用,type=>s,must=>false,default=>"所有应用",value=>"{text}",descrip=>"服务/应用选择应用时,选择的应用的全路径,格式如'网上银行/北京银行'"
id=>accept,name=>允许,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"动作是否勾选允许"
id=>refuse,name=>拒绝,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"动作是否勾选拒绝"
id=>record_hoped,name=>期望记录,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的记录,格式'服务/应用#协议#源区域#所属组#源IP/用户#目的区域#匹配策略名#动作',多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def application_control_log_query(hash)
      begin
        DeviceDataCenter::menu_open("应用控制")
        start_date, start_time, end_date, end_time = get_date_and_time(hash[:startdate], hash[:starttime], hash[:enddate], hash[:endtime])
        input_start_date_time(start_date, start_time[0,5])
        input_end_date_time(end_date, end_time[0,5])
        select_source_zone(hash[:source_zone])
        input_source_ip_or_user(hash[:source_type], hash[:source_ip], hash[:source_user], hash[:source_usergrp], hash[:sub_grp])
        select_dest_zone(hash[:dest_zone])
        input_dest_ip(hash[:dest_ip])
        select_service_or_app(hash[:service_app], hash[:services], hash[:protocol], hash[:port], hash[:apps]) # 选择服务或应用
        select_accept_and_reject(hash[:accept], hash[:refuse])
        click_query_button()

        check_query_result(hash[:record_hoped])
      rescue Watir::Exception::WatirException # 浏览器上有时会有脚本错误,导致点击链接无反应
        ATT::KeyLog.error("发生异常:#{$!.class},#{$!.message}")
        $dc_browser.refresh
        $dc_browser.wait
        retry
      end
    end


  end
end
