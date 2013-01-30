# coding: utf8
=begin rdoc
作用: 封装设备后台进程操作
维护记录:
维护人      时间                  行为
gsj     2011-12-09              创建
=end
require 'keywords/keyword/device_back'

module DeviceBack


=begin rdoc
类名: 进程操作
描述: 进程操作
=end
  class ProcessOperation < ATT::Base

=begin rdoc
关键字名: 查找设备进程ID
描述: 查找某个指定名称的进程的ID,以数组形式返回,允许某个进程名有多个进程号
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>process,name=>进程名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要查找的进程的名称,可以是带全路径的,如/usr/sbin/sshd"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|进程不存在",descrip=>""
=end
    def find_process_id( hash )
      ssh_connection = ATT::TestDevice.new(hash[:devicename])
      ATT::KeyLog.info("要获取后台进程#{hash[:process]}的ID...")
      value,ps_result = ssh_connection.exec_command("ps aux | grep #{hash[:process]}")
      ATT::KeyLog.error("命令返回值是#{value},返回结果是:\n#{ps_result}")
      if value.to_s.eql?("0")
        ATT::KeyLog.info("执行命令:ps aux | grep #{hash[:process]}成功")
        begin
          DeviceBack::get_pid_from_jobs(ps_result, hash[:process]) # 从ps aux | grep process的结果中查找出进程的ID
        rescue ATT::Exceptions::NotFoundError
          ATT::KeyLog.error("进程:#{hash[:process]}不存在")
          return_fail("进程不存在")
        end
      else
        ATT::KeyLog.error("命令返回值是#{value},返回结果是#{ps_result}")
        return_fail
      end
    end

=begin rdoc
关键字名: 强制杀死设备进程
描述: 强制杀死指定ID的进程
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>processid,name=>进程ID,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要杀死进程的ID"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def force_to_kill_process( hash )
      ssh_connection = ATT::TestDevice.new(hash[:devicename])
      ATT::KeyLog.info("要杀死的进程id是#{hash[:processid]}")
      value,kill_result = ssh_connection.exec_command("kill -9 #{hash[:processid]}")
      ATT::KeyLog.error("命令返回值是#{value},返回结果是#{kill_result}")
      if value.to_s.eql?("0")
        return_ok("成功")
      else
        return_fail
      end
    end


  end
end
