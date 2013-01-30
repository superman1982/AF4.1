=begin
作用: FTP操作
描述: 封装常用的FTP操作
平台: ruby1.8.6/windows
作者: gsj
更新记录:
     日期             更新人          行为
     2010.11.17      gsj            创建脚本
=end
require 'att'
require 'rubygems'
require 'net/ssh'
require 'net/sftp'

module ATT
=begin rdoc
描述: 封装测试设备的一些操作,如连接设备后台,执行命令,替换后台文件,返回设备型号/IP/mac等
=end
  class TestDevice
    private
    # dlan网关升级系统的位置
    @@lib_bin_path = Pathname.new(File.join(File.dirname(__FILE__),'..',"lib_bin")).realpath
=begin rdoc
描述: 在配置文件种读取第一台设备的配置
=end
    def self.get_default_config(device_config_array)
      tmp_hash = device_config_array[0] # 第一个配置
      #tmp_name = tmp_hash.keys[0] # 第一个设备的名称
      type = tmp_hash['type']
      host = tmp_hash['host']
      port = tmp_hash['port']
      user = tmp_hash['user']
      passwd = tmp_hash['passwd']
      dlancommand = tmp_hash['dlancommand']
      dlanpasswd = tmp_hash['dlanpasswd']
      comm = tmp_hash['comm']
      ATT::Logger.info("没有指定测试设备名称,默认使用第一个配置")
      ATT::Logger.soft(type, host, port, user, passwd, dlancommand, dlanpasswd, comm)
      return [type, [host, port, user, passwd, dlancommand, dlanpasswd, comm]]
    end
=begin rdoc
描述: 根据设备名称,在配置文件的所有设备中获取配置
=end
    def self.get_named_config(device_config_array, name)
      device_config_array.each do |device|
        #if device.has_key?(name)
        if device['name'] == name.strip
          type = device['type']
          host = device['host']
          port = device['port']
          user = device['user']
          passwd = device['passwd']
          dlancommand = device['dlancommand']
          dlanpasswd = device['dlanpasswd']
          comm = device['comm']
          ATT::Logger.info("在配置文件中找到了名称是 #{name} 的测试设备")
          ATT::Logger.soft(type, host, port, user, passwd, dlancommand, dlanpasswd, comm)
          return [type, [host, port, user, passwd, dlancommand, dlanpasswd, comm]]
        end
      end
      raise ATT::Exceptions::NotFoundError,"配置文件中没有名称是 #{name} 的设备"
    end
=begin rdoc
描述: 根据设备名称,从配置文件的设备数组中获取配置
=end
    def self.get_concrete_config(name, device_config_array)
      ATT::Logger.info("配置文件中共有 #{device_config_array.size} 台设备的配置")
      device_config_array.each do |device|
        ATT::Logger.info("测试设备名称 #{device['name']}")
      end
      return get_default_config(device_config_array) if name.nil?  # 如果name是空,则默认使用第一个配置
      return get_named_config(device_config_array, name)
    end

    def check_connector_closed?()
      return true if @connector.closed?
      return false
      @sftp_connector.close_channel if @sftp_connector.closed?
    end
    def check_sftp_connector_closed?()
      return true if @sftp_connector.closed?
      return false
    end
    def config_str_to_array(network_config)
      config_array = []
      tmp_config = ""
      network_config.each_line do |line|
        tmp_config << line unless line.strip == ""
        if line.strip == ""
          config_array << tmp_config
          tmp_config = ""
        end
      end
      return config_array
    end
    
    public
=begin rdoc
描述: 从配置文件读取设备的具体配置
参数: name => 测试设备名称,如果为空,则默认是配置文件的第一个配置
返回值: [产品线,[host, port, user, passwd, dlancommand, dlanpasswd, comm]]
=end
    def self.get_config(name)
      device_config = ConfigureManager.get("test_device.yml")
      devices = device_config["testdevice"]
      config = get_concrete_config(name, devices)
      return config
    end
