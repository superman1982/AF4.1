# coding: utf8
#
# This file is generated by att util tool.
# by 2012-05-22 11:24:44
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'../../../../') unless $LOADED
require 'keywords/unittests/setup'

$stdouttype = "GBK"

class TestDosDefence < Test::Unit::TestCase
  def setup
    @common = Common.new
    @interface_zone = DeviceConsole::NetConfig::InterfaceZone.new
    @dos_defence = keyword_proxy_for_class_name( DeviceConsole::FireWall::DosDefence ).new
    @ip_group = DeviceConsole::ObjectDefinition::IpGroup.new

    assert_success do
      @common.set_current_device( $common["login_hash"] ) # 设置正确的当前设备的IP,用户名,密码
    end
  end

  def test_set_intranet_dos_defence
    # 新增区域
    assert_success do
      @interface_zone.add_zone(:name => "zone221", :forward_type => "三层区域", :interfaces => "",
        :enable_webui => "是", :enable_ssh => "是", :enable_snmp => "是", :manage_address => "全部")
    end
    assert_success do
      @interface_zone.add_zone(:name => "zone222", :forward_type => "三层区域", :interfaces => "",
        :enable_webui => "是", :enable_ssh => "是", :enable_snmp => "是", :manage_address => "全部")
    end
    # 设置内网防护策略
    assert_success do
      @dos_defence.set_intranet_dos_defence({:enable => "否", :source_zone => "", :source_filter => "允许任意源IP",
        :source_ips => "", :env_deployment => "二层", :exclude_ips => "22.22.22.22/255.255.255.0&33.22.22.22/255.255.255.0",
        :tcp_conn => "1024", :max_times => "512", :block_time => "1", :record_logs => "是" })
    end
    # 设置内网防护策略
    assert_success do
      @dos_defence.set_intranet_dos_defence({:enable => "是", :source_zone => "zone221&zone222", :source_filter => "允许任意源IP",
        :source_ips => "", :env_deployment => "二层", :exclude_ips => "22.22.22.22/255.255.255.0&33.22.22.22/255.255.255.0",
        :tcp_conn => "1024", :max_times => "10240", :block_time => "2", :record_logs => "是" })
    end
    # 设置内网防护策略
    assert_success do
      @dos_defence.set_intranet_dos_defence({:enable => "是", :source_zone => "zone221", :source_filter => "允许指定源IP",
        :source_ips => "22.22.22.22/255.255.255.0&33.22.22.22/255.255.255.0", :env_deployment => "三层", :exclude_ips => "",
        :tcp_conn => "1024", :max_times => "512", :block_time => "1", :record_logs => "是" })
    end
    # 设置内网防护策略,不记录日志
    assert_success do
      @dos_defence.set_intranet_dos_defence({:enable => "是", :source_zone => "zone222", :source_filter => "允许指定源IP",
        :source_ips => "22.22.22.22/255.255.255.0&33.22.22.22/255.255.255.0", :env_deployment => "三层", :exclude_ips => "",
        :tcp_conn => "1024", :max_times => "512", :block_time => "1", :record_logs => "否" })
    end
    # 设置内网防护策略,引用不存在的源区域
    assert_fail do
      @dos_defence.set_intranet_dos_defence({:enable => "是", :source_zone => "aaaaaaaa", :source_filter => "允许指定源IP",
        :source_ips => "22.22.22.22/255.255.255.0&33.22.22.22/255.255.255.0", :env_deployment => "三层", :exclude_ips => "",
        :tcp_conn => "1024", :max_times => "512", :block_time => "1", :record_logs => "是" })
    end
    # 设置内网防护策略
    assert_success do
      @dos_defence.set_intranet_dos_defence({:enable => "否", :source_zone => "", :source_filter => "允许任意源IP",
        :source_ips => "", :env_deployment => "二层", :exclude_ips => "",
        :tcp_conn => "1024", :max_times => "10240", :block_time => "2", :record_logs => "是" })
    end
    # 删除区域
    assert_success do
      @interface_zone.delete_zone( {:delete_type => "部分删除", :names => "zone221&zone222"})
    end
  end

  def test_add_internet_dos_defence_policy
    # 新增IP组,正常
    assert_success do
      @ip_group.add_ip_group({:group_name => "IpGrp1", :description => "描述", :ip_addresses => "2.2.2.2&1.1.1.1-1.1.1.100&3.3.3.3"})
    end
    assert_success do
      @ip_group.add_ip_group({:group_name => "IpGrp2", :description => "描述", :ip_addresses => "2.2.2.2 & 1.1.1.1-1.1.1.100& 3.3.3.3 "})
    end
    # 新增区域
    assert_success do
      @interface_zone.add_zone(:name => "zone223", :forward_type => "三层区域", :interfaces => "",
        :enable_webui => "是", :enable_ssh => "是", :enable_snmp => "是", :manage_address => "全部")
    end
    assert_success do
      @interface_zone.add_zone(:name => "zone224", :forward_type => "三层区域", :interfaces => "",
        :enable_webui => "是", :enable_ssh => "是", :enable_snmp => "是", :manage_address => "全部")
    end

    # 新增外网防护策略,勾选所有防护
    assert_success do
      @dos_defence.add_internet_dos_defence_policy({:enable => "是", :name => "OUTDOS1", :description => "描述描述",
        :source_zone => "zone223&zone224", :arp_defence => "是", :arp_threshold => "5000",
        :ipscan_defence => "是", :ipscan_threshold => "4000", :portscan_defence => "是", :portscan_threshold => "4000",
        :dos_dstip_group => "IpGrp1&IpGrp2", :icmp_defence => "是", :icmp_threshold => "2000",
        :udp_defence => "是", :udp_threshold => "100000", :syn_defence => "是", :syn_dstip_activate_threshold => "5000",
        :syn_dstip_drop_threshold => "10000", :syn_srcip_threshold => "10000", :dns_defence => "是",
        :dns_threshold => "10000", :data_packet_defence => "未知协议类型防护&TearDrop攻击防护&IP数据块分片传输防护&LAND攻击防护&WinNuke攻击防护&Smurf攻击防护&超大ICMP数据攻击防护",
        :ip_protocol_options => "错误的IP报文选项防护&IP时间戳选项报文防护&IP安全选项报文防护&IP数据流项报文防护&IP记录路由选项报文防护&IP宽松源路由选项报文防护&IP严格源路由选项报文防护",
        :tcp_protocol_options => "SYN数据分片传输防护&TCP报头标志位全为0防护&SYN和FIN标志位同时为1防护&仅FIN标志位为1防护",
        :record_logs => "是", :block => "是"  })
    end
    # 新增外网防护策略,不勾选任何防护
    assert_success do
      @dos_defence.add_internet_dos_defence_policy({:enable => "是", :name => "OUTDOS2", :description => "",
        :source_zone => "zone223", :arp_defence => "否", :arp_threshold => "5000",
        :ipscan_defence => "否", :ipscan_threshold => "4000", :portscan_defence => "否", :portscan_threshold => "4000",
        :dos_dstip_group => "全部", :icmp_defence => "否", :icmp_threshold => "2000",
        :udp_defence => "否", :udp_threshold => "100000", :syn_defence => "否", :syn_dstip_activate_threshold => "5000",
        :syn_dstip_drop_threshold => "10000", :syn_srcip_threshold => "10000", :dns_defence => "否",
        :dns_threshold => "10000", :data_packet_defence => "",
        :ip_protocol_options => "",
        :tcp_protocol_options => "",
        :record_logs => "否", :block => "否"  })
    end
    # 新增外网防护策略,勾选部分防护
    assert_success do
      @dos_defence.add_internet_dos_defence_policy({:enable => "是", :name => "OUTDOS3", :description => "描述",
        :source_zone => "zone224", :arp_defence => "是", :arp_threshold => "6000",
        :ipscan_defence => "是", :ipscan_threshold => "5000", :portscan_defence => "否", :portscan_threshold => "4000",
        :dos_dstip_group => "IpGrp2", :icmp_defence => "否", :icmp_threshold => "2000",
        :udp_defence => "是", :udp_threshold => "500000", :syn_defence => "否", :syn_dstip_activate_threshold => "5000",
        :syn_dstip_drop_threshold => "10000", :syn_srcip_threshold => "10000", :dns_defence => "是",
        :dns_threshold => "30000", :data_packet_defence => "TearDrop攻击防护&LAND攻击防护&WinNuke攻击防护&超大ICMP数据攻击防护",
        :ip_protocol_options => "错误的IP报文选项防护&IP安全选项报文防护&IP记录路由选项报文防护&IP严格源路由选项报文防护",
        :tcp_protocol_options => "仅FIN标志位为1防护",
        :record_logs => "是", :block => "是"  })
    end
    # 新增外网防护策略,勾选所有防护,引用不存在的区域
    assert_fail do
      @dos_defence.add_internet_dos_defence_policy({:enable => "是", :name => "OUTDOS4", :description => "描述描述",
        :source_zone => "bbbbbbbbss", :arp_defence => "是", :arp_threshold => "5000",
        :ipscan_defence => "是", :ipscan_threshold => "4000", :portscan_defence => "是", :portscan_threshold => "4000",
        :dos_dstip_group => "IpGrp1&IpGrp2", :icmp_defence => "是", :icmp_threshold => "2000",
        :udp_defence => "是", :udp_threshold => "100000", :syn_defence => "是", :syn_dstip_activate_threshold => "5000",
        :syn_dstip_drop_threshold => "10000", :syn_srcip_threshold => "10000", :dns_defence => "是",
        :dns_threshold => "10000", :data_packet_defence => "未知协议类型防护&TearDrop攻击防护&IP数据块分片传输防护&LAND攻击防护&WinNuke攻击防护&Smurf攻击防护&超大ICMP数据攻击防护",
        :ip_protocol_options => "错误的IP报文选项防护&IP时间戳选项报文防护&IP安全选项报文防护&IP数据流项报文防护&IP记录路由选项报文防护&IP宽松源路由选项报文防护&IP严格源路由选项报文防护",
        :tcp_protocol_options => "SYN数据分片传输防护&TCP报头标志位全为0防护&SYN和FIN标志位同时为1防护&仅FIN标志位为1防护",
        :record_logs => "是", :block => "是"  })
    end
    # 新增外网防护策略,勾选所有防护,引用不存在的IP组
    assert_fail do
      @dos_defence.add_internet_dos_defence_policy({:enable => "是", :name => "OUTDOS5", :description => "描述描述",
        :source_zone => "zone224", :arp_defence => "是", :arp_threshold => "5000",
        :ipscan_defence => "是", :ipscan_threshold => "4000", :portscan_defence => "是", :portscan_threshold => "4000",
        :dos_dstip_group => "古古怪怪感光鼓", :icmp_defence => "是", :icmp_threshold => "2000",
        :udp_defence => "是", :udp_threshold => "100000", :syn_defence => "是", :syn_dstip_activate_threshold => "5000",
        :syn_dstip_drop_threshold => "10000", :syn_srcip_threshold => "10000", :dns_defence => "是",
        :dns_threshold => "10000", :data_packet_defence => "未知协议类型防护&TearDrop攻击防护&IP数据块分片传输防护&LAND攻击防护&WinNuke攻击防护&Smurf攻击防护&超大ICMP数据攻击防护",
        :ip_protocol_options => "错误的IP报文选项防护&IP时间戳选项报文防护&IP安全选项报文防护&IP数据流项报文防护&IP记录路由选项报文防护&IP宽松源路由选项报文防护&IP严格源路由选项报文防护",
        :tcp_protocol_options => "SYN数据分片传输防护&TCP报头标志位全为0防护&SYN和FIN标志位同时为1防护&仅FIN标志位为1防护",
        :record_logs => "是", :block => "是"  })
    end
    # 删除外网防护策略
    assert_success do
      @dos_defence.delete_internet_dos_defence_policy({:delete_type => "部分删除", :names => "OUTDOS3&OUTDOS2"})
    end
    assert_success do
      @dos_defence.delete_internet_dos_defence_policy({:delete_type => "全部删除", :names => ""})
    end
    # 删除区域
    assert_success do
      @interface_zone.delete_zone( {:delete_type => "部分删除", :names => "zone223&zone224"})
    end
    # 删除所有的IP组
    assert_success do
      @ip_group.delete_ip_group({ :delete_type => "部分删除", :group_names => "IpGrp1&IpGrp2"})
    end
  end

  def test_enable_disable_internet_dos_defence_policy
    # 新增区域
    assert_success do
      @interface_zone.add_zone(:name => "zone225", :forward_type => "三层区域", :interfaces => "",
        :enable_webui => "是", :enable_ssh => "是", :enable_snmp => "是", :manage_address => "全部")
    end
    # 新增外网防护策略,不勾选任何防护,不启用
    assert_success do
      @dos_defence.add_internet_dos_defence_policy({:enable => "否", :name => "OUTDOS6", :description => "",
        :source_zone => "zone225", :arp_defence => "否", :arp_threshold => "5000",
        :ipscan_defence => "否", :ipscan_threshold => "4000", :portscan_defence => "否", :portscan_threshold => "4000",
        :dos_dstip_group => "全部", :icmp_defence => "否", :icmp_threshold => "2000",
        :udp_defence => "否", :udp_threshold => "100000", :syn_defence => "否", :syn_dstip_activate_threshold => "5000",
        :syn_dstip_drop_threshold => "10000", :syn_srcip_threshold => "10000", :dns_defence => "否",
        :dns_threshold => "10000", :data_packet_defence => "",
        :ip_protocol_options => "",
        :tcp_protocol_options => "",
        :record_logs => "否", :block => "否"  })
    end
    # 新增外网防护策略,不勾选任何防护,不启用
    assert_success do
      @dos_defence.add_internet_dos_defence_policy({:enable => "否", :name => "OUTDOS7", :description => "",
        :source_zone => "zone225", :arp_defence => "否", :arp_threshold => "5000",
        :ipscan_defence => "否", :ipscan_threshold => "4000", :portscan_defence => "否", :portscan_threshold => "4000",
        :dos_dstip_group => "全部", :icmp_defence => "否", :icmp_threshold => "2000",
        :udp_defence => "否", :udp_threshold => "100000", :syn_defence => "否", :syn_dstip_activate_threshold => "5000",
        :syn_dstip_drop_threshold => "10000", :syn_srcip_threshold => "10000", :dns_defence => "否",
        :dns_threshold => "10000", :data_packet_defence => "",
        :ip_protocol_options => "",
        :tcp_protocol_options => "",
        :record_logs => "否", :block => "否"  })
    end
    # 启用外网防护策略
    assert_success do
      @dos_defence.enable_disable_internet_dos_defence_policy({:names => "OUTDOS6&OUTDOS7", :operation => "启用"})
    end
    # 禁用外网防护策略
    assert_success do
      @dos_defence.enable_disable_internet_dos_defence_policy({:names => "OUTDOS6&OUTDOS7", :operation => "禁用"})
    end
    # 启用外网防护策略
    assert_success do
      @dos_defence.enable_disable_internet_dos_defence_policy({:names => "OUTDOS6&OUTDOS7", :operation => "启用"})
    end
    # 删除外网防护策略
    assert_success do
      @dos_defence.delete_internet_dos_defence_policy({:delete_type => "全部删除", :names => ""})
    end
    # 删除区域
    assert_success do
      @interface_zone.delete_zone( {:delete_type => "部分删除", :names => "zone225"})
    end
  end
end