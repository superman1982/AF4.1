# coding: utf8
=begin rdoc
作用: 封装接口区域模块的关键字
维护记录:
维护人      时间                  行为
gsj     2011-12-07              创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module NetConfig


=begin rdoc
类名: 接口区域
描述: 接口区域
=end
    class InterfaceZone < ATT::Base

=begin rdoc
关键字名: 编辑物理接口
描述: 修改物理接口的设置
参数:
id=>name,name=>接口名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要编辑接口的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用要编辑的接口"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>type,name=>接口类型,type=>s,must=>false,default=>"路由",value=>"路由|透明|虚拟网线|旁路镜像",descrip=>"接口的类型"
id=>area_name,name=>所属区域,type=>s,must=>false,default=>"请选择区域",value=>"{text}",descrip=>"接口所属区域"
id=>is_wan,name=>WAN口,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选WAN口"
id=>enable_ping,name=>允许PING,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"当类型选择路由时是否勾选允许PING"
id=>link_type,name=>连接类型,type=>s,must=>false,default=>"静态IP",value=>"静态IP|DHCP|ADSL拨号|Access|Trunk",descrip=>"接口的连接类型"
id=>static_ip,name=>静态IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当类型选择路由,连接类型选择静态IP时,要输入的静态IP,多个时用&分割"
id=>interface1,name=>接口1,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"虚拟网线接口1"
id=>interface2,name=>接口2,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"虚拟网线接口2"
id=>gateway,name=>下一跳网关,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当类型选择路由,连接类型选择静态IP时,要输入的下一跳网关"
id=>dhcp_add_default_route,name=>DHCP添加默认路由,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"当类型选择路由,连接类型选择DHCP时,是否勾选添加默认路由"
id=>adsl_account,name=>ADSL帐号,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当类型选择路由,连接类型选择ADSL拨号时,要输入的ADSL帐号"
id=>adsl_passwd,name=>ADSL密码,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当类型选择路由,连接类型选择ADSL拨号时,要输入的ADSL密码"
id=>adsl_shake_time,name=>拨号握手时间,type=>s,must=>false,default=>"20",value=>"{text}",descrip=>"当类型选择路由,连接类型选择ADSL拨号时,拨号参数中的握手时间"
id=>adsl_timeout,name=>拨号超时时间,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"当类型选择路由,连接类型选择ADSL拨号时,拨号参数中的超时时间"
id=>adsl_retry_times,name=>拨号重试次数,type=>s,must=>false,default=>"3",value=>"{text}",descrip=>"当类型选择路由,连接类型选择ADSL拨号时,拨号参数中的重试次数"
id=>adsl_auto,name=>自动拨号,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"当类型选择路由,连接类型选择ADSL拨号时,拨号参数中是否勾选自动拨号"
id=>adsl_add_default_route,name=>ADSL添加默认路由,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"当类型选择路由,连接类型选择ADSL拨号时,拨号参数中是否勾选添加默认路由"
id=>adsl_first_dns,name=>作为系统首选DNS,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"当类型选择路由,连接类型选择ADSL拨号时,拨号参数中是否作为系统首选DNS"
id=>up_bandwidth,name=>上行带宽,type=>s,must=>false,default=>"10MB/s",value=>"{text}",descrip=>"当类型选择路由时,线路带宽中的上行带宽,带有单位MB/s,KB/s,GB/s"
id=>down_bandwidth,name=>下行带宽,type=>s,must=>false,default=>"10MB/s",value=>"{text}",descrip=>"当类型选择路由时,线路带宽中的下行带宽,带有单位MB/s,KB/s,GB/s"
id=>enable_link_trouble_check,name=>启用链路故障检测,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"当类型选择路由时,是否启用链路故障检测"
id=>check_method,name=>故障检测方法,type=>s,must=>false,default=>"PING",value=>"PING|DNS解析",descrip=>"当类型选择路由且启用链路故障检测时,选择的链路故障检测方法"
id=>ping_ip,name=>PING目标IP,type=>s,must=>false,default=>"202.96.137.23",value=>"{text}",descrip=>"当类型选择路由,启用链路故障检测,选择PIND方法时,输入的目标IP地址"
id=>dns_server,name=>DNS服务器,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当类型选择路由,连接类型选择静态IP,启用链路故障检测,选择DNS解析方法时,输入的DNS服务器"
id=>dns_domain,name=>解析域名,type=>s,must=>false,default=>"www.sangfor.com",value=>"{text}",descrip=>"当类型选择路由,启用链路故障检测,选择DNS解析方法时,输入的域名地址"
id=>check_interval,name=>检测间隔,type=>s,must=>false,default=>"2",value=>"{text}",descrip=>"当类型选择路由,启用链路故障检测时输入的检测间隔,单位是秒"
id=>check_bad_threshold,name=>连续检测失败,type=>s,must=>false,default=>"3",value=>"{text}",descrip=>"当类型选择路由,启用链路故障检测时输入的连续检测失败,单位是次数"
id=>access_id,name=>Access,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"当类型选择透明,连接类型选择Access时,输入的Access ID"
id=>native_id,name=>Native,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"当类型选择透明,连接类型选择Trunk时,输入的native ID"
id=>vlan_scope,name=>VLAN范围,type=>s,must=>false,default=>"1-1000",value=>"{text}",descrip=>"当类型选择透明,连接类型选择Trunk时,输入的VLAN范围"

