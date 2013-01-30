=begin
作用: 测试主机的操作封装
描述: 封装测试主机常用的操作
平台: ruby1.8.6/windows
作者: gsj
更新记录:
     日期             更新人          行为
     2010.11.16      gsj            创建脚本
=end
require 'att'
require 'att/core_ext/string'
require 'pathname'
require 'win32ole'

module ATT
=begin rdoc
描述: 封装了本机的一些操作,如获取/设置IP/MAC/
=end
  class LocalPC
    @@lib_bin_path = Pathname.new(File.join(File.dirname(__FILE__),'..',"lib_bin")).realpath
    private
    def self.get_connection_gbk_name(connection_name) # 转换连接名称的编码到GBK
      return connection_name.to_gbk
    end
    def self.print_lib_bin_dir()
      #Dir.chdir(@@lib_bin_path)
      ATT::Logger.info("目录 #{@@lib_bin_path}")
    end
=begin rdoc
描述: 从ipconfig命令的返回结果中查找出指定名称连接的所有配置
参数: cmd => 要执行的命令
返回值: 执行命令后的输出,utf8编码的值
=end
    def self.get_connection_configuration(ipconfig_result, connection_name)
      config_line = ""
      config_start = false
      ipconfig_result.each_line do |line|
        config_start = true if line.include?(connection_name)
        config_line << line if config_start #&& line =~ /IP Address. . . . . . . . . . . . : /
        config_start = false if line =~ /Default Gateway/
      end
      return config_line
    end
    public
	
=begin rdoc
描述: 获取当前windows版本信息
参数: 无
返回值: 返回字符串:Microsoft Windows XP Professional SP3
=end
    def self.get_windows_version_info()
      WIN32OLE.connect('winmgmts:\\\\.').ExecQuery("select * from Win32_OperatingSystem" ).each do |m|
        return "#{m.Caption} SP#{m.ServicePackMajorVersion}"
      end
    end	
	
=begin rdoc
描述: 本机执行cmd命令
参数: cmd => 要执行的命令
返回值: 执行命令后的输出,utf8编码的值
=end
    def self.execute_cmd(cmd)
      cmd_result = `#{cmd}`
      return cmd_result.to_s.to_utf8
    end
    
=begin rdoc
作用: 本机设置ip地址
描述: 设置本机某个连接的静态ip地址
参数: ip => 目的IP
     mask => 掩码
     gateway => 默认网关
     connection_name => 连接的名称,默认是"本地连接"
返回值: 设置成功true/设置失败异常
=end
    def self.set_ip(ip, mask, gateway, connection_name = "本地连接")
      ATT::Logger.info("目的IP是#{ip},掩码是#{mask},默认网关是#{gateway},连接是#{connection_name}")
      connection = get_connection_gbk_name(connection_name)
      print_lib_bin_dir()
      # 执行设置IP的命令
	  if gateway == "none"
	    netsh_result = execute_cmd("#{@@lib_bin_path}/netsh.exe interface ip set address \"#{connection}\" static #{ip} #{mask} #{gateway}")
	  else
        netsh_result = execute_cmd("#{@@lib_bin_path}/netsh.exe interface ip set address \"#{connection}\" static #{ip} #{mask} #{gateway} 1")
	  end
      ATT::Logger.info("执行netsh interface ip set address命令后的结果: #{netsh_result}")
      if netsh_result.include?("确定") # 设置成功
        ATT::Logger.info("本机IP设置成功")
        return true
      end
      ATT::Logger.info("本机IP设置失败")  # 设置失败
      raise ATT::Exceptions::InterfaceParameterError,"设置IP失败,请检查各参数"
    end
=begin rdoc
作用: 本机添加ip地址
描述: 添加本机某个连接的静态ip地址
参数: ip => 目的IP
     mask => 掩码
     gateway => 网关,默认是空
     connection_name => 连接的名称,默认是本地连接