=begin rdoc
作用: 与后台设备建立连接
描述: 与后台设备建立连接,获取connector,以执行命令等
参数: name => 测试设备的标识
=end
    def initialize(name = nil)
      test_device_config = ATT::TestDevice.get_config(name)
      type = test_device_config[0].to_s
      host = test_device_config[1][0].to_s
      port = test_device_config[1][1].to_i
      user = test_device_config[1][2].to_s
      passwd = test_device_config[1][3].to_s
      dlancommand = test_device_config[1][4].to_s
      dlanpasswd = test_device_config[1][5].to_s
      comm = test_device_config[1][6].to_s
      ATT::Logger.soft(host, port, user, passwd, dlancommand, dlanpasswd, comm)
      begin
        Timeout.timeout(300) do
          @connector = Net::SSH.start(host, user, {:password => passwd, :port => port})
          ATT::Logger.info("初次连接建立#{@connector}")
          @sftp_connector = Net::SFTP.start(host, user, {:password => passwd, :port => port})
          ATT::Logger.info("初次连接建立#{@sftp_connector}")
          return
        end
      rescue Exception
        ATT::Logger.info("初次连接失败,异常是#{$!.class},异常消息是#{$!.message}")
        10.times do
          if type =~ /ssl/i
            ATT::Logger.soft($!.class, $!.to_s)
            try_open_port(host, dlancommand, dlanpasswd, comm)
          else
            ATT::Logger.info("等待,稍候重试连接......")
            sleep 20 # 等待20秒后再重试
          end
          begin
            Timeout.timeout(300) do
              @connector = Net::SSH.start(host, user, {:password => passwd, :port => port})
              ATT::Logger.info("重试连接建立#{@connector}")
              @sftp_connector = Net::SFTP.start(host, user, {:password => passwd, :port => port})
              ATT::Logger.info("重试连接建立#{@sftp_connector}")
              return
            end
          rescue Exception
            ATT::Logger.info("重试连接异常是#{$!.class},重试连接异常消息是#{$!.message}")
          end
        end
      end
      raise ATT::Exceptions::NotFoundError,"连接未建立"
    end
=begin rdoc
描述: 关闭与设备后台的连接
=end
    def close()
      @connector.close unless @connector.closed?
      @sftp_connector.close_channel unless @sftp_connector.closed?
    end
    
=begin rdoc
作用: 在设备后台执行命令
描述: 与设备建立连接后,执行指定的命令
参数: command => 要执行的命令,如"ls -l"
返回值: [返回值, 执行结果字符串],如执行"ls -l",返回["0", 目录],0表示执行成功
=end
    def exec_command(command)
      raise ATT::Exceptions::NotFoundError,"请先使用TestDevice.new()建立ssh连接" unless @connector
      raise ATT::Exceptions::NotFoundError,"ssh连接超时断开,请重新使用TestDevice.new()建立连接" if check_connector_closed?
      result = @connector.exec!(command)
      value = @connector.exec!("echo $?").strip
      ATT::Logger.info("执行命令#{command}的输出结果是: #{result.dump}") unless result.nil?
      ATT::Logger.info("执行命令#{command}的返回值是: #{value.dump}")
      return [value, result]
    end
=begin rdoc
作用: 在设备后台执行命令,不等待命令执行完毕直接返回
描述: 与设备建立连接后,执行指定的命令
参数: command => 要执行的命令,如"ls -l"
返回值: [返回值, 执行结果字符串],如执行"ls -l",返回["0", 目录],0表示执行成功
=end
    def exec_command_nowait(command)
      raise ATT::Exceptions::NotFoundError,"请先使用TestDevice.new()建立ssh连接" unless @connector
      raise ATT::Exceptions::NotFoundError,"ssh连接超时断开,请重新使用TestDevice.new()建立连接" if check_connector_closed?
      result = @connector.exec(command) # 返回channel
      value = @connector.exec!("echo $?").strip
      ATT::Logger.info("执行命令#{command}的返回值是: #{value.dump}")
      return [value, result]
    end
=begin rdoc
作用: 上传文件到设备后台
描述: 与设备建立连接后,上传文件到设备后台
参数: localfile => 本地文件,如"D:/tmp/tmp.txt"
     dest_dir => 目的路径,如"/root","/etc"
     file => 目的文件名