id=>work_mode,name=>工作模式,type=>s,must=>false,default=>"自动协商",value=>"自动协商|全双工10M|半双工10M|全双工100M|半双工100M|全双工1000M|半双工1000M|全双工10000M|半双工10000M",descrip=>"高级设置中的工作模式"
id=>mtu,name=>MTU,type=>s,must=>false,default=>"1500",value=>"{text}",descrip=>"高级设置中的MTU"
id=>mac,name=>MAC,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"高级设置中的MAC地址,不设置时使用原来的mac地址"

id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|不存在的接口类型|不存在的连接类型|不存在的带宽单位|不存在的链接检测方法|不存在的工作模式",descrip=>"期望结果"
=end
      def edit_physical_interface( hash )
        ATT::KeyLog.debug("editing physical interface......")
        post_hash = get_edit_physical_interface( hash )
        result_hash = AF::Login.get_session().post(InterfaceZoneCGI, post_hash)
        if result_hash["success"]
          clear_zone_by_default(hash)
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
        #tmp_hash = {"opr"=>"modify","data"=>{"name"=>"eth2","descript"=>"","eth_type"=>"route","area_name"=>"s","basic_params"=>["waneth"],"waneth"=>true,"allowping"=>false,"link_type"=>"dhcp","static_ip"=>false,"access"=>false,"dhcp"=>true,"trunk"=>false,"adsl_dial"=>false,"ipaddress"=>"","nextgateway"=>"","isGetGateway"=>true,"linkstatus"=>"<SPAN style=\"COLOR: red\">鏂?寮€</SPAN>","username"=>"1","userpwd"=>"***************","userpwd_temp"=>"5($*V@|#Pg|*$z)","dial_params"=>{"timeout"=>80,"addroute"=>false,"conntimes"=>3,"handshake"=>20,"autodial"=>true,"replacedns"=>false},"natives"=>"1","vlan"=>"1-1000","access_value"=>"1","line"=>{"up"=>81920,"down"=>81920},"linkcheck"=>{"set_check_method"=>{"linkcheck_win"=>{"enable"=>false,"linkcheck_method_inte"=>{"check_interval"=>2},"linkcheck_method_fs"=>{"ping"=>{"enable"=>true},"dns_parse"=>{}}}}},"advancesetup"=>{"advancesetup_win"=>{"workmode"=>1,"mss"=>"closed","mtu"=>1500,"mac"=>"00:50:56:B3:00:90","closed"=>true}},"enable"=>true}}
        #result_hash = AF::Login.get_session().post(InterfaceZoneCGI, tmp_hash)
        #post_and_judge_result(InterfaceZoneCGI, tmp_hash, "编辑物理接口")
      end