返回值: 添加成功true/添加失败异常
=end
    def self.add_ip(ip, mask, gateway = nil, connection_name = "本地连接")
      ATT::Logger.info("目的IP是#{ip},掩码是#{mask},网关是#{gateway},连接是#{connection_name}")
      connection = get_connection_gbk_name(connection_name)
      os_version = get_windows_version_info()
      ATT::Logger.info("当前主机的操作系统是#{os_version}")
      if gateway.nil? or gateway.empty? # 参数中,网关为空
        part_command = "interface ip add address \"#{connection}\" #{ip} #{mask}"
      else
        part_command = "interface ip add address \"#{connection}\" #{ip} #{mask} #{gateway} 1"
      end
      if os_version =~ /XP/ || os_version =~ /2003/
        print_lib_bin_dir()
        cmd = "#{@@lib_bin_path}/netsh.exe #{part_command}"
      elsif os_version =~ /Windows 7/
        cmd = "netsh #{part_command}"
      end
      netsh_result = execute_cmd(cmd) # 执行添加IP的命令
      ATT::Logger.info("执行netsh interface ip add address命令后的结果是: #{netsh_result}")
      if (os_version =~ /XP/ || os_version =~ /2003/) && netsh_result.include?("确定") # 添加成功
        ATT::Logger.info("本机IP添加成功")
        return true
      elsif os_version =~ /Windows 7/ && netsh_result.strip.empty?
        ATT::Logger.info("本机IP添加成功")
        return true
      end
      ATT::Logger.info("本机IP添加失败") # 添加失败
      raise ATT::Exceptions::InterfaceParameterError,"添加IP失败,请检查各参数"
    end
=begin rdoc
作用: 本机删除ip地址
描述: 删除本机某个连接的静态ip地址
参数: ip => 目的IP
     gateway => 网关,默认是空
     connection_name => 连接的名称,默认是本地连接
返回值: 删除成功true/删除失败异常
=end
    def self.delete_ip(ip, gateway = nil, connection_name = "本地连接")
      ATT::Logger.info("目的IP是#{ip}, 网关是#{gateway}, 连接是#{connection_name}")
      connection = get_connection_gbk_name(connection_name)
      os_version = get_windows_version_info()
      ATT::Logger.info("当前主机的操作系统是#{os_version}")
      if gateway.nil? or gateway.empty? # 参数中,网关为空
        part_command = "interface ip delete address \"#{connection}\" #{ip}"
      else
        part_command = "interface ip delete address \"#{connection}\" #{ip} #{gateway}"
      end
      if os_version =~ /XP/ || os_version =~ /2003/
        print_lib_bin_dir()
        cmd = "#{@@lib_bin_path}/netsh.exe #{part_command}"
      elsif os_version =~ /Windows 7/
        cmd = "netsh #{part_command}"
      end
      # 执行删除IP的命令
      netsh_result = execute_cmd(cmd)
      ATT::Logger.info("执行netsh interface ip delete address命令后的结果是: #{netsh_result}")
      if (os_version =~ /XP/ || os_version =~ /2003/) && netsh_result.include?("确定") # 删除成功
        ATT::Logger.info("IP删除成功")
        return true
      elsif os_version =~ /Windows 7/ && netsh_result.strip.empty?
        ATT::Logger.info("IP删除成功")
        return true
      end
      ATT::Logger.info("IP删除失败") # 删除失败
      raise ATT::Exceptions::InterfaceParameterError,"删除IP失败,请检查各参数"
    end

=begin rdoc
作用: 获取本机ip地址
描述: 获取本机ip地址
参数: connection_name => 连接的名称,默认是本地连接
返回值: 本机指定连接所有IP组成的数组
       连接不存在时,抛出ATT::Exceptions::NotFoundError,"指定的连接不存在"
=end
    def self.get_ip(connection_name = "本地连接")
      print_lib_bin_dir()
      ipconfig_result = execute_cmd("#{@@lib_bin_path}/ipconfig.exe") # 执行 ipconfig
      ATT::Logger.info("执行ipconfig命令后的结果是#{ipconfig_result}")
      raise ATT::Exceptions::NotFoundError,"指定的连接不存在" unless ipconfig_result.include?(connection_name)
      ip_array = []  # 存放指定连接所有IP的数组
      ip_address_line = "" # IP地址所在的行
      # 获取指定名称连接的所有配置
      connection_config = get_connection_configuration(ipconfig_result, connection_name)
      ATT::Logger.info("connection_config:\n #{connection_config}")
      connection_config.each_line do |line|  # 获取IP所在的行
        ip_address_line << line if line =~ /IP Address. . . . . . . . . . . . : /
      end
      ip_address_line.each_line do |line|   # 获取所有的IP
        start_index = line.index(":") + 2
        ip = line.slice(start_index, line.length - 1)
        ATT::Logger.info("本机IP:\n#{ip.strip}") # IP找到
        ip_array << ip.strip
      end
      return ip_array
    end

=begin rdoc
作用: 获取本机指定连接的MAC地址
描述: 获取本机ip地址
参数: connection_name => 连接的名称,默认是本地连接
返回值: 本机指定连接的MAC地址
       连接不存在时,抛出ATT::Exceptions::NotFoundError,"指定的连接不存在"