返回值: true/异常
     目的路径不存在时,抛出ATT::Exceptions::SftpStatusError
     其他情况,抛出ATT::Exceptions::SftpUnknownError
=end
    def upload(localfile, dest_dir = "/root", file = nil)
      raise ATT::Exceptions::NotFoundError,"请先使用TestDevice.new()建立sftp连接" unless @sftp_connector
      raise ATT::Exceptions::NotFoundError,"sftp连接超时断开,请重新使用TestDevice.new()建立连接" if check_sftp_connector_closed?
      raise ATT::Exceptions::NotFoundError,"本地文件不存在" unless File.exist?(localfile)
      if file.nil?      
        file_name = File.basename(localfile)
      else
        file_name = file
      end
      ATT::Logger.info("要上传的文件名称是: #{file_name}")
      begin
        @sftp_connector.upload!(localfile, dest_dir + "/#{file_name}") do |event, uploader, *args|
          case event
          when :open # args[0] : file metadata
            ATT::Logger.info("starting upload: #{args[0].local} -> #{args[0].remote} (#{args[0].size} bytes}")
          when :put
            # args[0] : file metadata
            # args[1] : byte offset in remote file
            # args[2] : data being written (as string)
            ATT::Logger.info("writing #{args[2].length} bytes to #{args[0].remote} starting at #{args[1]}")
          when :close # args[0] : file metadata
            ATT::Logger.info("finished with #{args[0].remote}")
          when :mkdir # args[0] : remote path name
            ATT::Logger.info("creating directory #{args[0]}")
          when :finish
            ATT::Logger.info("all done!")
          end
        end
        ATT::Logger.info("上传文件成功")
        return true
      rescue Net::SFTP::StatusException
        raise ATT::Exceptions::SftpStatusError,"目的路径不存在或没有权限上传"
      rescue
        ATT::Logger.soft($!.class, $!.to_s)
        raise ATT::Exceptions::SftpUnknownError,"未知错误"
      ensure
      end
    end
=begin rdoc
作用: 删除设备后台的文件
描述: 与设备建立连接后,删除设备后台的文件
参数: dest_file => 目的文件,如"/var/tmp/temp.txt"
返回值: true/异常
     目的文件不存在时,抛出ATT::Exceptions::SftpStatusError
     其他情况,抛出ATT::Exceptions::SftpUnknownError
=end
    def delete(dest_file)
      raise ATT::Exceptions::NotFoundError,"请先使用TestDevice.new()建立sftp连接" unless @sftp_connector
      raise ATT::Exceptions::NotFoundError,"sftp连接超时断开,请重新使用TestDevice.new()建立连接" if check_sftp_connector_closed?
      ATT::Logger.info("要删除的文件名称是: #{dest_file}")
      begin
        @sftp_connector.remove!(dest_file)
        ATT::Logger.info("删除文件成功")
        return true
      rescue Net::SFTP::StatusException
        raise ATT::Exceptions::SftpStatusError,"目的文件不存在或没有权限"
      rescue
        ATT::Logger.soft($!.class, $!.to_s)
        raise ATT::Exceptions::SftpUnknownError,"未知错误"
      ensure
      end
    end
=begin rdoc
作用: 下载文件到本地
描述: 与设备建立连接后,下载文件到本地
参数: dest_file => 目的文件,如"/root/tmp.txt","/etc/tmp.txt"
     local_dir => 本地路径,如"D:/tmp"
返回值: true/异常
     目的文件不存在时,抛出ATT::Exceptions::SftpStatusError
     其他情况,抛出ATT::Exceptions::SftpUnknownError