=begin rdoc
关键字名: 检查物理接口设置
描述: 在物理接口列表页面,检查某个物理接口当前的设置
参数:
id=>name,name=>接口名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要检查接口的名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的描述"
id=>is_wan,name=>WAN口,type=>s,must=>false,default=>"忽略",value=>"是|否|忽略",descrip=>"期望是否是WAN口,忽略表示不检查此参数"
id=>type,name=>接口类型,type=>s,must=>false,default=>"忽略",value=>"路由|透明|虚拟网线|忽略",descrip=>"期望的接口类型,忽略表示不检查此参数"
id=>link_type,name=>连接类型,type=>s,must=>false,default=>"忽略",value=>"静态IP|DHCP|ADSL拨号|忽略|无效",descrip=>"期望的接口连接类型,忽略表示不检查此参数,无效即---"
id=>address,name=>地址,type=>s,must=>false,default=>"",value=>"无效|{text}",descrip=>"期望的地址,如1.1.1.1/24或1.1.1.1/255.255.255.0,多个时使用&分割,无效即---"
id=>adsl_status,name=>拨号状态,type=>s,must=>false,default=>"忽略",value=>"断开|连接|忽略|无效",descrip=>"期望的拨号状态,忽略表示不检查此参数,无效即---"
id=>mtu,name=>MTU,type=>s,must=>false,default=>"1500",value=>"{text}",descrip=>"期望的MTU"
id=>work_mode,name=>工作模式,type=>s,must=>false,default=>"自动协商",value=>"忽略|自动协商|全双工10M|半双工10M|全双工100M|半双工100M|全双工1000M|半双工1000M|全双工10000M|半双工10000M",descrip=>"期望的工作模式"
id=>enable_ping,name=>PING,type=>s,must=>false,default=>"忽略",value=>"允许|拒绝|忽略|无效",descrip=>"期望是否允许PING,忽略表示不检查此参数,无效即---"
id=>interface_status,name=>网口状态,type=>s,must=>false,default=>"忽略",value=>"断开|正常|忽略",descrip=>"期望的网口状态"
id=>link_status,name=>链路状态,type=>s,must=>false,default=>"忽略",value=>"故障|正常|未检测|忽略|无效",descrip=>"期望的链路状态,忽略表示不检查此参数,无效即---"
id=>status,name=>状态,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"期望的接口状态"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|物理接口不存在|描述错误|WAN口错误|接口类型错误|连接类型错误|区域错误|IP地址错误|拨号状态错误|MTU错误|工作模式错误|PING错误|网口状态错误|链路状态错误|状态错误",descrip=>""
=end
      def check_physical_interface( hash )
        ATT::KeyLog.debug("检查物理接口#{hash[:name]}的设置")
        post_hash = {"opr" => "list"}
        result_hash = AF::Login.get_session().post(InterfaceZoneCGI, post_hash)
        if result_hash["success"]
          ATT::KeyLog.info("获取数据成功,现在开始检查...")
          check_interface_setting(result_hash["data"], hash )
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end
      
=begin rdoc
关键字名: 获取接口的默认MAC
描述: 获取某个物理接口的默认MAC地址
参数:
id=>name,name=>接口名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"接口的名称"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def get_original_mac_of_interface( hash )
        post_hash = {"opr" => "query", "name" => hash[:name], "type" => "get_defmac"}
        result_hash = AF::Login.get_session().post(InterfaceZoneCGI, post_hash)
        if result_hash["success"]
          mac_address = result_hash["mac"]
          ATT::KeyLog.info("默认MAC成功,默认MAC是#{mac_address}")
          return [ mac_address ]
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end
      
