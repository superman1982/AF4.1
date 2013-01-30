# coding: utf8
=begin rdoc
作用: 封装设备后台网络操作
维护记录:
维护人      时间                  行为
gsj     2011-12-09              创建
=end
require 'keywords/keyword/device_back'

module DeviceBack


=begin rdoc
类名: 网络操作
描述: 网络操作
=end
  class NetworkOperation < ATT::Base

=begin rdoc
关键字名: 检查拨号虚拟接口
描述: 使用ifconfig检查拨号产生的虚拟设备是否存在
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def check_virtual_interface_by_pppope(hash) # 
      ssh_connection = ATT::TestDevice.new(hash[:devicename])
      ifconfig_result = ssh_connection.exec_command("ifconfig")[1].to_s
      unless ifconfig_result.include?("ppp")
        ATT::KeyLog.debug("执行ifconfig命令的输出是:\n#{ifconfig_result}")
        return_fail
      end
      return_ok # 拨号虚拟接口存在|拨号虚拟接口不存在
    end

=begin rdoc
关键字名: tcpdump抓包
描述: 使用tcpdump命令进行抓包,抓包的内容存入某个文件,以备检查
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>block,name=>阻塞,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否以阻塞执行的形式执行tcpdump命令,默认是非阻塞"
id=>options,name=>抓包选项,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"执行tcpdump命令的选项"
id=>tmpfile,name=>存入文件,type=>s,must=>false,default=>"/root/tcpdump.txt",value=>"{text}",descrip=>"抓包的内容保存到的文件,含全路径,默认是/root/tcpdump.txt"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def tcpdump_package( hash )
      kill_tcpdump_processes_existed( hash[:devicename] ) # 检查是否已经有tcpdump进程存在,若有则全部杀掉
      tcpdump_command = "tcpdump -nn #{hash[:options]} > #{hash[:tmpfile]}"
      ssh_connection = ATT::TestDevice.new(hash[:devicename])
      begin # 先启动tcpdump,然后检查tcpdump进程有没有启动,若没有则重新启动
        if hash[:block] == "是"
          value, result = ssh_connection.exec_command( tcpdump_command )
        else
          value, result = ssh_connection.exec_command_nowait( tcpdump_command )
        end
        ATT::KeyLog.debug("执行命令#{tcpdump_command}的返回值是:#{value},返回结果是:#{result}")
        sleep 6 # 稍等
        ps_value, ps_result = ssh_connection.exec_command( PS_GREP_TCPDUMP )
        ATT::KeyLog.error("执行命令:#{PS_GREP_TCPDUMP}的返回值是#{ps_value},返回结果是:\n#{ps_result}")
        pid_array = DeviceBack::get_pid_from_jobs(ps_result, "tcpdump") # 从ps aux | tcpdump的结果中查找出进程的ID
      rescue => exception
        ATT::KeyLog.error("发生异常:#{$!.class},#{$!.message}")
        if exception == "进程不存在" # 未启动成功
          retry
        else
          ssh_connection = ATT::TestDevice.new(hash[:devicename])
          retry
        end
      end
      return_ok if defined?(pid_array) && !pid_array.empty?
    end
    
=begin rdoc
关键字名: 抓包检查链路检测间隔
描述: 阻塞执行tcpdump命令进行抓包,从抓包的内容中检查链路检测时间间隔是否与期望一致,仅限时间间隔在1分钟内
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>options,name=>抓包选项,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"执行tcpdump命令的选项"
id=>interval,name=>期望间隔,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"期望的链路检测时间间隔,单位是秒"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def tcpdump_check_link_check_interval( hash )
      ssh_connection = ATT::TestDevice.new(hash[:devicename])
      tcpdump_result = ssh_connection.exec_command("tcpdump #{hash[:options]}")[1].to_s
      link_check_interval(tcpdump_result, hash[:interval]) # 检查链路检测间隔
    end
    
  end
end