=end
    def self.get_mac(connection_name = "本地连接")
      print_lib_bin_dir()
      ipconfig_result = execute_cmd("#{@@lib_bin_path}/ipconfig.exe /all") # 执行 ipconfig /all
      ATT::Logger.info("执行ipconfig /all命令后的结果是#{ipconfig_result}")
      raise ATT::Exceptions::NotFoundError,"指定的连接不存在" unless ipconfig_result.include?(connection_name)
      mac_line = "" # mac地址所在的行
      # 获取指定名称连接的所有配置
      connection_config = get_connection_configuration(ipconfig_result, connection_name)
      ATT::Logger.info("connection_config:\n #{connection_config}")
      connection_config.each_line do |line|  # 获取mac所在的行
        if line =~ /Physical Address/
          mac_line << line
          break
        end
      end
      start_index = mac_line.index(":") + 2 # mac地址开始的索引号
      mac = mac_line.slice(start_index, mac_line.length - 1)# mac找到
      ATT::Logger.info("指定连接的mac: #{mac.strip}")
      return mac.strip
    end

=begin rdoc
作用: 修改本机的计算机名
描述: 使用wmic修改本机的计算机名,修改后需要重启计算机
参数: new_name => 新的计算机名
返回值: 修改成功/true,失败/false
=end
    def self.set_computer_name(new_name)
      old_computer_name = execute_cmd("echo %ComputerName%").strip # 获取原有的计算机名
      ATT::Logger.info("原有的计算机名: #{old_computer_name}")
      print_lib_bin_dir()
      # 执行 wmic 命令设置计算机名
      set_result = execute_cmd("#{@@lib_bin_path}/wmic.exe computersystem where \"name='#{old_computer_name}'\" call rename #{new_name}")
      ATT::Logger.info("执行wmic命令后的结果是#{set_result}")
    end
=begin rdoc
作用: 获取本机的计算机名
描述: 获取本机的计算机名
参数: 
返回值: 计算机名
=end
    def self.get_computer_name()
      computer_name = execute_cmd("echo %ComputerName%").strip # 获取计算机名
      ATT::Logger.info("计算机名: #{computer_name}")
      return computer_name
    end

=begin rdoc
作用: 修改本机的MAC地址
描述: 使用 修改本机的MAC地址,修改后需要重启计算机
参数: new_mac => 新的MAC地址
     connection_name = "本地连接"
返回值: 修改成功/true,失败/false
=end
    def self.set_mac(new_mac, connection_name = "本地连接")
      ATT::Logger.info("目的MAC: #{new_mac}")
      print_lib_bin_dir()
      # 执行  命令设置mac
      
    end

=begin rdoc
作用: 启用网卡
描述: 启用指定的网卡,如果是xp系统,需要从win2003下拷贝ifmon.dll到xp对应目录,因为winxp的netsh interface set interface不支持name扩展
参数: adpater_name => 适配器的名称,默认是本地连接
返回值: 成功/true,失败/false
=end
    def self.enable_adpater(adpater_name = "本地连接")
      ATT::Logger.info("要启用的适配器: #{adpater_name}")
      connection = get_connection_gbk_name(adpater_name)
      print_lib_bin_dir()
      # 执行 netsh 命令启用网卡
      netsh_result = execute_cmd("#{@@lib_bin_path}/netsh.exe interface set interface \"#{connection}\" enabled").strip
      ATT::Logger.info("执行netsh interface set interface命令后的结果是: #{netsh_result}")
      if netsh_result.empty? # 启用成功
        ATT::Logger.info("启用网卡成功")
        return true
      end
      ATT::Logger.info("启用网卡失败") # 启用失败
      return false
    end
=begin rdoc
作用: 禁用网卡
描述: 禁用指定的网卡,如果是xp系统,需要从win2003下拷贝ifmon.dll到xp对应目录,因为winxp的netsh interface set interface不支持name扩展
参数: adpater_name => 适配器的名称,默认是本地连接
返回值: 成功/true,失败/false
=end
    def self.disable_adpater(adpater_name = "本地连接")
      ATT::Logger.info("要禁用的适配器: #{adpater_name}")
      connection = get_connection_gbk_name(adpater_name)
      print_lib_bin_dir()
      # 执行 netsh 命令禁用网卡
      netsh_result = execute_cmd("#{@@lib_bin_path}/netsh.exe interface set interface \"#{connection}\" disabled").strip
      ATT::Logger.info("执行netsh interface set interface命令后的结果是: #{netsh_result}")
      if netsh_result.empty? # 禁用成功
        ATT::Logger.info("禁用网卡成功")
        return true
      end
      ATT::Logger.info("禁用网卡失败") # 禁用失败
      return false
    end
