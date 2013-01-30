# coding: utf8
=begin rdoc
作用: 封装执行主机上其他网络访问的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-09              创建
=end
require 'socket'
require 'net/telnet'
require 'net/ssh'
require 'net/sftp'

require 'rubygems'
require 'att'
require 'win32/registry'

module LocalPc

  module NetworkAccess


=begin rdoc
类名: 其他
描述: 其他网络访问
=end
    class OtherApplication < ATT::Base

      include_helper "LocalPc::SystemManagement"
      
      @@udp_recev_thread = nil # 接收UDP包的线程
      @@udp_packages = []      # 存放接收到的UPD包
      @@tcp_packages = []      # 存放接收到的TCP包
      @@udp_recev_socket = nil # 接收UDP包的socket
      @@tcp_recev_thread = nil # 接收TCP包的线程
      @@tcp_server = nil       # 接收TCP包的socket
      
      @@pktbuilder_exe = nil # 科来生成器的安装路径
      @@autoit_ctl = nil       # autoit控制科来生成器
      @@shell_app = nil        # shell.application的WIN32OLE
      
=begin rdoc
关键字名: 测试ping连通
描述: 执行ping命令,ping 10个包,ping的通(丢包不大于10%)返回成功,否则返回失败
参数:
id=>address,name=>目的地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"ping的地址"
id=>length,name=>数据长度,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"ICMP包的数据长度,仅是数据,不包含包头"
id=>hope,name=>期望结果,type=>s,must=>true,default=>"",value=>"成功|失败",descrip=>"期望结果"
=end
      def exec_ping_cmd(hash)
        if hash[:length].empty?
          command = "ping #{hash[:address]} -n 10"
        else
          command = "ping #{hash[:address]} -n 10 -l #{hash[:length].to_i}"
        end
        exec_result = ATT::LocalPC.execute_cmd(command)
        ATT::KeyLog.info("执行#{command}的结果是:\n#{exec_result}")
        return_fail if exec_result =~ /could not find host|找不到主机/
        pattern = /Lost = (.*) \(/
        pattern2 = /丢失 = (.*) \(/
        num = exec_result.scan(pattern).to_s.to_i
        num2 = exec_result.scan(pattern2).to_s.to_i
        sleep 10 #增加待时间，保证结果完成
        if num >= 2 || num2 >= 2 # 大于等于2个丢包,表示ping不通
          return_fail
        else
          return_ok
        end
      end

=begin rdoc
关键字名: nslookup解析域名
描述: 执行nslookup命令,检查是否能解析域名
参数:
id=>domain_name,name=>域名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要解析的域名"
id=>domain_server,name=>DNS服务器IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"从此服务器上解析指定的域名,为空时使用本机上的默认DNS服务器"
id=>domain_ip,name=>期望IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"解析的域名,期望对应的IP地址,为空时不判断域名解析出的IP地址是否正确"
id=>hope,name=>期望结果,type=>s,must=>true,default=>"",value=>"成功|失败|期望IP错误",descrip=>"期望结果"
=end
      def nslookup_cmd(hash)
        command = "nslookup #{hash[:domain_name]} #{hash[:domain_server]}"
        exec_result = ATT::LocalPC.execute_cmd(command)
        ATT::KeyLog.info("执行#{command}的结果是:\n#{exec_result.dump}")
        if exec_result =~ /can't find|找不到/ # 无法解析
          ATT::KeyLog.error("无法解析域名,请检查域名服务器是否正确")
          return_fail
        end
        if exec_result.strip =~ /\ADNS request timed out/ && exec_result.strip =~ /timeout was 2 seconds.\Z/# 被应用控制策略拒绝
          ATT::KeyLog.error("DNS解析失败,请检查是否被应用控制策略拒绝")
          return_fail
        end
        unless hash[:domain_ip].to_s.empty?
          domain_name = hash[:domain_name]
          domain_ip = hash[:domain_ip]
          part_hope_text = "    #{domain_name}\nAddress:  #{domain_ip}"
          if !exec_result.include?("名称:#{part_hope_text}") && !exec_result.include?("Name:#{part_hope_text}")
            return_fail("期望IP错误")
          end
        end
        return_ok
      end



=begin
关键字名: 启动RUBY接收UDP包
描述: 在执行PC上的指定端口启动接收UPD包
参数:
id=>port,name=>接收端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"接收UDP包的端口"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def start_receive_udp_package_in_ruby(hash)
      @@udp_packages = [] # 清空之前收到的所有UDP包
      rece_port = hash[:port].to_i
      ATT::KeyLog.info("开始在端口#{rece_port}接收UDP包...")
      @@udp_recev_thread = Thread.new do
        @@udp_recev_socket = UDPSocket.new
        @@udp_recev_socket.bind("0.0.0.0", rece_port)
        loop do
          msg, sender = @@udp_recev_socket.recvfrom(100)
          host = sender[3]
          ATT::KeyLog.info("#{Time.now}: 从#{host}收到UDP包:#{msg}")
          @@udp_packages << msg
        end
      end
      return_ok
    end
      
=begin
关键字名: RUBY发送UDP包
描述: 用ruby中的socket发送指定数目的UDP包
参数:
id=>dip,name=>目的IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"发包到的目的ip"
id=>port,name=>目的端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"发包到的目的端口"
id=>content,name=>内容,type=>s,must=>false,default=>"one udp package",value=>"{text}",descrip=>"发包的内容,默认是:'one udp package'"
id=>packages,name=>包数,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"发包的数目,默认是10个"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def send_udp_package_in_ruby(hash)
      dest_ip = hash[:dip]
      dest_port = hash[:port].to_i
      ATT::KeyLog.info("往#{dest_ip}的#{dest_port}端口发送#{hash[:packages]}个UDP包...")
      socket = UDPSocket.new
      socket.connect("#{dest_ip}", dest_port)
      1.upto(hash[:packages].to_i) do
        socket.print(hash[:content])
      end
      sleep 10 #增加待时间，保证结果完成
      socket.close
      return_ok
    end
      
=begin
关键字名: 结束RUBY接收UDP包
描述:
参数:
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def end_receive_udp_package_in_ruby(hash)
      ATT::KeyLog.info("收到结束接收UDP包的信号...")
      if @@udp_recev_thread.nil?
        ATT::KeyLog.info("尚未启动接收UDP包的线程...")
        return_ok # return_fail("未启动接收")
      end
      if @@udp_recev_thread.alive?
        @@udp_recev_socket.close # 关闭接收UPD包的端口,以便下次使用
        @@udp_recev_thread.kill
        @@udp_recev_thread = nil
      end
    end
      
=begin
关键字名: 检查RUBY接收UDP包
描述: 在执行PC上,检查自从启动RUBY接收UDP包开始,到当前时间有没有接收到UDP包
参数:
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|未收到包|已收到包",descrip=>"期望结果"
=end
    def check_udp_package_received_in_ruby(hash)
      sleep 20 # 稍等下,等待发送的包都已被接收
      if @@udp_packages.empty?
        return_fail("未收到包")
      else
        ATT::KeyLog.info("已经接收到了#{@@udp_packages.size}个UDP包...")
        return_ok("已收到包")
      end
    end
      
=begin
关键字名: 启动RUBY接收TCP包
描述: 在执行PC上的指定端口启动接收TCP包
参数:
id=>port,name=>接收端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"接收TCP包的端口"
id=>reply_content,name=>回复内容,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"接收到每一个TCP包后要回复的内容"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def start_receive_tcp_package_in_ruby(hash)
      @@tcp_packages = [] # 清空之前接收到的TCP包,方便存放本次接收的数据包
      rece_port = hash[:port].to_i
      ATT::KeyLog.info("开始在端口#{rece_port}接收TCP包...")
      Thread.abort_on_exception = true
      begin
        @@tcp_recev_thread = Thread.new do # 服务端接收TCP包的线程
          @@tcp_server = TCPServer.new("0.0.0.0", rece_port) # 打开接收端口
          while(session = @@tcp_server.accept) # 等到一个tcp连接
            while(msg = session.gets )  #recv(100) # 接收数据包
              ATT::KeyLog.info("#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: 收到TCP包:#{msg}")
              unless hash[:reply_content].empty?
                session.puts("#{hash[:reply_content]}") # 回复数据包给客户端
                ATT::KeyLog.info("#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: 回复数据包:#{hash[:reply_content]}")
              end
              @@tcp_packages << msg
            end
            session.close
          end
        end
      rescue Exception
        ATT::KeyLog.error("发生异常:#{$!.class}/#{$!.message}")
        ATT::KeyLog.error("发生异常:#{$!.backtrace.join("\n")}")
      end
      return_ok
    end
      
=begin
关键字名: RUBY发送TCP包
描述: 用ruby中的socket发送指定数目的TCP包
参数:
id=>dip,name=>目的IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"发包到的目的ip"
id=>port,name=>目的端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"发包到的目的端口"
id=>content,name=>内容,type=>s,must=>false,default=>"one tcp package",value=>"{text}",descrip=>"发包的内容,默认是:'one tcp package'"
id=>packages,name=>包数,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"发包的数目,默认是10个"
id=>reply_hoped,name=>期望回复内容,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"客户端每发送一个TCP包,服务端收到后回复的内容"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def send_tcp_package_in_ruby(hash)
      dest_ip = hash[:dip]
      dest_port = hash[:port].to_i
      ATT::KeyLog.info("往#{dest_ip}的#{dest_port}端口发送#{hash[:packages]}个TCP包...")
      begin
        tcp_socket = TCPSocket.open("#{dest_ip}", dest_port) # 发起TCP连接
      rescue Exception
        ATT::KeyLog.error("发生异常:#{$!.class},#{$!.message}...")
        return_fail
      end
      return_ok if hash[:content] == ""
      send_count = 0
      1.upto(hash[:packages].to_i) do
        content = hash[:content].gsub(/\\r/, "\r").gsub(/\\t/, "\t").gsub(/\\n/, "\n").gsub(/\\f/, "\f").gsub(/\\v/, "\v")
        ATT::KeyLog.debug("send: " + content.dump)
        ATT::KeyLog.debug("send: " + content)
        tcp_socket.puts(content) # 发送TCP包
        send_count += 1
        ATT::KeyLog.debug("目前已发送:#{send_count}个数据包")
        sleep 1
        unless hash[:reply_hoped].empty?
          reply_content = tcp_socket.gets # 接收回复包
          ATT::KeyLog.info("#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}: 收到回复包:#{reply_content}")
          unless hash[:reply_hoped] == reply_content.to_s.strip
            ATT::KeyLog.error("期望服务端回复内容:#{hash[:reply_hoped].dump},服务端实际回复内容:#{reply_content.dump}")
            return_fail
          end
        end
      end
      sleep 10 #增加待时间，保证结果完成
      tcp_socket.close # 关闭本次连接
      return_ok
    end
      
=begin
关键字名: 结束RUBY接收TCP包
描述:
参数:
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def end_receive_tcp_package_in_ruby(hash)
      ATT::KeyLog.info("收到结束接收TCP包的信号...")
      if @@tcp_recev_thread.nil?
        ATT::KeyLog.info("尚未启动接收TCP包的线程...")
        return_ok
      end
      ATT::KeyLog.debug("服务端接收线程alive?:#{@@tcp_recev_thread.alive?}")
      if !@@tcp_server.nil? && !@@tcp_server.closed?
        ATT::KeyLog.debug("关闭服务端监听端口....")
        @@tcp_server.close # 关闭接收TCP包的端口
        @@tcp_server = nil
      end
      if @@tcp_recev_thread.alive?
        @@tcp_recev_thread.kill
        @@tcp_recev_thread = nil
      end
    end
      
=begin
关键字名: 检查RUBY接收TCP包
描述: 在执行PC上,检查自从启动RUBY接收TCP包开始,到当前时间有没有接收到TCP包,或者检查接收的数据包是否含期望内容
参数:
id=>content,name=>期望内容,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望接收到的数据包的内容,为空时仅检查有无收到TCP包,不为空时才检查数据包的内容"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|未收到包|已收到包",descrip=>"期望结果"
=end
    def check_tcp_package_received_in_ruby(hash)
      sleep 20 # 稍等下,等待发送的包都已被接收
      if @@tcp_packages.empty?
        return_fail("未收到包")
      else
        ATT::KeyLog.info("已经接收到了#{@@tcp_packages.size}个TCP包...")
        if hash[:content].empty? # 期望内容的空
          return_ok("已收到包")
        else
          @@tcp_packages.each do |package|
            if package.include?(hash[:content])
              return_ok
            end
          end
          ATT::KeyLog.error("期望内容是:#{hash[:content]},实际已接收的内容:#{@@tcp_packages.join("\n")}")
          return_fail
        end
      end
    end
      
=begin
关键字名: 发送UDP包
描述: 用newClient.exe发送udp包
参数:
id=>dip,name=>目的IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"发包目的ip"
id=>port,name=>目的端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"发包目的端口"
id=>size,name=>包大小,type=>s,must=>false,default=>"1400",value=>"{text}",descrip=>"包大小,单位字节"
id=>interval,name=>间隔,type=>s,must=>false,default=>"1000",value=>"{text}",descrip=>"间隔,单位毫秒"
id=>count,name=>次数,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"次数,间隔时间内的发包次数"
id=>fastest,name=>是否最快,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否最快"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def send_udp_package(hash)
    end

=begin rdoc
关键字名: 发送TCP包
描述: 用tcpclient发送tcp包
参数:
id=>dip,name=>目的IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"发包目的ip"
id=>port,name=>目的端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"发包目的端口"
id=>size,name=>包大小,type=>s,must=>false,default=>"1400",value=>"{text}",descrip=>"包大小,单位字节"
id=>fastest,name=>是否最快,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否最快速度发包"
id=>interval,name=>间隔,type=>s,must=>false,default=>"1000",value=>"{text}",descrip=>"发包间隔,单位毫秒"
id=>count,name=>次数,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"发包次数,间隔时间内的发包次数"
id=>file,name=>数据位置,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"数据文件位置,放在temp目录"
id=>close,name=>完成关闭,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"完成后是否关闭tcpclient"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def send_tcp_package(hash)
    end

=begin rdoc
关键字名: 建立SSH连接
描述: PC与设备建立ssh连接
参数:
id=>host,name=>目的IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"与该地址建立SSH连接"
id=>port,name=>端口号,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"建立SSH连接的端口号"
id=>user,name=>用户名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"建立SSH连接使用的用户"
id=>passwd,name=>密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"建立SSH连接使用的密码"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|连接未建立",descrip=>"期望结果"
=end
    def establish_ssh_connect(hash)
      ATT::KeyLog.info("用户名/密码:#{hash[:user]}/#{hash[:passwd]}连接#{hash[:host]}:#{hash[:port]}")
      begin
        ssh_connect = Net::SSH.start(hash[:host], hash[:user], {:password => hash[:passwd], :port => hash[:port].to_i})
        ATT::Logger.info("连接建立#{ssh_connect}")
      rescue Exception
        ATT::Logger.error("发生异常:#{$!.class},#{$!.message}")
        return_fail("连接未建立")
      end
      return_ok
    end
      
=begin rdoc
关键字名: 获取主机SNMP信息
描述: 获取PC或设备的SNMP信息
参数:
id=>host,name=>目的IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要获取该IP主机的SNMP信息"
id=>community_name,name=>团体名,type=>s,must=>false,default=>"public",value=>"{text}",descrip=>"团体名,默认是public"
id=>snmp_entry,name=>SNMP信息,type=>s,must=>false,default=>"系统描述",value=>"系统描述|系统对象ID|系统开机时间|系统授权|系统名称|系统所处位置|系统业务内容",descrip=>"获取主机的哪个snmp信息,默认是主机的系统描述"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def get_snmp_information_of_host(hash)
      ATT::KeyLog.info("get snmp information of host #{hash[:host]}")
      oid = get_snmp_oid( hash[:snmp_entry] )
      snmputil_bin_path = File.join(ATT::ConfigureManager.root, "bin", "snmputil.exe")
      command = "#{snmputil_bin_path} get #{hash[:host]} #{hash[:community_name]} #{oid}"
      snmputil_result = `#{command}`
      if snmputil_result !~ /Variable =/ && snmputil_result !~ /Value    =/
        ATT::KeyLog.error("获取snmp信息失败,错误信息是:#{snmputil_result}")
        return_fail
      else
        ATT::KeyLog.error("获取snmp信息成功,返回信息是:#{snmputil_result}")
        return_ok
      end
    end
      
=begin rdoc
关键字名: 建立TELNET连接
描述: telnet到某个主机的某个端口,必要时使用用户名密码
参数:
id=>ip,name=>目的地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"目的ip地址"
id=>port,name=>端口,type=>s,must=>false,default=>"23",value=>"{text}",descrip=>"端口,默认是23"
id=>user,name=>用户名,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"用户名,可为空"
id=>passwd,name=>密码,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"密码,可为空"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"",value=>"成功|失败",descrip=>"期望结果"
=end
    def establish_telnet_connect(hash)
      telnet_result = false
      if hash[:user].to_s.empty?
        begin
          conn = Net::Telnet::new("Host" => hash[:ip],"Port" => hash[:port].to_i)
          telnet_result = true
        rescue
          ATT::KeyLog.info("发生异常:#{$!.class},#{$!.message}")
        ensure
          conn.close if conn
        end
      else
        begin
          conn = Net::Telnet::new("Host" => hash[:ip],"Port" => hash[:port].to_i)
          login_res = conn.login(hash[:user],hash[:passwd])
          ATT::KeyLog.info(login_res)
          telnet_result = true
        rescue
          ATT::KeyLog.info("发生异常:#{$!.class},#{$!.message}")
        ensure
          conn.close if conn
        end
      end
      if telnet_result
        return_ok
      else
        return_fail
      end
    end
      
=begin rdoc
关键字名: 登陆认证窗口
描述: 用来处理登陆认证过程中的各种情况
参数:
id=>authweb,name=>authweb,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"认证页面的IP地址,如192.168.101.1,后缀/webAuth将被自动添加"
id=>username,name=>username,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"用户名"
id=>passwd,name=>password,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"密码"
id=>expect_context,name=>期望页面内容,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"在认证返回页面种要获取的信息"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果,默认成功"
=end
    def login_authd_webpage(hash)
      auth_result_html = input_user_and_passwd( hash )
      ATT::KeyLog.info("整个页面为:#{auth_result_html}")
      if auth_result_html.include?(hash[:expect_context])
        return_ok("成功")
      end
      ATT::KeyLog.info("认证后返回的页面不包含期望内容:#{hash[:expect_context]}")
      return_fail("失败")
    end

=begin rdoc
关键字名: 连接网关升级客户端
描述: 打开升级客户端工具,输入网关和密码,进行连接
参数:
id=>host,name=>网关IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>""
id=>dlanpasswd,name=>登录密码,type=>s,must=>false,default=>"",value=>"{text}",descrip=>""
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|登录失败|登录密码错误|连接失败|打开升级客户端超时",descrip=>""
=end
    def gateway_update( hash )
      autoit = WIN32OLE.new("autoitx3.control")
      title = "SANGFOR"
      system("tskill dlanupdater 2> NUL") and sleep 5 if autoit.WinExists(title)
      shell = WIN32OLE.new("shell.application")
      dlanupdater_exe = File.expand_path(File.join(ATT::ConfigureManager.root, "bin","dlanupdater.exe" ))
      shell.ShellExecute("#{dlanupdater_exe}", '', '', 'open', 1)
      return_fail "打开升级客户端超时" if autoit.WinWait(title, "" , 15) == 0
      Timeout.timeout(60) do
        catch(:login_ok) do
          autoit.WinActivate(title)
          autoit.WinMenuSelectItem(title,"","系统","直接连接")
          autoit.WinActivate("连接")
          sleep 1
          autoit.ControlSetText("连接","","Edit1",hash[:host])
          sleep 1
          autoit.ControlSetText("连接","","Edit2", hash[:dlanpasswd])
          sleep 1
          autoit.ControlClick("连接","","Button1")
          sleep 1
          loop do
            msg = autoit.ControlGetText(title,"","RICHEDIT1")
            ATT::KeyLog.info("工具上的显示信息是:#{msg}")
            if msg.include?("登录密码错误")
              sleep 10
              autoit.WinClose(title) # 关闭dlan工具
              return_fail "登录密码错误"
            elsif msg.include?("无法连接网关")
              sleep 10
              autoit.WinClose(title) # 关闭dlan工具
              return_fail("连接失败")
            elsif msg.include?("登录成功")
              throw :login_ok
            end
            sleep 1
          end
        end
      end
      msg  = autoit.ControlGetText(title,"","RICHEDIT1")
      unless msg.include?("登录成功")
        autoit.WinClose(title) # 关闭dlan工具
        ATT::KeyLog.info("登录失败,工具上的显示信息是:#{msg}")
        return_fail "登录失败"
      end
      autoit.WinClose(title) # 关闭dlan工具
    end

=begin rdoc
关键字名: 建立拨号连接
描述: 建立拨号连接,前提是PC上已经手动创建了宽带连接
参数:
id=>connection,name=>连接名称,type=>s,must=>true,default=>"",value=>"#{text}",descrip=>"在执行主机上配置的宽带连接的名称"
id=>user,name=>用户名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要登录的用户"
id=>password,name=>密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要登录的密码"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"连接成功",value=>"连接成功|连接失败",descrip=>"期望结果"
=end
    def establish_adsl_connection(hash)
      ATT::KeyLog.info("pc establish adsl connection...")
      # 使用拨号命令行工具进行拨号
      exec_result = connect_adsl(hash[:connection] ,hash[:user], hash[:password] )
      ATT::KeyLog.info("首次连接的结果是:\n#{exec_result}")
      if exec_result =~ /命令已完成/
        return_ok("连接成功")
      else
        ATT::KeyLog.debug("再次尝试连接...")
        exec_result = connect_adsl(hash[:connection] ,hash[:user], hash[:password] )
        ATT::KeyLog.info("再次连接的结果是:\n#{exec_result}")
        return_fail("连接失败") unless exec_result =~ /命令已完成/
      end
    end

=begin rdoc
关键字名: 断开拨号连接
描述: 断开PC上已经拨号成功的连接
参数:
id=>connection,name=>连接名称,type=>s,must=>true,default=>"",value=>"#{text}",descrip=>"在执行主机上配置的宽带连接的名称"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def disconnect_adsl_connection(hash)
      ATT::KeyLog.info("pc disconnect adsl connection...")
      # 关闭拨号连接
      result = disconnect_adsl(hash[:connection])
      ATT::KeyLog.info("断开连接的结果是:\n#{result}")
      if result =~ /命令已完成/
        return_ok("成功")
      else
        return_fail("失败")
      end
    end

=begin rdoc
关键字名: 科来生成器发包
描述: 使用科来生成器发包
维护人: gsj
参数:
id=>packfile,name=>数据包文件,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要发送的数据包文件的名称,位于项目根目录下的data_packages目录内"
id=>nic,name=>网卡,type=>s,must=>false,default=>"2",value=>"2|3|4|5|6|{text}",descrip=>"科来生成器窗口的网卡列表中,用来发包的网卡的序号,默认是第2个"
id=>emergent,name=>突发模式,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选突发模式,默认不勾选"
id=>loop,name=>循环发送,type=>s,must=>false,default=>"否",value=>"是|否|{text}",descrip=>"是否勾选循环发送,默认不勾选"
id=>looptimes,name=>循环次数,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"勾选循环发送时,循环发送的次数"
id=>loopinterval,name=>循环间延迟,type=>s,must=>false,default=>"1000",value=>"{text}",descrip=>"勾选循环发送时,循环间的延迟,单位是毫秒"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def cola_builder_send_packet(hash)
      @@pktbuilder_exe = get_pktbuilder_path_from_registry() if @@pktbuilder_exe.nil? # 从注册表中获取科来生成器的安装路径
      @@autoit_ctl = WIN32OLE.new("autoitx3.control") if @@autoit_ctl.nil?
      @@shell_app = WIN32OLE.new("shell.application") if @@shell_app.nil?
      packet_file_path = packet_file_with_path( hash[:packfile] )

      start_pktbuilder(@@autoit_ctl, @@pktbuilder_exe, @@shell_app) # 启动科来数据包生成器
      delete_old_and_import_specified_file(@@autoit_ctl, packet_file_path) # 删除原来的所有数据包,并打开指定的数据包文件

      select_net_adapter(@@autoit_ctl, hash[:nic]) # 选择默认网卡

      #@@autoit_ctl.ControlClick(PKTBUILDER_TITLE, "", TOOL_BAR, "left", 1, 495, 25) # 点击工具栏上的'发送全部'
      @@autoit_ctl.ControlClick(PKTBUILDER_TITLE, "", MENU_BAR, "left", 1, 100, 10) # 点击菜单栏上的'发送'
      @@autoit_ctl.Send("+a") # 发送全部数据包
      set_emergent_mode(@@autoit_ctl, hash[:emergent]) # 设置突发模式
      set_loop_send_options(@@autoit_ctl, hash[:loop], hash[:looptimes], hash[:loopinterval]) # 设置循环发送选项
      retry_times = 0
      @@autoit_ctl.ControlFocus(SEND_ALL_PACKAGES_TITLE, "", START_BUTTON)
      sleep 2
      click_start_result = @@autoit_ctl.ControlClick(SEND_ALL_PACKAGES_TITLE, "", START_BUTTON) # 点击开始发送数据包
      while retry_times <= 3 && click_start_result.to_s != "1"
        @@autoit_ctl.ControlFocus(SEND_ALL_PACKAGES_TITLE, "", START_BUTTON)
        sleep 2
        click_start_result = @@autoit_ctl.ControlClick(SEND_ALL_PACKAGES_TITLE, "", START_BUTTON) # 点击开始发送数据包
      end
      if retry_times > 3 && click_start_result.to_s != "1"
        ATT::KeyLog.error("连续3次重试点击开始按钮均失败")
        return_fail
      end
    
      total_count = total_count_to_be_sent(@@autoit_ctl) # 在窗口上获取要发送的数据包个数
      while true
        count_sended = @@autoit_ctl.ControlGetText(SEND_ALL_PACKAGES_TITLE, "", PACKAGES_SENDED_COUNT) # 已发送数据包数
        ATT::KeyLog.debug(count_sended)
        if count_sended == total_count # 发送结束了
          sleep 1
          @@autoit_ctl.ControlFocus(SEND_ALL_PACKAGES_TITLE, "", CLOSE_BUTTON)
          @@autoit_ctl.ControlClick(SEND_ALL_PACKAGES_TITLE, "", CLOSE_BUTTON)
          break
        else
          sleep 1 # 每1秒检查一次是否已经发送完毕
        end
      end
      @@autoit_ctl.WinKill(PKTBUILDER_TITLE, "") # 关闭科来生成器
      return_ok
    end

=begin rdoc
关键字名: WinDump抓包
描述: 使用WinDump(前提是安装了WinPcap包)命令进行抓包,抓包的内容存入某个文件,以备检查,返回文件的全路径
参数:
id=>nic,name=>网卡编号,type=>s,must=>false,default=>"2",value=>"{text}",descrip=>"在哪个网卡上进行抓包,默认在第2个网卡上"
id=>block,name=>阻塞,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否以阻塞执行的形式执行WinDump命令,默认是非阻塞"
id=>options,name=>抓包选项,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"执行WinDump命令的选项,不包括-i选项"
id=>tmpfile,name=>存入文件,type=>s,must=>false,default=>"windump.txt",value=>"{text}",descrip=>"抓包的内容保存到的文件,位于tmp目录下,默认是windump.txt"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def windump_package( hash )
      kill_windump_processes_existed() # 检查是否已经有WinDump.exe进程存在,若有则全部杀掉
      windump_exe = Pathname.new(File.join(ATT::ConfigureManager.root, "bin", WINDUMP_PROCESS)).realpath.to_s
      tmpfile = Pathname.new(File.join(ATT::ConfigureManager.root, "temp", "#{hash[:tmpfile]}")).realpath.to_s
      windump_command = "#{windump_exe} -i #{hash[:nic]} -n -l > #{tmpfile} #{hash[:options]}\""

      ATT::KeyLog.debug("启动WinDump抓包的命令是:#{windump_command}")
      # 先启动windump,然后检查WinDump.exe有没有启动
      if hash[:block] == "是"
        result = ATT::LocalPC.execute_cmd(windump_command)
      else
        Thread.new do
          result = system(windump_command) # 用线程,非组塑启动WinDump.exe
        end
      end
      sleep 2 # 稍等
      pid_array = find_pid_of_specified_process( WINDUMP_PROCESS ) # 返回指定名称的进程所有进程ID
      if pid_array.empty? # WinDump.exe没有启动
        ATT::KeyLog.debug("#{WINDUMP_PROCESS}进程启动失败,result=#{result}")
        return_fail
      else
        ATT::KeyLog.info("#{WINDUMP_PROCESS}进程启动成功,result=#{result}")
        return [ tmpfile.gsub(/:/, "\:") ]
      end
    end
    
=begin
关键字名:使用nc发送数据包
描述: 使用nc.exe发送数据包
参数:
id=>content,name=>发送内容,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"nc工具发送内容，注意，请默认增加上(0d 0a),需要整个echo语句,如echo -ne \"\r\t\f\v a\n(0d 0a)\""
id=>destip,name=>目的IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"接收端的IP地址"
id=>destport,name=>目的端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"客户端接收包的端口"
id=>timeout,name=>超时时间,type=>s,must=>false,default=>"30",value=>"{text}",descrip=>"nc发包的时间，最长不超过多少秒，默认30s,超过就干掉nc并返回失败"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def send_nc_packet(hash)
      nc_path = obtain_filepath(obtain_att_directory("bin"),"nc.exe")
      send_command = hash[:content].gsub("\\r","\r")
      send_command = send_command.gsub("\\n","\n")
      send_command = send_command.gsub("\\f","\f")
      send_command = send_command.gsub("\\t","\t")
      send_command = send_command.gsub("\\v","\v")
      command = "#{send_command}|#{nc_path} #{hash[:destip]} #{hash[:destport]}"
      log "The command dump is #{command.dump}"
      log "The command is #{command}"
      Thread.new do
        system(command)
      end
      wait_send_packet(hash[:timeout].to_i)
      nc_arr = find_pid_of_specified_process("nc.exe")
      if nc_arr.empty?
        return_ok
      else
        nc_arr.each do |pid|
          system("tskill #{pid}")
        end
        log "The nc.exe can't quit.Please check the nc command:#{command}."
        return_fail
        #raise StandardError,"The nc.exe can't quit.Please check the nc command:#{command}."
      end
    end

=begin
关键字名:AET请求
描述: 使用AET工具发送请求数据包
参数:
id=>ip,name=>目的IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"服务器的IP地址"
id=>port,name=>目的端口,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器的IP端口号"
id=>header,name=>请求文件,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"指定请求头部文件名,文件路径必须处于aet_packages目录下"
id=>timeout,name=>超时时间,type=>s,must=>false,default=>"30",value=>"{text}",descrip=>"发包的时间，最长不超过多少秒，默认30s,超过返回失败"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def send_aet_packet(hash)
      aet_path = obtain_filepath(obtain_att_directory("aet_packages"),hash[:header])
      puts aet_path
      f = File.open(aet_path,"rb")
      request = f.read
      ATT::KeyLog.info("\n====================\n请求头部内容：\n#{request}\n==============================")
      # puts request.dump
      begin
        socket = TCPSocket.open(hash[:ip],hash[:port])
        # socket = OpenSSL::SSL::SSLSocket.new(TCPSocket.new(hash[:ip],'443'))
        # socket.sync_close = false
        # socket.connect
      rescue
        ATT::KeyLog.info("error: #{$!}")
        return_fail("访问失败")
      else
        begin
          socket.print(request)
          headers=socket.gets("\r\n\r\n")
        rescue Exception => e
          ATT::KeyLog.info("error: #{$!}"+"\n堆栈：\n#{e.backtrace}")
          return_fail
        end
        socket.close
      end
      ATT::KeyLog.info("\n====================\n服务器响应结果:\n#{headers}\n==============================")
      return_ok
      socket.close
    end
    
    
    
  end
end
end
