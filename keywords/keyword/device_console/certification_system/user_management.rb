=begin rdoc
作用: 封装认证系统中用户管理部分的关键字
维护记录:
维护人      时间                  行为
gsj     2011-12-07              创建
=end

module DeviceConsole

  module CertificationSystem


=begin rdoc
类名: 用户管理
描述: 用户管理
=end
    class UserManagement < ATT::Base

=begin rdoc
关键字名: 新增用户组
描述: 新增用户组,可同时新增同一个所属路径下的多个用户组,位于不同路径上的用户组可重名
参数:
id=>group_names,name=>用户组名列表,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"用户组名,多个时使用&分割"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>path,name=>所属路径,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"新用户组所属的全路径"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|路径错误",descrip=>""
=end
      def add_user_group( hash )
        ATT::KeyLog.debug("add user group......")
        post_hash=get_add_user_group( hash )
        result_hash = AF::Login.get_session().post(UserManageCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除用户组
描述: 删除用户组,可同时删除同一个所属路径下的多个用户组
参数:
id=>group_names,name=>用户组名列表,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要删除的用户组名,多个时使用&分割"
id=>path,name=>所属路径,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"要删除的用户组所属的全路径,如/默认组"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|路径错误|该用户组不存在",descrip=>""
=end
      def delete_user_group( hash )
        ATT::KeyLog.debug("delete user group......")
        post_hash = get_delete_user_group( hash )
        result_hash = AF::Login.get_session().post(UserManageCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end


=begin rdoc
关键字名: 新增单用户
描述: 新增一个用户,所有的用户不可重名,即使属于不同的用户组
参数:
id=>login_name,name=>登录名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"单用户的登录名"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>show_name,name=>显示名,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"单用户的显示名"
id=>path,name=>所属用户组全路径,type=>s,must=>false,default=>"/默认组",value=>"{text}",descrip=>"新用户所属用户组的全路径,如/默认组/test"
id=>local_passwd,name=>本地密码,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否使用本地密码"
id=>passwd,name=>密码,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"勾选本地密码时输入的密码"
id=>confirm_passwd,name=>确认密码,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"勾选本地密码时输入的确认密码"
id=>bind_ip_mac,name=>绑定IP或MAC地址,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选绑定IP/MAC地址"
id=>bind_method,name=>绑定方式,type=>s,must=>false,default=>"用户和地址双向绑定",value=>"用户和地址双向绑定|用户和地址单向绑定",descrip=>"勾选绑定IP/MAC地址时选择的绑定方式"
id=>bind_type,name=>绑定类型,type=>s,must=>false,default=>"绑定IP和MAC",value=>"绑定IP和MAC|绑定IP|绑定MAC",descrip=>"勾选绑定IP/MAC地址时选择的绑定类型"
id=>ip_macs,name=>IP或MAC地址,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入绑定的IP,MAC地址或IP和MAC"
id=>public_account,name=>公用帐号,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否允许多人同时使用该帐号登录"
id=>logout_popup,name=>弹出注销窗口,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"密码认证成功后弹出注销窗口"
id=>expire_type,name=>帐号过期类型,type=>s,must=>false,default=>"永不过期",value=>"永不过期|指定过期时间",descrip=>"帐号过期的类型,是永不过期还是指定过期时间"
id=>expire_time,name=>过期时间,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"不选择永不过期时输入的过期时间"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_single_user( hash )
        ATT::KeyLog.debug("add single user......")
        post_hash = get_add_single_user_post_hash( hash )
        result_hash = AF::Login.get_session().post(UserManageCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除用户
描述: 删除用户,可同时删除同一个用户组下的多个用户
参数:
id=>user_names,name=>用户名列表,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要删除的用户名,多个时使用&分割"
id=>path,name=>所属用户组全路径,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"要删除的用户所属的用户组的全路径,如/默认组"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|路径错误|该用户不存在",descrip=>""
=end
      def delete_users( hash )
        ATT::KeyLog.debug("delete users......")
        post_hash = get_delete_users_post_hash( hash )
        result_hash = AF::Login.get_session().post(UserManageCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      
      end
    end
  end
end
