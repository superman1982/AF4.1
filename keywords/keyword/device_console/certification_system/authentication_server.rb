# encoding: utf-8
=begin rdoc
作用: 请输入作用
维护记录:
维护人      时间                  行为
张文杰     2012-12-20                     创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module CertificationSystem


=begin rdoc
类名: 外部认证服务器
描述: 配置外部认证服务器
=end
    class AuthenticationServer < ATT::Base

=begin rdoc
关键字名: 新增LDAP认证服务器
描述: 新增LDAP认证服务器
维护人: 张文杰
参数:
id=>name,name=>服务器名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"LADP服务器的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启禁LADP服务器"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"LADP服务器的IP地址"
id=>port,name=>认证端口,type=>s,must=>false,default=>"389",value=>"{text}",descrip=>"LADP服务器的认证端口"
id=>timeout,name=>超时,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"LADP服务器的超时（秒)"
id=>basedn,name=>BaseDN,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"LADP服务器的BaseDN"
id=>type,name=>类型,type=>s,must=>false,default=>"MS Active Directory",value=>"MS Active Directory|Open LDAP|SUN LADP|IBM LDAP|OTHER LDAP",descrip=>"LADP服务器的同步配置类型"
id=>anonymous,name=>匿名搜索,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否使用匿名搜索"
id=>user,name=>域用户,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"LADP服务器的同步配置域用户"
id=>passwd,name=>用户密码,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"LADP服务器的同步配置用户密码"
id=>userAttr,name=>用户属性,type=>s,must=>false,default=>"sAMAccountName",value=>"{text}",descrip=>"LADP服务器的同步配置用户属性"
id=>groupAttr,name=>用户组属性,type=>s,must=>false,default=>"member",value=>"{text}",descrip=>"LADP服务器的同步配置用户组属性"
id=>filter,name=>用户组过滤,type=>s,must=>false,default=>"objectCategory=group",value=>"{text}",descrip=>"LADP服务器的同步配置用户组过滤"
id=>attr,name=>描述属性,type=>s,must=>false,default=>"description",value=>"{text}",descrip=>"LADP服务器的同步配置描述属性"
id=>useext,name=>分页搜索,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否使用扩展方式函数"
id=>pagesize,name=>页面大小,type=>s,must=>false,default=>"0",value=>"{text}",descrip=>"LADP服务器的搜索配置页面大小"
id=>sizelimits,name=>大小限制,type=>s,must=>false,default=>"0",value=>"{text}",descrip=>"LADP服务器的搜索配置大小限制"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def add_ldap_server(hash={})
        ATT::KeyLog.debug("新增LDAP认证服务器......")
        post_hash = get_add_ldap_server_post_hash( hash )
        result_hash = AF::Login.get_session().post(AuthenticateServerCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("新增LDAP认证服务器错误,消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑LDAP认证服务器
描述: 编辑LDAP认证服务器
维护人: 张文杰
参数:
id=>name,name=>服务器名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"LADP服务器的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启禁LADP服务器"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"LADP服务器的IP地址"
id=>port,name=>认证端口,type=>s,must=>false,default=>"389",value=>"{text}",descrip=>"LADP服务器的认证端口"
id=>timeout,name=>超时,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"LADP服务器的超时（秒)"
id=>basedn,name=>BaseDN,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"LADP服务器的BaseDN"
id=>type,name=>类型,type=>s,must=>false,default=>"MS Active Directory",value=>"MS Active Directory|Open LDAP|SUN LADP|IBM LDAP|OTHER LDAP",descrip=>"LADP服务器的同步配置类型"
id=>anonymous,name=>匿名搜索,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否使用匿名搜索"
id=>user,name=>域用户,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"LADP服务器的同步配置域用户"
id=>passwd,name=>用户密码,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"LADP服务器的同步配置用户密码"
id=>userAttr,name=>用户属性,type=>s,must=>false,default=>"sAMAccountName",value=>"{text}",descrip=>"LADP服务器的同步配置用户属性"
id=>groupAttr,name=>用户组属性,type=>s,must=>false,default=>"member",value=>"{text}",descrip=>"LADP服务器的同步配置用户组属性"
id=>filter,name=>用户组过滤,type=>s,must=>false,default=>"objectCategory=group",value=>"{text}",descrip=>"LADP服务器的同步配置用户组过滤"
id=>attr,name=>描述属性,type=>s,must=>false,default=>"description",value=>"{text}",descrip=>"LADP服务器的同步配置描述属性"
id=>useext,name=>分页搜索,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否使用扩展方式函数"
id=>pagesize,name=>页面大小,type=>s,must=>false,default=>"0",value=>"{text}",descrip=>"LADP服务器的搜索配置页面大小"
id=>sizelimits,name=>大小限制,type=>s,must=>false,default=>"0",value=>"{text}",descrip=>"LADP服务器的搜索配置大小限制"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def edit_ldap_server(hash={})
        ATT::KeyLog.debug("编辑LDAP认证服务器......")
        post_hash = get_edit_ldap_server_post_hash( hash )
        result_hash = AF::Login.get_session().post(AuthenticateServerCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("编辑LDAP认证服务器错误,消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增RADIUS认证服务器
描述: 新增RADIUS认证服务器
维护人: 张文杰
参数:
id=>name,name=>服务器名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"RADIUS服务器名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启禁RADIUS服务器"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"RADIUS服务器的IP地址"
id=>port,name=>认证端口,type=>s,must=>false,default=>"1812",value=>"{text}",descrip=>"RADIUS服务器的认证端口"
id=>timeout,name=>超时,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"RADIUS服务器的超时（秒)"
id=>sharekey,name=>共享密钥,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"RADIUS服务器的共享密钥"
id=>protocol,name=>采用协议,type=>s,must=>false,default=>"不加密的协议PAP",value=>"不加密的协议PAP|质询握手身份验证协议|Microsoft CHAP|Microsoft CHAP2|EAP_MD5",descrip=>"RADIUS服务器的采用协议"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def add_radius_server(hash={})
        ATT::KeyLog.debug("新增RADIUS认证服务器......")
        post_hash = get_add_radius_server_post_hash( hash )
        result_hash = AF::Login.get_session().post(AuthenticateServerCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("新增RADIUS认证服务器错误,消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑RADIUS认证服务器
描述: 编辑RADIUS认证服务器
维护人: 张文杰
参数:
id=>name,name=>服务器名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"RADIUS服务器名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启禁RADIUS服务器"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"RADIUS服务器的IP地址"
id=>port,name=>认证端口,type=>s,must=>false,default=>"1812",value=>"{text}",descrip=>"RADIUS服务器的认证端口"
id=>timeout,name=>超时,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"RADIUS服务器的超时（秒)"
id=>sharekey,name=>共享密钥,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"RADIUS服务器的共享密钥"
id=>protocol,name=>采用协议,type=>s,must=>false,default=>"不加密的协议PAP",value=>"不加密的协议PAP|质询握手身份验证协议|Microsoft CHAP|Microsoft CHAP2|EAP_MD5",descrip=>"RADIUS服务器的采用协议"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def edit_radius_server(hash={})
        ATT::KeyLog.debug("编辑RADIUS认证服务器......")
        post_hash = get_edit_radius_server_post_hash( hash )
        result_hash = AF::Login.get_session().post(AuthenticateServerCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("编辑RADIUS认证服务器错误,消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增POP3认证服务器
描述: 新增POP3认证服务器
维护人: 张文杰
参数:
id=>name,name=>服务器名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"POP3服务器名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启禁POP3服务器"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"POP3服务器的IP地址"
id=>port,name=>认证端口,type=>s,must=>false,default=>"110",value=>"{text}",descrip=>"POP3服务器的认证端口"
id=>timeout,name=>超时,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"POP3服务器的超时（秒）"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def add_pop3_server(hash={})
        ATT::KeyLog.debug("新增POP3认证服务器......")
        post_hash = get_add_pop3_server_post_hash( hash )
        result_hash = AF::Login.get_session().post(AuthenticateServerCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("新增POP3认证服务器错误,消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑POP3认证服务器
描述: 编辑POP3认证服务器
维护人: 张文杰
参数:
id=>name,name=>服务器名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"POP3服务器名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启禁POP3服务器"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"POP3服务器的IP地址"
id=>port,name=>认证端口,type=>s,must=>false,default=>"110",value=>"{text}",descrip=>"POP3服务器的认证端口"
id=>timeout,name=>超时,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"POP3服务器的超时（秒）"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def edit_pop3_server(hash={})
        ATT::KeyLog.debug("编辑POP3认证服务器......")
        post_hash = get_edit_pop3_server_post_hash( hash )
        result_hash = AF::Login.get_session().post(AuthenticateServerCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("编辑POP3认证服务器错误,消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 启禁认证服务器
描述: 启禁认证服务器
维护人: 张文杰
参数:
id=>enable_count,name=>操作个数,type=>s,must=>true,default=>"部分操作",value=>"部分操作|全部操作",descrip=>"操作指定名称的认证服务器,还是操作目前所有的认证服务器"
id=>names,name=>名称列表,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"当操作类型选择部分操作时,指定要操作的认证服务器名称,多个时使用&分割"
id=>enable_type,name=>操作类型,type=>s,must=>true,default=>"启用",value=>"启用|禁用",descrip=>"指定操作,是启用还是禁用"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_authenticate_server(hash={})
        ATT::KeyLog.debug("启用或禁用认证服务器.....")
        if hash[:enable_count] == "全部操作"
          all_authenticate_server_names = DeviceConsole::get_all_object_names(AuthenticateServerCGI, "外部认证服务器") # 获取所有IPS策略的名称,数组类型
        else
          all_authenticate_server_names = hash[:names].to_s.split("&") # 数组类型
        end
        post_hash = {"opr" => ( hash[:enable_type] == "启用" ? "enable" : "disable"), "name" => all_authenticate_server_names }
        result_hash = AF::Login.get_session().post(AuthenticateServerCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("启用或禁用认证服务器..错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除认证服务器
描述: 删除认证服务器
维护人: 张文杰
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的认证服务器,还是删除目前所有的认证服务器"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的认证服务器名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_authenticate_server(hash={})
        ATT::KeyLog.debug("删除认证服务器......")
        if hash[:delete_type] == "全部删除"
          all_authenticate_server_names = DeviceConsole::get_all_object_names(AuthenticateServerCGI, "外部认证服务器") # 数组类型
        else
          all_authenticate_server_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_authenticate_server_names.empty? # 不存在任何URL过滤时,直接返回成功
        post_hash = {"opr" => "delete", "name" => all_authenticate_server_names}
        result_hash = AF::Login.get_session().post(AuthenticateServerCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end


      #end of class AuthenticationServer
    end
    #don't add any code after here.

  end

end
