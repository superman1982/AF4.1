#
# This file is generated by att util tool.
# by 2011-12-09 14:30:42
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'../../../../') unless $LOADED
require 'keywords/unittests/setup'

#$stdouttype = "GBK"

class TestOtherApplication < Test::Unit::TestCase
  def setup
    @other_application = LocalPc::NetworkAccess::OtherApplication.new
    
    @common = Common.new
    @advanced_netconfig = DeviceConsole::NetConfig::AdvancedNetConfig.new
    assert_success do
      @common.set_current_device( $common["login_hash"] ) # 设置正确的当前设备的IP,用户名,密码
    end
  end

=begin
  def test_exec_ping_cmd
    # ping本机
    assert_success do
      @other_application.exec_ping_cmd(:address => "127.0.0.1", :length => "")
    end
    # ping不存在的域名
    assert_fail do
      @other_application.exec_ping_cmd(:address => "www.baidu.comcomcom", :length => "")
    end
    # ping局域网内其他主机
    assert_success do
      @other_application.exec_ping_cmd(:address => "200.200.0.3", :length => "")
    end
  end

  def test_nslookup_cmd
    # 解析百度
    assert_success do
      @other_application.nslookup_cmd({:domain_name => "www.baidu.com", :domain_server => "", :domain_ip => ""})
    end
    # 解析不存在的域名
    assert_success do
      @other_application.nslookup_cmd({:domain_name => "wsdfsdfsdww.baidu.com", :domain_server => "", :domain_ip => ""})
    end
    # 解析域名,期望IP
    assert_success do
      @other_application.nslookup_cmd({:domain_name => $common["FtpDomainName"], :domain_server => $common["DNSServer"], :domain_ip => $common["FtpDomainIp"]})
    end
    # 解析域名,期望IP
    assert_hope("期望IP错误") do
      @other_application.nslookup_cmd({:domain_name => $common["FtpDomainName"], :domain_server => $common["DNSServer"], :domain_ip => $common["wFtpDomainIp"]})
    end
  end

  def test_send_udp_package
    @other_application
  end

  def test_send_tcp_package
    @other_application
  end

  def test_establish_ssh_connect
    # 与设备建立连接
    assert_success do
      @other_application.establish_ssh_connect( $common["pshell_hash"] )
    end
    # 与设备建立连接
    assert_hope("连接未建立") do
      @other_application.establish_ssh_connect( $common["pshell_hash2"] )
    end
  end

  def test_get_snmp_information_of_host
    # 启用SNMP
    assert_success do
      @advanced_netconfig.enable_disable_snmp({:operation => "启用"})
    end
    # 删除所有的snmp管理主机
    assert_success do
      @advanced_netconfig.delete_snmp_host_manager({:delete_type => "全部删除", :names => ""})
    end
    # 禁用SNMP
    assert_success do
      @advanced_netconfig.enable_disable_snmp({:operation => "禁用"})
    end
    # 获取设备的snmp信息
    assert_fail do
      @other_application.get_snmp_information_of_host({:host => $common["login_hash"][:gw_ip], :community_name => "public", :snmp_entry => "系统描述"})
    end
    # 启用SNMP
    assert_success do
      @advanced_netconfig.enable_disable_snmp({:operation => "启用"})
    end
    # 新增snmp管理主机,主机地址类型
    assert_success do
      @advanced_netconfig.add_snmp_host_manager({:name => "snmp4", :addr_type => "主机", :address => $common["LocalIP"], :community_name => "public"})
    end
    # 获取设备的snmp信息
    assert_success do
      @other_application.get_snmp_information_of_host({:host => $common["login_hash"][:gw_ip], :community_name => "public", :snmp_entry => "系统描述"})
    end
    # 删除所有的snmp管理主机
    assert_success do
      @advanced_netconfig.delete_snmp_host_manager({:delete_type => "全部删除", :names => ""})
    end
    # 禁用SNMP
    assert_success do
      @advanced_netconfig.enable_disable_snmp({:operation => "禁用"})
    end
  end

  def test_receive_udp_package_in_ruby
    # 启动接收UDP包的线程,在本机的9999端口开始接收
    assert_success do
      @other_application.start_receive_udp_package_in_ruby({:port => "9999"})
    end
    # 接收
    sleep 60
    # 停止接收UPD包
    assert_success do
      @other_application.end_receive_udp_package_in_ruby({})
    end
    # 等待接收UDP包的线程结束
    sleep 10

    # 启动接收TCP包的线程,在本机的8888端口开始接收
    assert_success do
      @other_application.start_receive_tcp_package_in_ruby({:port => "8888"})
    end
    # 接收TCP包
    sleep 100
    # 停止接收TCP包
    assert_success do
      @other_application.end_receive_tcp_package_in_ruby({})
    end
    # 等待接收TCP包的线程结束
    sleep 10
  end

  def test_establish_telnet_connect
    # 23端口
    assert_fail do
      @other_application.establish_telnet_connect({:ip => $common["FtpServer"], :port => "23", :user => "", :passwd => ""})
    end
    # pop3端口
    assert_success do
      @other_application.establish_telnet_connect({:ip => $common["FtpServer"], :port => "110", :user => "", :passwd => ""})
    end
  end

  def test_gateway_update
    #登录成功
    assert_hope("成功") do
      @other_application.gateway_update( $common["updater_login_hash"] )
    end
    #登录失败
    assert_hope("登录密码错误") do
     @other_application.gateway_update( $common["updater_login_hash2"] )
    end
    #登录失败
    assert_hope("连接失败") do
     @other_application.gateway_update( $common["updater_login_hash3"] )
    end
  end

  def test_cola_builder_send_packet
    assert_success do
      @other_application.cola_builder_send_packet({:packfile => $common["packfile"], :nic => "2", :emergent => "是",
      :loop => "是", :looptimes => "3", :loopinterval => "1000"})
    end
    assert_success do
      @other_application.cola_builder_send_packet({:packfile => $common["packfile"], :nic => "2", :emergent => "是",
      :loop => "否", :looptimes => "1", :loopinterval => "1000"})
    end
    assert_success do
      @other_application.cola_builder_send_packet({:packfile => $common["packfile"], :nic => "1", :emergent => "否",
      :loop => "否", :looptimes => "1", :loopinterval => "1000"})
    end
    
  end

  def test_windump_package
    # 在第1个网卡上抓包,带抓包选项,启动成功
    assert_success do
      @other_application.windump_package({:nic => 1, :block => "否", :options => "host 1.1.1.1", :tmpfile => "windump.txt"})
    end
    sleep 10
    # 在第1个网卡上抓包,不带抓包选项,启动成功
    assert_success do
      @other_application.windump_package({:nic => 1, :block => "否", :options => "", :tmpfile => "windump.txt"})
    end
    sleep 10
    # 在不存在的网卡上抓包,启动失败
    assert_fail do
      @other_application.windump_package({:nic => 100, :block => "否", :options => "host 1.1.1.1", :tmpfile => "windump.txt"})
    end
    sleep 10
  end
  
  def test_send_nc_packet 
    assert_success do
      @other_application.send_nc_packet({:content =>"echo -en \"\\r\\t\\f\\v a\\n(0d 0a)\"",:destip=>"200.200.84.58",:destport=>"80"})
    end
  end
  
  def test_send_aet_packet
    assert_success do
      @other_application.send_aet_packet({:ip => "200.200.88.205",:port => "80",:header => "62243.test"})
    end
    assert_fail do
      @other_application.send_aet_packet({:ip => "200.200.88.205",:port => "811",:header => "62243.test"})
    end
  end
=end
  
end