=begin rdoc
关键字名: 启禁物理接口
描述: 启用或禁用物理接口
参数:
id=>names,name=>接口名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要启用或禁用的接口的名称,多个时使用|分割"
id=>operation,name=>操作,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"启用还是禁用指定的物理接口"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_physical_interface( hash )
        eth_name_array = hash[:names].split("|") # 在ATM平台上,eth1&eth2&eth3会显示为乱码,所以改成以|分割
        operation = (hash[:operation] == "启用"? "enable" : "disable")
        post_hash = { "opr" => operation, "name" => eth_name_array }
        result_hash = AF::Login.get_session().post(InterfaceZoneCGI, post_hash)
        if result_hash["success"]
          ATT::KeyLog.info("#{hash[:operation]}#{hash[:names]}成功")
          sleep 5 # 稍等会儿再返回
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end
      
=begin rdoc
关键字名: 物理接口ADSL拨号
描述: 在连接类型是ADSL的物理接口上进行拨号,前提是物理接口的连接类型已经保存为ADSL拨号
参数:
id=>name,name=>接口名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要进行拨号的接口的名称"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|拨号连接失败",descrip=>""
=end
      def adsl_dial_on_physical_interface( hash )
        linkon_post_hash = {"opr" => "query", "type" => "linkon", "name" => hash[:name]}
        result_hash = AF::Login.get_session().post(AdslDialCGI, linkon_post_hash)
        if result_hash["success"]
          flag = dial_ten_times(hash[:name]) # 点击连接按钮后,尝试10次检测其连接状态
          return_fail("拨号连接失败") unless flag
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end
      
