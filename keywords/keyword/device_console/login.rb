# coding: utf8
=begin rdoc
作用: 登录设备控制台
维护记录:
维护人      时间                  行为
gsj     2011-12-14              创建
=end

module DeviceConsole


=begin rdoc
类名: 登录
描述: 非UI方式登录控制台
=end
  class Login < ATT::Base

=begin rdoc
关键字名: 登录控制台
描述: 非UI方式登录控制台,前提是已经调用过关键字'设置当前网关'
维护人: gsj
参数:
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def login( hash )
      ATT::KeyLog.info("登录网关IP:#{$gw_ip},用户名/密码:#{$user}/#{$passwd}")
      session = nil
      begin
        session = AF::Login.get_session()
      rescue Exception
        ATT::KeyLog.error("发生异常:#{$!}")
      end
      if session.nil?
        return_fail
      else
        return_ok
      end
    end



  end
end
