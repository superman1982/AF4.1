# coding: utf8
=begin rdoc
作用: 重启设备或服务
维护记录:
维护人      时间                  行为
gsj     2012-01-05              创建
=end

module DeviceConsole

  module SystemMantenance


=begin rdoc
类名: 重启
描述: 重启设备或服务
=end
    class RebootDevice < ATT::Base

=begin rdoc
关键字名: 重启设备
描述: 重启网关
维护人: gsj
参数:
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def reboot_device(hash)
        post_hash = {"opr" => "reboot" }
        result_hash = AF::Login.get_session().post(RebootCGI, post_hash)
        if result_hash["success"]
          sleep 80
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 重启服务
描述: 重启服务
维护人: gsj
参数:
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def reboot_service(hash)
        post_hash = {"opr" => "service" }
        result_hash = AF::Login.get_session().post(RebootCGI, post_hash)
        if result_hash["success"]
          sleep 60
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end



    end
  end
end