=end
    def download(dest_file, local_dir)
      raise ATT::Exceptions::NotFoundError,"请先使用TestDevice.new()建立sftp连接" unless @sftp_connector
      raise ATT::Exceptions::NotFoundError,"sftp连接超时断开,请重新使用TestDevice.new()建立连接" if check_sftp_connector_closed?
      raise ATT::Exceptions::NotFoundError,"本地路径不存在" unless File.exist?(local_dir)
      file_name = File.basename(dest_file)
      ATT::Logger.info("要下载的文件名称是: #{file_name}")
      begin
        @sftp_connector.download!(dest_file, "#{local_dir}/#{file_name}") do |event, downloader, *args|
          case event
          when :open # args[0] : file metadata
            puts "starting download: #{args[0].remote} -> #{args[0].local} (#{args[0].size} bytes}"
          when :get
            puts "writing #{args[2].length} bytes to #{args[0].local} starting at #{args[1]}"
          when :close # args[0] : file metadata
            puts "finished with #{args[0].remote}"
          when :mkdir # args[0] : local path name
            puts "creating directory #{args[0]}"
          when :finish
            puts "all done!"
          end
        end
        ATT::Logger.info("下载文件成功")
        return true
      rescue Net::SFTP::StatusException
        raise ATT::Exceptions::SftpStatusError,"目的文件不存在或没有权限"
      rescue
        ATT::Logger.soft($!.class, $!.to_s)
        raise ATT::Exceptions::SftpUnknownError,"未知错误"
      ensure
      end
    end
=begin rdoc
作用: 重命名设备后台的文件
描述: 与设备建立连接后,重命名设备后台的文件
参数: dest_file => 目的文件,如"/var/tmp/temp.txt"
     new_name => 新名称
返回值: true/异常
     目的文件不存在时,抛出ATT::Exceptions::SftpStatusError
     其他情况,抛出ATT::Exceptions::SftpUnknownError
=end
    def rename(dest_file, new_name)
      raise ATT::Exceptions::NotFoundError,"请先使用TestDevice.new()建立sftp连接" unless @sftp_connector
      raise ATT::Exceptions::NotFoundError,"sftp连接超时断开,请重新使用TestDevice.new()建立连接" if check_sftp_connector_closed?
      file_name = File.basename(dest_file)
      file_path = dest_file.split("/")[0..-2].join("/")
      ATT::Logger.info("要重命名的文件名称是: #{file_name}")
      ATT::Logger.info("带路径的新文件是: #{file_path}/#{new_name}")
      begin
        @sftp_connector.rename!(dest_file, "#{file_path}/#{new_name}")
        ATT::Logger.info("重命名文件成功")
        return true
      rescue Net::SFTP::StatusException
        raise ATT::Exceptions::SftpStatusError,"目的文件不存在或没有权限"
      rescue
        ATT::Logger.soft($!.class, $!.to_s)
        raise ATT::Exceptions::SftpUnknownError,"未知错误"
      ensure
      end
    end

=begin rdoc
作用: 获取设备的网络配置
描述: 与设备建立连接后,执行ifconfig获取设备的网络配置
参数:
返回值: 执行ifconfig后的返回结果
=end
    def get_ifconfig()
      raise ATT::Exceptions::NotFoundError,"请先使用TestDevice.new()建立ssh连接" unless @connector
      raise ATT::Exceptions::NotFoundError,"ssh连接超时断开,请重新使用TestDevice.new()建立连接" if check_connector_closed?
      result = @connector.exec!("ifconfig")
      ATT::Logger.info("设备的网络配置是:\n#{result}")
      return result
    end
=begin rdoc
作用: 获取设备的IP地址
描述: 从配置文件根据名称获取设备的IP地址
参数: name => 测试设备名称,如果是空则默认从第一个配置读取
返回值: true/异常
     其他情况,抛出ATT::Exceptions::SshUnknownError
=end
    def self.manage_ip(name = nil)
      ATT::Logger.info("参数中设备名称是#{name},如果是空则从配置文件中读取第一个配置")
      test_device_config = ATT::TestDevice.get_config(name)
      ip = test_device_config[1][0]
      ATT::Logger.info("名称是 #{name} 的设备的ip: #{ip}")
      return ip
    end
