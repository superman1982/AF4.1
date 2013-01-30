# coding: utf8
=begin rdoc
作用: 公共作用的关键字
维护记录:
维护人      时间                  行为
gsj     2011-12-10              创建
=end


=begin rdoc
类名: 公共
描述: 公共
=end
class Common < ATT::Base

=begin rdoc
关键字名: 设置当前网关
描述: 设置当前网关,目的是用全局量记录下当前设备的IP,用户名,密码,供登录设备控制台使用
维护人: gsj
参数:
id=>gw_ip,name=>网关IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"当前要操作的设备的IP"
id=>user,name=>用户名,type=>s,must=>false,default=>"admin",value=>"{text}",descrip=>"登录当前设备控制台的用户名,默认是admin"
id=>passwd,name=>密码,type=>s,must=>false,default=>"sangfor",value=>"{text}",descrip=>"登录当前设备控制台的密码,默认是sangfor"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
	def set_current_device( hash )
    AF::Login.logout() # 设置前先注销登录控制台的session,避免设置新的网关配置后,仍使用原来的session
    $gw_ip = "#{hash[:gw_ip]}"
    $user = "#{hash[:user]}"
    $passwd = "#{hash[:passwd]}"
    ATT::KeyLog.info("当前网关IP:#{$gw_ip},用户名/密码:#{$user}/#{$passwd}")
	end

=begin rdoc
关键字名: 等待
描述: 等待指定的时间
维护人: gsj
参数:
id=>time,name=>时间,type=>s,must=>false,default=>"60",value=>"{text}",descrip=>"等待的时长,单位是秒,默认60秒"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
	def wait( hash )
    hash[:time] = 60 if hash[:time].to_s.empty?
    ATT::KeyLog.info("要等待#{hash[:time]}秒...")
    sleep hash[:time].to_i
    return_ok
	end


end