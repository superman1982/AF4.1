# coding: utf8
=begin rdoc
作用: 高级网络配置页面上的操作
维护记录:
维护人      时间                  行为
gsj      2011-12-07             创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module NetConfig


=begin rdoc
类名: 高级网络配置
描述: 高级网络配置
=end
    class AdvancedNetConfig < ATT::Base


=begin rdoc
关键字名: 新增ARP表项
描述: 新增ARP表项
维护人: zwjie
参数:
id=>ip_address,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"IP地址"
id=>mac_address,name=>MAC地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"MAC地址，如00:E0:4C:0E:9A:2F或00-E0-4C-0E-9A-2F"
id=>eth,name=>接口,type=>s,must=>false,default=>"自动检测",value=>"{text}",descrip=>"指向的接口，如eth0"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_arp_table(hash)
        ATT::KeyLog.debug("add static arp table......")
        post_hash = get_add_arp_table_post_hash( hash )
        result_hash = AF::Login.get_session().post(ArpConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑ARP表项
描述: 编辑ARP表项
维护人: zwjie
参数:
id=>old_ip_address,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"指定需要编辑的IP地址"
id=>ip_address,name=>新IP地址,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"IP地址"
id=>mac_address,name=>MAC地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"MAC地址，如00:E0:4C:0E:9A:2F或00-E0-4C-0E-9A-2F"
id=>eth,name=>接口,type=>s,must=>false,default=>"自动检测",value=>"{text}",descrip=>"指向的接口，如eth0"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def edit_arp_table(hash)
        ATT::KeyLog.debug("edit static arp table......")
        post_hash = get_edit_arp_table_post_hash( hash )
        result_hash = AF::Login.get_session().post(ArpConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除ARP表项
描述: 删除ARP表项
维护人: zwjie
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定的ARP表项,还是删除目前所有的ARP表项"
id=>ips,name=>IP列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的ARP表项的IP,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_arp_table(hash)
        ATT::KeyLog.debug("delete static arp table......")
        if hash[:delete_type] == "全部删除"
          all_arp_table_names = DeviceConsole::get_all_object_names(ArpConfigCGI, "静态ARP表项") # 数组类型
        else
          all_arp_table_names = []
          ip_names = hash[:ips].to_s.split("&")
          ip_names.each do |ip|
            all_arp_table_names << get_arp_name(ip)
          end
        end
        return_ok if all_arp_table_names.empty? # 不存在任何ARP表项时,直接返回成功
        post_hash = {"opr" => "delete", "name" => all_arp_table_names}
        result_hash = AF::Login.get_session().post(ArpConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 自动获取MAC地址
描述: 新增静态ARP时自动获取MAC地址
维护人: zwjie
参数:
id=>ip_address,name=>IP地址,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"自动获取MAC地址的IP地址"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def auto_get_mac_address(hash)
        ATT::KeyLog.debug("auto get MAC address......")
        post_hash = {"opr" =>"ip_to_mac","ipAddress" => hash[:ip_address]}
        result_hash = AF::Login.get_session().post(ArpConfigCGI, post_hash)
        if result_hash["success"]
          mac_address = result_hash["mac"]
          ATT::KeyLog.info("IP地址:#{hash[:ip_address]}自动获取的MAC地址为:#{mac_address}")
          return mac_address
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 设置DNS
描述: 设置DNS服务器和DNS代理
参数:
id=>first_dns,name=>首选DNS地址,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"首选DNS服务器地址"
id=>secondary_dns,name=>备选DNS地址,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"备选DNS服务器地址"
id=>enable_dns_proxy,name=>启用DNS代理,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用DNS代理"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def set_dns_server_and_proxy(hash)
        ATT::KeyLog.debug("set dns server and proxy......")
        post_hash = get_set_dns_server_and_proxy_post_hash( hash )
        result_hash = AF::Login.get_session().post(DnsConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 启禁DHCP服务
描述: 启用或禁用DHCP服务
维护人: zwjie
参数:
id=>operation,name=>操作,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"启用还是禁用SNMP"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_dhcp(hash)
        ATT::KeyLog.debug("enable or disable DHCP service......")
        post_hash = { "opr" => "submit", "enable" => hash[:operation].to_logic }
        result_hash = AF::Login.get_session().post(DHCPConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑DHCP服务
描述: 编辑DHCP服务
维护人: zwjie
参数:
id=>interface,name=>接口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"编辑DHCP服务的接口"
id=>lease,name=>租期,type=>s,must=>false,default=>"120",value=>"{text}",descrip=>"DHCP服务的租期,单位分钟"
id=>gw,name=>网关,type=>s,must=>false,default=>"0.0.0.0",value=>"{text}",descrip=>"DHCP服务的网关"
id=>mask,name=>子网掩码,type=>s,must=>false,default=>"0.0.0.0",value=>"{text}",descrip=>"DHCP服务的子网掩码"
id=>master_dns,name=>首选DNS,type=>s,must=>false,default=>"0.0.0.0",value=>"{text}",descrip=>"DHCP服务的首选DNS"
id=>slave_dns,name=>备用DNS,type=>s,must=>false,default=>"0.0.0.0",value=>"{text}",descrip=>"DHCP服务的备用DNS"
id=>master_wins,name=>首选WINS,type=>s,must=>false,default=>"0.0.0.0",value=>"{text}",descrip=>"DHCP服务的首选WINS"
id=>slave_wins,name=>备用WINS,type=>s,must=>false,default=>"0.0.0.0",value=>"{text}",descrip=>"DHCP服务的备用WINS"
id=>range,name=>IP地址范围,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"DHCP服务的IP地址范围，多个时使用&分割"
id=>reserved,name=>保留IP设置,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"DHCP服务的保留IP设置，以格式‘名称/IP地址/MAC地址/机器名’输入，多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
     def edit_dhcp(hash)
        ATT::KeyLog.debug("edit dhcp service......")
        post_hash = get_edit_dhcp( hash )
        result_hash = AF::Login.get_session().post(DHCPConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=begin rdoc
关键字名: 启禁SNMP
描述: 启用或禁用SNMP
参数:
id=>operation,name=>操作,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"启用还是禁用SNMP"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_snmp(hash)
        ATT::KeyLog.debug("enable or disable snmp......")
        post_hash = { "opr" => "submit", "enable" => hash[:operation].to_logic }
        result_hash = AF::Login.get_session().post(SnmpConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      
=begin rdoc
关键字名: 新增SNMP管理主机
描述: 新增SNMP管理主机
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"管理主机的名称"
id=>addr_type,name=>地址类型,type=>s,must=>false,default=>"主机",value=>"主机|子网",descrip=>"管理主机的地址类型"
id=>address,name=>地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"管理主机的地址"
id=>community_name,name=>团体名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"管理主机所在的团体名"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_snmp_host_manager(hash)
        ATT::KeyLog.debug("add snmp host manaager......")
        post_hash = get_add_snmp_host_manager_post_hash( hash )
        result_hash = AF::Login.get_session().post(SnmpConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=begin rdoc
关键字名: 编辑SNMP管理主机
描述: 编辑SNMP管理主机
维护人: zwjie
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"管理主机的名称"
id=>addr_type,name=>地址类型,type=>s,must=>false,default=>"主机",value=>"主机|子网",descrip=>"管理主机的地址类型"
id=>address,name=>地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"管理主机的地址"
id=>community_name,name=>团体名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"管理主机所在的团体名"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def edit_snmp_host_manager(hash)
        ATT::KeyLog.debug("edit snmp host manaager......")
        post_hash = get_edit_snmp_host_manager_post_hash( hash )
        result_hash = AF::Login.get_session().post(SnmpConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=begin rdoc
关键字名: 删除SNMP管理主机
描述: 删除指定的SNMP管理主机
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的SNMP管理主机,还是删除目前所有的SNMP管理主机"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的SNMP管理主机名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_snmp_host_manager( hash )
        ATT::KeyLog.debug("delete snmp host manaager......")
        if hash[:delete_type] == "全部删除"
          all_snmp_host_manager_names = DeviceConsole::get_all_object_names(SnmpConfigCGI, "SNMP管理主机")
        else
          all_snmp_host_manager_names = hash[:names].to_s.split("&") # 数组类型
        end
        post_hash = {"opr" => "delete", "name" => all_snmp_host_manager_names}
        result_hash = AF::Login.get_session().post(SnmpConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=begin rdoc
关键字名: 新增SNMP_V3规则
描述: 新增SNMP_V3规则
维护人: zwjie
参数:
id=>name,name=>用户名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"SNMP V3规则的用户名称"
id=>pubkey,name=>认证密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"SNMP V3规则的认证密码"
id=>confirm_pubkey,name=>确认认证密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"确认SNMP V3规则的认证密码"
id=>prikey,name=>加密密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"SNMP V3规则的加密密码"
id=>confirm_prikey,name=>确认加密密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"确认SNMP V3规则的加密密码"
id=>safelevel,name=>安全级别,type=>s,must=>false,default=>"加密",value=>"加密|不加密",descrip=>"SNMP V3规则的安全级别"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_snmp_v3_rule(hash)
        ATT::KeyLog.debug("add snmp v3 rule......")
        post_hash = get_add_snmp_v3_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(SnmpVConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑SNMP_V3规则
描述: 编辑SNMP_V3规则
维护人: zwjie
参数:
id=>name,name=>用户名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"SNMP V3规则的用户名称"
id=>pubkey,name=>认证密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"SNMP V3规则的认证密码"
id=>confirm_pubkey,name=>确认认证密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"确认SNMP V3规则的认证密码"
id=>prikey,name=>加密密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"SNMP V3规则的加密密码"
id=>confirm_prikey,name=>确认加密密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"确认SNMP V3规则的加密密码"
id=>safelevel,name=>安全级别,type=>s,must=>false,default=>"加密",value=>"加密|不加密",descrip=>"SNMP V3规则的安全级别"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def edit_snmp_v3_rule(hash)
        ATT::KeyLog.debug("edit snmp v3 rule......")
        post_hash = get_edit_snmp_v3_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(SnmpVConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除SNMP_V3规则
描述: 删除指定的SNMP_V3规则
维护人: zwjie
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的SNMP V3规则,还是删除目前所有的SNMP V3规则"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的 V3规则名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_snmp_v3_rule( hash )
        ATT::KeyLog.debug("delete snmp v3 rules......")
        if hash[:delete_type] == "全部删除"
          all_snmp_v3_rule_names = DeviceConsole::get_all_object_names(SnmpVConfigCGI, "SNMP V3规则")
        else
          all_snmp_v3_rule_names = hash[:names].to_s.split("&") # 数组类型
        end
        post_hash = {"opr" => "delete", "name" => all_snmp_v3_rule_names}
        result_hash = AF::Login.get_session().post(SnmpVConfigCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

    end
  end
end