=begin rdoc
作用: 获取设备的lan口IP
描述: 与设备建立连接后,执行ifconfig获取设备的lan口(物理口eth0)的ip
参数: 无
返回值: ip
=end
    def lan_ip()
      network_config = get_ifconfig()
      config_array = config_str_to_array(network_config)
      config_array.each do |config|
        if config =~ /eth0\s+/
          ATT::Logger.info("找到了eth0的配置, 是:\n#{config}")
          line_array = config.split("\n")
          if line_array[1] =~ /\s+inet addr:(.+)\s+Bcast:.+/
            ip = $1.strip
            ATT::Logger.info("LAN口(eth0)的IP是:#{ip}")
            return ip
          end
        end
      end
    end
=begin rdoc
作用: 获取设备的wan口IP
描述: 与设备建立连接后,执行ifconfig获取设备的wan口(物理口eth2)的ip
参数: 无
返回值: ip
=end
    def wan_ip()
      network_config = get_ifconfig()
      config_array = config_str_to_array(network_config)
      config_array.each do |config|
        if config =~ /eth2\s+/
          ATT::Logger.info("找到了eth2的配置, 是:\n#{config}")
          line_array = config.split("\n")
          if line_array[1] =~ /\s+inet addr:(.+)\s+Bcast:.+/
            ip = $1.strip
            ATT::Logger.info("WAN口(eth2)的IP是:#{ip}")
            return ip
          end
        end
      end
    end
=begin rdoc
描述: 用来打开连接设备后台的端口,使用DLAN网关升级系统工具,执行命令打开端口
=end
    def try_open_port(host, dlancommand, dlanpasswd, comm)
      ai = WIN32OLE.new("autoitx3.control")
      title = "DLAN"
      host_array = host.to_s.split(".")
      system("tskill dlanupdater 2> NUL") and sleep 5 if ai.WinExists(title)
      #ai.run("#{@@lib_bin_path}/dlanupdater.exe")
	  
	  shell = WIN32OLE.new("shell.application")
	  shell.ShellExecute("#{@@lib_bin_path}/dlanupdater.exe", '', '', 'open', 1)
	  
      if ai.WinWait(title, "" , 15) == 0
        raise "打开DLAN工具超时"
      end
      Timeout.timeout(30) do
        catch(:login_ok) do
          ai.WinActivate(title)
          ai.WinMenuSelectItem(title,"","系统","直接连接")
          ai.WinActivate("连接")
          sleep 0.5
          ai.ControlSetText("连接","","Edit4",host_array[0])
          sleep 0.5
          ai.ControlSetText("连接","","Edit3",host_array[1])
          sleep 0.5
          ai.ControlSetText("连接","","Edit2",host_array[2])
          sleep 0.5
          ai.ControlSetText("连接","","Edit1",host_array[3])
          sleep 0.5
          ai.ControlSetText("连接","","Edit5", dlanpasswd)
          sleep 0.5
          ai.ControlClick("连接","","Button1")
          sleep 0.5
          loop do
            msg = ai.ControlGetText(title,"","RICHEDIT1")
            if msg.include?("登录密码错误")
              raise "登录密码错误"
            end
            if msg.include?("登录成功")
              throw :login_ok
            end
            sleep 0.1
          end
        end
      end
      msg  = ai.ControlGetText(title,"","RICHEDIT1")
      raise "登录失败" unless msg.include?("登录成功")
      ai.WinActivate(title)
      ai.Send("^+{F10}")
      ai.ControlSetText("请输入密码","","Edit1", dlancommand)
      sleep 0.5
      ai.ControlClick("请输入密码","","Button1")
      sleep 0.5
      ai.ControlSetText(title,"","Edit1", comm)
      sleep 0.5
      ai.ControlFocus(title,"","Edit1")
      ai.Send("{ENTER}")
      Timeout.timeout(30) do
        catch(:sshftp_ok) do
          loop do
            msg  = ai.ControlGetText(title,"","RICHEDIT1")
            if msg.include?("执行命令成功")
              throw :sshftp_ok
            end
            sleep 0.1
          end
        end
      end
      msg  = ai.ControlGetText(title,"","RICHEDIT1")
      raise "执行命令失败" unless msg.include?("执行命令成功")
      sleep 10
      ai.WinClose(title) # 关闭dlan工具
    end
=begin
get_model(host, port, user, passwd)
=end
  end
end