=begin rdoc
作用: 本机设置DNS服务器地址
描述: 设置本机某个连接的DNS服务器地址,可设置首选备选DNS,也可清空DNS服务器地址
参数: primarydns => 首选DNS服务器IP地址,取值为'none'时,清空DNS服务器地址,取值是IP地址时,设置首选DNS
     secondarydns => 备选DNS服务器IP地址
     connection_name => 连接的名称,默认是"本地连接"
返回值: 设置成功true/设置失败异常
=end
    def self.set_dns(primarydns, secondarydns = nil, connection_name = "本地连接")
      ATT::Logger.info("首选DNS服务器是#{primarydns},备选DNS服务器是#{secondarydns},连接是#{connection_name}")
      connection = get_connection_gbk_name(connection_name)
      os_version = get_windows_version_info()
      ATT::Logger.info("当前主机的操作系统是#{os_version}")
      set_part_command = "interface ip set dns #{connection} static #{primarydns}"
      add_part_command = "interface ip add dns #{connection} #{secondarydns} 2"
      if os_version =~ /XP/ || os_version =~ /2003/
        print_lib_bin_dir()
        set_cmd = "#{@@lib_bin_path}/netsh.exe #{set_part_command}" # 设置首选DNS
        add_cmd = "#{@@lib_bin_path}/netsh.exe #{add_part_command}" # 添加备选DNS
      elsif os_version =~ /Windows 7/
        set_cmd = "netsh #{set_part_command}" # 设置首选DNS
        add_cmd = "netsh #{add_part_command}" # 添加备选DNS
      end
      netsh_result_1 = execute_cmd(set_cmd) # 执行设置DNS的命令
      ATT::Logger.info("执行netsh interface ip set dns命令后的结果: #{netsh_result_1}")
      if (os_version =~ /XP/ || os_version =~ /2003/) && netsh_result_1.include?("确定") # 设置DNS服务器成功
        ATT::Logger.info("设置首选DNS服务器成功")
        unless secondarydns.nil?
          netsh_result_2 = execute_cmd(add_cmd)
          ATT::Logger.info("执行netsh interface ip add dns命令后的结果: #{netsh_result_2}")
          if netsh_result_2.include?("确定")
            ATT::Logger.info("添加备选DNS服务器成功")
            return true
          end
        end
        return true
      elsif os_version =~ /Windows 7/ && netsh_result_1.strip.empty?
        ATT::Logger.info("设置首选DNS服务器成功")
        unless secondarydns.nil?
          netsh_result_2 = execute_cmd(add_cmd)
          ATT::Logger.info("执行netsh interface ip add dns命令后的结果: #{netsh_result_2}")
          if netsh_result_2.strip.empty?
            ATT::Logger.info("添加备选DNS服务器成功")
            return true
          end
        end
        return true
      end
      ATT::Logger.info("本机DNS服务器设置失败")  # 设置失败
      raise ATT::Exceptions::InterfaceParameterError,"设置DNS服务器失败,请检查各参数"
    end
=begin rdoc
作用: 本机清除DNS服务器地址
描述: 清除本机某个连接的DNS服务器地址
参数: connection_name => 连接的名称,默认是"本地连接"
返回值: 清除成功true/清除失败异常
=end
    def self.clear_dns(connection_name = "本地连接")
      ATT::Logger.info("清除连接是#{connection_name}的所有DNS服务器地址")
      connection = get_connection_gbk_name(connection_name)
      os_version = get_windows_version_info()
      ATT::Logger.info("当前主机的操作系统是#{os_version}")
      set_part_command = "interface ip set dns #{connection} static none"
      if os_version =~ /XP/ || os_version =~ /2003/
        print_lib_bin_dir()
        set_cmd = "#{@@lib_bin_path}/netsh.exe #{set_part_command}" # 清除DNS
      elsif os_version =~ /Windows 7/
        set_cmd = "netsh #{set_part_command}" # 清除DNS
      end
      netsh_result = execute_cmd(set_cmd) # 执行清除DNS的命令
      ATT::Logger.info("执行netsh interface ip set dns命令后的结果: #{netsh_result}")
      if (os_version =~ /XP/ || os_version =~ /2003/) && netsh_result.include?("确定") # 清除DNS服务器成功
        ATT::Logger.info("清除DNS服务器成功")
        return true
      elsif os_version =~ /Windows 7/ && netsh_result.include?("该计算机上没有配置域名服务器")
        ATT::Logger.info("清除DNS服务器成功")
        return true
      end
      ATT::Logger.info("清除DNS服务器失败")  # 清除失败
      raise ATT::Exceptions::InterfaceParameterError,"清除DNS服务器失败,请检查各参数"
    end
    
  end
end