=begin rdoc
关键字名: 断开ADSL拨号
描述: 在连接类型是ADSL的物理接口上断开拨号连接,前提是物理接口已经拨号成功
参数:
id=>name,name=>接口名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要断开拨号的接口的名称"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def disconnect_adsl_dial_on_physical_interface( hash )
        linkoff_post_hash = {"opr" => "query", "type" => "linkoff", "name" => hash[:name]}
        result_hash = AF::Login.get_session().post(AdslDialCGI, linkoff_post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end
=begin rdoc
关键字名: 恢复默认MAC地址
描述: 在某个物理接口上恢复默认MAC地址,获取成功后返回该MAC地址
参数:
id=>name,name=>接口名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要恢复默认MAC地址的接口的名称"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def restore_default_mac_on_physical_interface( hash )
        post_hash = {"opr" => "query", "name" => hash[:name], "type" => "get_defmac"}
        result_hash = AF::Login.get_session().post(InterfaceZoneCGI, post_hash)
        if result_hash["success"]
          mac_address = result_hash["mac"]
          ATT::KeyLog.info("默认MAC成功,默认MAC是#{mac_address}")
          return [ mac_address ]
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end

=begin rdoc
关键字名: 新增子接口
描述: 在类型是路由接口的接口上新增子接口
参数:
id=>name,name=>物理接口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"物理接口的名称,此接口的类型必须是路由"
id=>vlan_id,name=>VLANID,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"VLAN ID"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>area_name,name=>所属区域,type=>s,must=>false,default=>"default",value=>"{text}",descrip=>"接口所属区域"
id=>enable_ping,name=>允许PING,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选允许PING"
id=>link_type,name=>连接类型,type=>s,must=>false,default=>"静态IP",value=>"静态IP|DHCP",descrip=>"子接口的连接类型"
id=>static_ip,name=>静态IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当连接类型选择静态IP时,要输入的静态IP"
id=>gateway,name=>下一跳网关,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当连接类型选择静态IP时,要输入的下一跳网关"
id=>get_default_gw,name=>获取默认网关,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"当连接类型选择DHCP时,是否勾选获取默认网关"
id=>enable_link_trouble_check,name=>启用链路故障检测,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用链路故障检测"
id=>check_method,name=>故障检测方法,type=>s,must=>false,default=>"PING",value=>"PING|DNS解析",descrip=>"启用链路故障检测时,选择的链路故障检测方法"
id=>dns_server,name=>DNS服务器,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"启用链路故障检测,选择DNS解析方法时,输入的DNS服务器"
id=>dns_domain,name=>解析域名,type=>s,must=>false,default=>"www.sangfor.com",value=>"{text}",descrip=>"启用链路故障检测,选择DNS解析方法时,输入的域名地址"
id=>ping_ip,name=>PING目标IP,type=>s,must=>false,default=>"202.96.137.23",value=>"{text}",descrip=>"启用链路故障检测,选择PIND方法时,输入的目标IP地址"
id=>check_interval,name=>检测间隔,type=>s,must=>false,default=>"2",value=>"{text}",descrip=>"启用链路故障检测时输入的检测间隔,单位是秒"
id=>mtu,name=>MTU,type=>s,must=>false,default=>"1500",value=>"{text}",descrip=>"高级设置中的MTU"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_sub_interface_on_physical_interface( hash )
        ATT::KeyLog.debug("add sub interface on physical interface......")
        post_hash = get_add_sub_interface_post_hash( hash )
        result_hash = AF::Login.get_session().post(SubPortCGI, post_hash)
        if result_hash["success"]
          clear_zone_by_default(hash)
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除子接口
描述: 删除指定的子接口
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的子接口,还是删除目前所有的子接口"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的子接口名称,多个时使用|分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_sub_interfaces( hash )
        ATT::KeyLog.debug("delete sub interfaces......")
        if hash[:delete_type] == "全部删除"
          all_sub_port_names = DeviceConsole::get_all_object_names(SubPortCGI, "子接口")# get_all_sub_interface_names() # 数组类型
        else
          all_sub_port_names = hash[:names].to_s.split("|") # 数组类型
        end
        post_hash = {"opr" => "delete", "name" => all_sub_port_names}
        result_hash = AF::Login.get_session().post(SubPortCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 检查子接口设置
描述: 在子接口列表页面,检查某个子接口设置当前的设置
参数:
id=>name,name=>子接口名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要检查子接口的名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的描述"
id=>zone,name=>区域,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望所属的区域"
id=>address,name=>地址,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的地址,如1.1.1.1/24或1.1.1.1/255.255.255.0"
id=>mtu,name=>MTU,type=>s,must=>false,default=>"1500",value=>"{text}",descrip=>"期望的MTU"
id=>enable_ping,name=>PING,type=>s,must=>false,default=>"忽略",value=>"允许|拒绝|忽略",descrip=>"期望是否允许PING,忽略表示不检查此参数"
id=>link_status,name=>链路状态,type=>s,must=>false,default=>"忽略",value=>"故障|正常|未检测|忽略",descrip=>"期望的链路状态,忽略表示不检查此参数"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|子接口不存在|描述错误|区域错误|IP地址错误|MTU错误|PING错误|链路状态错误",descrip=>""
=end
      def check_sub_interface( hash )
        ATT::KeyLog.debug("check sub interface info......")
        all_sub_port_names = DeviceConsole::get_all_object_names(SubPortCGI, "子接口") # get_all_sub_interface_names() # 数组类型
        return_fail("子接口不存在") unless all_sub_port_names.include?(hash[:name])
        
        all_sub_interfaces = DeviceConsole::list_all_objects(SubPortCGI, "子接口") # list_all_sub_interfaces # 所有子接口的详细信息
        all_sub_interfaces.each do |sub_interface_info_hash|
          if hash[:name] == sub_interface_info_hash["name"]
            check_sub_interface_info(sub_interface_info_hash, hash )
          end
        end
      end

=begin rdoc
关键字名: 新增VLAN接口
描述: 新增VLAN接口
参数:
id=>vlan_id,name=>VLANID,type=>i,must=>true,default=>"",value=>"{text}",descrip=>"VLAN ID,范围是1-4094"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>enable_ping,name=>允许PING,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选允许PING"
id=>link_type,name=>连接类型,type=>s,must=>false,default=>"静态IP",value=>"静态IP|DHCP",descrip=>"VLAN接口的连接类型"
id=>area_name,name=>所属区域,type=>s,must=>false,default=>"default",value=>"{text}",descrip=>"接口所属区域"
id=>static_ip,name=>静态IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当连接类型选择静态IP时,要输入的静态IP"
id=>gateway,name=>下一跳网关,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当连接类型选择静态IP时,要输入的下一跳网关"
id=>get_default_gw,name=>获取默认网关,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"当连接类型选择DHCP时,是否勾选获取默认网关"
id=>enable_link_trouble_check,name=>启用链路故障检测,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用链路故障检测"
id=>check_method,name=>故障检测方法,type=>s,must=>false,default=>"PING",value=>"PING|DNS解析",descrip=>"启用链路故障检测时,选择的链路故障检测方法"
id=>dns_server,name=>DNS服务器,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"启用链路故障检测,选择DNS解析方法时,输入的DNS服务器"
id=>dns_domain,name=>解析域名,type=>s,must=>false,default=>"www.sangfor.com",value=>"{text}",descrip=>"启用链路故障检测,选择DNS解析方法时,输入的域名地址"
id=>ping_ip,name=>PING目标IP,type=>s,must=>false,default=>"202.96.137.23",value=>"{text}",descrip=>"启用链路故障检测,选择PIND方法时,输入的目标IP地址"
id=>check_interval,name=>检测间隔,type=>s,must=>false,default=>"2",value=>"{text}",descrip=>"启用链路故障检测时输入的检测间隔,单位是秒"
id=>mtu,name=>MTU,type=>s,must=>false,default=>"1500",value=>"{text}",descrip=>"高级设置中的MTU"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_vlan_interface( hash )
        ATT::KeyLog.debug("add vlan interface......")
        post_hash = get_add_vlan_interface_post_hash( hash )
        result_hash = AF::Login.get_session().post(VlanCGI, post_hash)
        if result_hash["success"]
          # => 添加进默认区域然后要清空出来才不影响后面的操作
          clear_zone_by_default(hash)
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      
=begin rdoc
关键字名: 删除VLAN接口
描述: 删除指定的VLAN接口
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的VLAN接口,还是删除目前所有的VLAN接口"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的VLAN接口名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_vlan_interfaces( hash )
        ATT::KeyLog.debug("delete vlan interfaces......")
        if hash[:delete_type] == "全部删除"
          all_vlan_names = get_all_vlan_interface_names() # 数组类型
        else
          all_vlan_names = hash[:names].to_s.split("&") # 数组类型
        end
        post_hash = {"opr" => "delete", "name" => all_vlan_names}
        result_hash = AF::Login.get_session().post(VlanCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑VLAN接口
描述: 编辑指定的VLAN接口,若某个参数未在用例的关键字中写出,该参数不使用原来的设置,使用当前新设置的值
参数:
id=>name,name=>VLAN接口名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要编辑VLAN接口的名称,名称不可修改"
id=>new_name,name=>新名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"要修改成的新名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>enable_ping,name=>允许PING,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选允许PING"
id=>link_type,name=>连接类型,type=>s,must=>false,default=>"静态IP",value=>"静态IP|DHCP",descrip=>"VLAN接口的连接类型"
id=>area_name,name=>所属区域,type=>s,must=>false,default=>"default",value=>"{text}",descrip=>"接口所属区域"
id=>static_ip,name=>静态IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当连接类型选择静态IP时,要输入的静态IP"
id=>gateway,name=>下一跳网关,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当连接类型选择静态IP时,要输入的下一跳网关"
id=>get_default_gw,name=>获取默认网关,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"当连接类型选择DHCP时,是否勾选获取默认网关"
id=>enable_link_trouble_check,name=>启用链路故障检测,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用链路故障检测"
id=>check_method,name=>故障检测方法,type=>s,must=>false,default=>"PING",value=>"PING|DNS解析",descrip=>"启用链路故障检测时,选择的链路故障检测方法"
id=>dns_server,name=>DNS服务器,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"启用链路故障检测,选择DNS解析方法时,输入的DNS服务器"
id=>dns_domain,name=>解析域名,type=>s,must=>false,default=>"www.sangfor.com",value=>"{text}",descrip=>"启用链路故障检测,选择DNS解析方法时,输入的域名地址"
id=>ping_ip,name=>PING目标IP,type=>s,must=>false,default=>"202.96.137.23",value=>"{text}",descrip=>"启用链路故障检测,选择PIND方法时,输入的目标IP地址"
id=>check_interval,name=>检测间隔,type=>s,must=>false,default=>"2",value=>"{text}",descrip=>"启用链路故障检测时输入的检测间隔,单位是秒"
id=>mtu,name=>MTU,type=>s,must=>false,default=>"1500",value=>"{text}",descrip=>"高级设置中的MTU"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def edit_vlan_interface( hash )
        ATT::KeyLog.debug("edit vlan interface......")
        post_hash = get_edit_vlan_interface_post_hash( hash )
        result_hash = AF::Login.get_session().post(VlanCGI, post_hash)
        if result_hash["success"]
          clear_zone_by_default(hash)
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=begin rdoc
关键字名: 检查VLAN接口设置
描述: 在VLAN接口列表页面,检查某个VLAN接口当前的设置
参数:
id=>name,name=>VLAN接口名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要检查VLAN接口的名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的描述"
id=>zone,name=>区域,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望所属的区域"
id=>link_type,name=>连接类型,type=>s,must=>false,default=>"忽略",value=>"静态IP|DHCP|无效|忽略",descrip=>"期望的接口连接类型,忽略表示不检查此参数,无效即---"
id=>address,name=>地址,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的地址,如1.1.1.1/24或1.1.1.1/255.255.255.0"
id=>mtu,name=>MTU,type=>s,must=>false,default=>"1500",value=>"{text}",descrip=>"期望的MTU"
id=>enable_ping,name=>PING,type=>s,must=>false,default=>"忽略",value=>"允许|拒绝|忽略",descrip=>"期望是否允许PING,忽略表示不检查此参数"
id=>link_status,name=>链路状态,type=>s,must=>false,default=>"忽略",value=>"故障|正常|未检测|忽略",descrip=>"期望的链路状态,忽略表示不检查此参数"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|VLAN接口不存在|描述错误|区域错误|连接类型|IP地址错误|MTU错误|PING错误|链路状态错误",descrip=>""
=end
      def check_vlan_interface( hash )
        ATT::KeyLog.debug("check vlan interface info......")
        all_vlan_names = get_all_vlan_interface_names()
        return_fail("VLAN接口不存在") unless all_vlan_names.include?(hash[:name])

        all_vlan_interfaces = list_all_vlan_interfaces
        all_vlan_interfaces.each do |vlan_interface_info_hash|
          if hash[:name] == vlan_interface_info_hash["name"]
            check_vlan_interface_info(vlan_interface_info_hash, hash )
          end
        end
      end

=begin rdoc
关键字名: 新增区域
描述: 新增区域
参数:
id=>name,name=>区域名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"区域的名称"
id=>forward_type,name=>转发类型,type=>s,must=>false,default=>"二层区域",value=>"二层区域|三层区域|虚拟网线区域",descrip=>"区域的转发类型"
id=>interfaces,name=>接口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"区域包含的接口,多个使用|分割"
id=>enable_webui,name=>WEBUI,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"管理选项中是否勾选WEBUI"
id=>enable_ssh,name=>SSH,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"管理选项中是否勾选SSH"
id=>enable_snmp,name=>SNMP,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"管理选项中是否勾选SNMP"
id=>manage_address,name=>管理地址,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"管理地址即选择的IP组，多个之间以&隔开"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|不存在的转发类型|IP组不存在|转发类型与接口不匹配",descrip=>""
=end
      def add_zone( hash )
        ATT::KeyLog.debug("add zone......")
        post_hash = get_add_zone_post_hash( hash )
        result_hash = AF::Login.get_session().post(ZoneCGI, post_hash)
        if result_hash["success"]
          ATT::KeyLog.info("返回信息是#{result_hash["msg"]}")
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除区域
描述: 删除指定的区域
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的区域,还是删除目前所有的区域"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的区域名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_zone( hash )
        ATT::KeyLog.debug("delete zones......")
        if hash[:delete_type] == "全部删除"
          all_zone_names = DeviceConsole::get_all_object_names(ZoneCGI, "区域") # get_all_zone_names() # 数组类型
        else
          all_zone_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_zone_names.empty? # 不存在任何区域时,直接返回成功
        post_hash = {"opr" => "delete", "name" => all_zone_names }
        result_hash = AF::Login.get_session().post(ZoneCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑区域
描述: 编辑指定的某个区域,若某个参数未在用例的关键字中写出,该参数不使用原来的设置,使用当前新设置的值
参数:
id=>name,name=>区域名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要编辑区域的名称,名称不可修改"
id=>forward_type,name=>转发类型,type=>s,must=>false,default=>"二层区域",value=>"二层区域|三层区域|虚拟网线区域",descrip=>"区域的转发类型"
id=>interfaces,name=>接口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"区域包含的接口,多个使用|分割"
id=>enable_webui,name=>WEBUI,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"管理选项中是否勾选WEBUI"
id=>enable_ssh,name=>SSH,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"管理选项中是否勾选SSH"
id=>enable_snmp,name=>SNMP,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"管理选项中是否勾选SNMP"
id=>manage_address,name=>管理地址,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"管理地址即选择的IP组"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def edit_zone( hash )
        ATT::KeyLog.debug("edit zone......")
        post_hash = get_edit_zone_post_hash( hash )
        result_hash = AF::Login.get_session().post(ZoneCGI, post_hash)
        if result_hash["success"]
          ATT::KeyLog.info("返回信息是#{result_hash["msg"]}")
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 启禁接口联动
描述: 启用或禁用接口联动
参数:
id=>operation,name=>操作,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"启用还是禁用接口联动"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_interface_linkage( hash )
        operation = (hash[:operation] == "启用"? true : false)
        post_hash = { "opr" => "PortLinkage_StartEnable", "data" => { "enable" => operation } }
        result_hash = AF::Login.get_session().post(InterfaceLinkageCGI, post_hash)
        if result_hash["success"]
          ATT::KeyLog.info("#{hash[:operation]}接口联动成功")
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end

=begin rdoc
关键字名: 新增接口联动
描述: 新增接口联动
参数:
id=>name,name=>接口联动名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"接口联动的名称"
id=>interfaces,name=>物理接口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"接口联动包含的物理接口,多个使用&分割,不能为空"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_interface_linkage( hash )
        ATT::KeyLog.debug("add interface linkage......")
        post_hash = get_add_interface_linkage_post_hash( hash )
        result_hash = AF::Login.get_session().post(InterfaceLinkageCGI, post_hash)
        if result_hash["success"]
          ATT::KeyLog.info("返回信息是#{result_hash["msg"]}")
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      
=begin rdoc
关键字名: 删除接口联动
描述: 删除指定的接口联动规则
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的接口联动,还是删除目前所有的接口联动"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的接口联动名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_interface_linkage( hash )
        ATT::KeyLog.debug("delete interface linkages......")
        if hash[:delete_type] == "全部删除"
          all_linkage_names = DeviceConsole::get_all_object_names(InterfaceLinkageCGI, "接口联动") # get_all_linkage_names() # 数组类型
        else
          all_linkage_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_linkage_names.empty? # 不存在任何接口联动时,直接返回成功
        post_hash = {"opr" => "delete", "name" => all_linkage_names}
        result_hash = AF::Login.get_session().post(InterfaceLinkageCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      
      def clear_zone_by_default(hash)
          if hash[:area_name] == "default" or hash[:area_name] == "default2" or hash[:area_name] == "defaultv"
            fortype = "三层区域" if hash[:area_name] == "default"
            fortype = "二层区域" if hash[:area_name] == "default2"
            fortype = "虚拟网线区域" if hash[:area_name] == "defaultv"
            edit_zone({:name => hash[:area_name],:forward_type => fortype, :interfaces => "", :enable_webui => "是",
                :enable_ssh => "是", :enable_snmp => "是",:manage_address => "全部"})
          end
      end
      

    end
  end
end
