# coding: utf8
=begin rdoc
作用: 封装DOS防护页面上的操作
维护记录:
维护人      时间                  行为
gsj     2012-05-22              创建
=end

module DeviceConsole

  module FireWall


=begin rdoc
类名: DOS防护
描述: DOS/DDOS防护
=end
    class DosDefence < ATT::Base

=begin rdoc
关键字名: 设置内网防护策略
描述: 设置内网防护策略
维护人: gsj
参数:
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用内网防护"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分隔"
id=>source_filter,name=>源地址过滤,type=>s,must=>false,default=>"允许任意源IP",value=>"允许任意源IP|允许指定源IP",descrip=>"源地址过滤,选择'允许任意源IP地址的数据包通过'还是'仅允许以下IP地址数据包通过'"
id=>source_ips,name=>指定源IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源地址过滤选择'仅允许以下IP地址数据包通过'时,输入指定的源IP,多个时使用&分隔"
id=>env_deployment,name=>部署环境,type=>s,must=>false,default=>"二层",value=>"二层|三层",descrip=>"部署环境选择'内网通过二层交换设备与本机直连'还是'内部网络到本机通过三层交换设备相连'"
id=>exclude_ips,name=>排除地址,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"排除地址,可为空,多个地址时使用&分隔"
id=>tcp_conn,name=>TCP最大连接数,type=>s,must=>false,default=>"1024",value=>"{text}",descrip=>"TCP最大连接数,默认是1024"
id=>max_times,name=>最大攻击包次数,type=>s,must=>false,default=>"10240",value=>"{text}",descrip=>"最大攻击包次数,默认是10240"
id=>block_time,name=>封锁攻击时间,type=>s,must=>false,default=>"2",value=>"{text}",descrip=>"封锁攻击时间,单位是分钟,默认是2分钟"
id=>record_logs,name=>记录日志,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否要记录攻击日志"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def set_intranet_dos_defence(hash)
        ATT::KeyLog.debug("设置内网防护策略......")
        post_hash = get_set_intranet_dos_defence_post_hash( hash )
        result_hash = AF::Login.get_session().post(IntranetDosAttackCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增外网防护策略
描述: 新增外网防护策略
维护人: gsj
参数:
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用当前新增的外网防护策略"
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"外网防护策略的名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"外网防护策略的描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分隔"
id=>arp_defence,name=>ARP攻击防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选ARP洪水攻击防护,默认不勾选"
id=>arp_threshold,name=>ARP攻击阀值,type=>s,must=>false,default=>"5000",value=>"{text}",descrip=>"ARP洪水攻击防护下的每源区域阀值,默认是5000"
id=>ipscan_defence,name=>IP地址扫描防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选IP地址扫描防护,默认不勾选"
id=>ipscan_threshold,name=>IP地址扫描阀值,type=>s,must=>false,default=>"4000",value=>"{text}",descrip=>"IP地址扫描防护下的阀值,默认是4000"
id=>portscan_defence,name=>端口扫描防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选端口扫描防护,默认不勾选"
id=>portscan_threshold,name=>端口扫描阀值,type=>s,must=>false,default=>"4000",value=>"{text}",descrip=>"端口扫描防护下的阀值,默认是4000"
id=>dos_dstip_group,name=>DOS防护目的IP组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"DOS攻击防护下的目的IP组,多个时使用&分隔"
id=>icmp_defence,name=>ICMP攻击防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选ICMP洪水攻击防护,默认不勾选"
id=>icmp_threshold,name=>ICMP攻击阀值,type=>s,must=>false,default=>"2000",value=>"{text}",descrip=>"ICMP洪水攻击防护下的每目的IP阀值,默认是2000"
id=>udp_defence,name=>UDP攻击防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选UDP洪水攻击防护,默认不勾选"
id=>udp_threshold,name=>UDP攻击阀值,type=>s,must=>false,default=>"100000",value=>"{text}",descrip=>"UDP洪水攻击防护下的每目的IP阀值,默认是100000"
id=>syn_defence,name=>SYN攻击防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选SYN洪水攻击防护,默认不勾选"
id=>syn_dstip_activate_threshold,name=>SYN攻击目的IP激活阀值,type=>s,must=>false,default=>"5000",value=>"{text}",descrip=>"SYN洪水攻击防护下的目的IP激活阀值,默认是5000"
id=>syn_dstip_drop_threshold,name=>SYN攻击目的IP丢包阀值,type=>s,must=>false,default=>"10000",value=>"{text}",descrip=>"SYN洪水攻击防护下的目的IP丢包阀值,默认是10000"
id=>syn_srcip_threshold,name=>SYN攻击源IP阀值,type=>s,must=>false,default=>"10000",value=>"{text}",descrip=>"SYN洪水攻击防护下的源IP阀值,默认是10000"
id=>dns_defence,name=>DNS攻击防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选DNS洪水攻击防护,默认不勾选"
id=>dns_threshold,name=>DNS攻击阀值,type=>s,must=>false,default=>"10000",value=>"{text}",descrip=>"DNS洪水攻击防护下的目的地址阀值,默认是10000"
id=>data_packet_defence,name=>数据包攻击类型,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"数据包攻击类型,多个时使用&分隔,可选的类型包含:未知协议类型防护,TearDrop攻击防护,IP数据块分片传输防护,LAND攻击防护,WinNuke攻击防护,Smurf攻击防护,超大ICMP数据攻击防护"
id=>ip_protocol_options,name=>IP协议报文选项,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"IP协议报文选项,多个时使用&分隔,可选的包含:错误的IP报文选项防护,IP时间戳选项报文防护,IP安全选项报文防护,IP数据流项报文防护,IP记录路由选项报文防护,IP宽松源路由选项报文防护,IP严格源路由选项报文防护"
id=>tcp_protocol_options,name=>TCP协议报文选项,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"TCP协议报文选项,多个时使用&分隔,可选的包含:SYN数据分片传输防护,TCP报头标志位全为0防护,SYN和FIN标志位同时为1防护,仅FIN标志位为1防护"
id=>record_logs,name=>记录日志,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否要勾选记录攻击日志"
id=>block,name=>阻断,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否要勾选阻断"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_internet_dos_defence_policy( hash )
        ATT::KeyLog.debug("新增外网防护策略......")
        post_hash = get_add_internet_dos_defence_policy_post_hash( hash )
        result_hash = AF::Login.get_session().post(InternetDosAttackCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 启禁外网防护策略
描述: 启用或禁用外网防护策略
参数:
id=>names,name=>名称列表,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要启用或禁用的外网防护策略名称,多个时使用&分割"
id=>operation,name=>操作,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"启用还是禁用指定的外网防护策略"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
      def enable_disable_internet_dos_defence_policy( hash )
        operation = (hash[:operation] == "启用" ? "enable" : "disable")
        post_hash = {"opr" => operation, "name" => hash[:names].split("&") }
        result_hash = AF::Login.get_session().post(InternetDosAttackCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end
      
=begin rdoc
关键字名: 删除外网防护策略
描述: 删除所有或指定的外网防护策略
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的外网防护策略,还是删除目前所有的外网防护策略"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的外网防护策略名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_internet_dos_defence_policy( hash )
        ATT::KeyLog.debug("删除外网防护策略......")
        if hash[:delete_type] == "全部删除"
          all_internet_dos_defence_policy_names = get_all_internet_dos_defence_policy_names() # 获取所有外网防护策略的名称,数组类型
        else
          all_internet_dos_defence_policy_names = hash[:names].to_s.split("&") # 数组类型
        end
        post_hash = {"opr" => "delete", "name" => all_internet_dos_defence_policy_names}
        result_hash = AF::Login.get_session().post(InternetDosAttackCGI, post_hash)
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
