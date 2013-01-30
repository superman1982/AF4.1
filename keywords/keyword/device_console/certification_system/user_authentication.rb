# coding: utf8
=begin rdoc
作用: 封装认证系统中用户认证部分的关键字
维护记录:
维护人      时间                  行为
gsj     2011-12-07              创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module CertificationSystem


=begin rdoc
类名: 用户认证
描述: 用户认证
=end
    class UserAuthentication < ATT::Base

=begin rdoc
关键字名: 启禁用户认证
描述: 启禁用户认证
参数:
id=>operation,name=>操作,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"启用还是禁用用户认证"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_user_authenticate( hash )
        ATT::KeyLog.debug("enable disable user authenticate......")
        post_hash = {"opr" => "enablechkusrauth","enable"=>hash[:operation].to_logic }
        
        result_hash = AF::Login.get_session().post(UserAuthenticateCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 设置认证区域
描述: 设置认证区域
参数:
id=>zones,name=>区域,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"认证区域,多个时使用&分割,可为空"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|认证区域不存在",descrip=>""
=end
      def set_authenticate_zone( hash )
        ATT::KeyLog.debug("set authenticate zone......")
        zone_id_array = get_id_array_of_zones(hash[:zones]) # 区域id组成的数组

        data_hash={"grid"=>zone_id_array}
        post_hash = {"opr" => "modfiyauthzone", "data" => data_hash }
        result_hash = AF::Login.get_session().post(UserAuthenticateCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增用户认证策略
描述: 新增用户认证策略
维护人: 张文杰
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"用户认证策略的名称"
id=>description,name=>描述,type=>s,must=>false,default=>"zwjTest",value=>"{text}",descrip=>"描述"
id=>ipmac,name=>IP/MAC范围,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"策略适用IP/MAC范围,多个以&隔开"
id=>authway,name=>认证方式,type=>s,must=>false,default=>"不需要认证/单点登录",value=>"不需要认证/单点登录|本地密码认证/外部密码认证/单点登录|必须使用单点登录",descrip=>"策略的认证方式"
id=>noauth,name=>不需要认证的方式,type=>s,must=>false,default=>"把IP作为用户名",value=>"把IP作为用户名|把MAC作为用户名|把计算机名字作为用户名",descrip=>"选择不需要认证的方式"
id=>exceptuser,name=>例外的用户,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"指定例外用户帐号的登录名，多个以&个隔开"
id=>newoption,name=>新用户选项,type=>s,must=>false,default=>"添加到指定的本地组中",value=>"添加到指定的本地组中|仅作为临时帐号|不允许新用户认证",descrip=>"指定新用户选项方式"
id=>path,name=>选择组,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"选择组"
id=>auto,name=>自动同步,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否自动触发该用户的同步"
id=>publiclimit,name=>帐号公共属性,type=>s,must=>false,default=>"允许多人同时使用",value=>"允许多人同时使用|仅允许一人使用",descrip=>"选择用户帐号的公共属性"
id=>ipmaclimit,name=>绑定IP/MAC地址,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用绑定IP/MAC地址"
id=>ipmac_bind,name=>绑定方式,type=>s,must=>false,default=>"双向绑定",value=>"双向绑定|单向绑定",descrip=>"指定用户和地址的绑定方式"
id=>select,name=>绑定内容,type=>s,must=>false,default=>"仅绑定IP",value=>"仅绑定IP|仅绑定MAC|IP与MAC均绑定",descrip=>"指定绑定的地址"
id=>rightpath,name=>上网权限组,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"指定上网权限所在的组"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|认证区域不存在",descrip=>""
=end
      def add_authenticate_rule( hash )
        ATT::KeyLog.debug("新增用户认证策略......")
        post_hash = get_add_authenticate_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(UserAuthenticateCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("新增用户认证错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑用户认证策略
描述: 编辑用户认证策略
维护人: 张文杰
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"编辑用户认证策略的名称"
id=>description,name=>描述,type=>s,must=>false,default=>"zwjTest",value=>"{text}",descrip=>"描述"
id=>ipmac,name=>IP/MAC范围,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"策略适用IP/MAC范围,多个以&隔开"
id=>authway,name=>认证方式,type=>s,must=>false,default=>"不需要认证/单点登录",value=>"不需要认证/单点登录|本地密码认证/外部密码认证/单点登录|必须使用单点登录",descrip=>"策略的认证方式"
id=>noauth,name=>不需要认证的方式,type=>s,must=>false,default=>"把IP作为用户名",value=>"把IP作为用户名|把MAC作为用户名|把计算机名字作为用户名",descrip=>"选择不需要认证的方式"
id=>exceptuser,name=>例外的用户,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"指定例外用户帐号的登录名，多个以&个隔开"
id=>newoption,name=>新用户选项,type=>s,must=>false,default=>"添加到指定的本地组中",value=>"添加到指定的本地组中|仅作为临时帐号|不允许新用户认证",descrip=>"指定新用户选项方式"
id=>path,name=>选择组,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"选择组"
id=>auto,name=>自动同步,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否自动触发该用户的同步"
id=>publiclimit,name=>帐号公共属性,type=>s,must=>false,default=>"允许多人同时使用",value=>"允许多人同时使用|仅允许一人使用",descrip=>"选择用户帐号的公共属性"
id=>ipmaclimit,name=>绑定IP/MAC地址,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用绑定IP/MAC地址"
id=>ipmac_bind,name=>绑定方式,type=>s,must=>false,default=>"双向绑定",value=>"双向绑定|单向绑定",descrip=>"指定用户和地址的绑定方式"
id=>select,name=>绑定内容,type=>s,must=>false,default=>"仅绑定IP",value=>"仅绑定IP|仅绑定MAC|IP与MAC均绑定",descrip=>"指定绑定的地址"
id=>rightpath,name=>上网权限组,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"指定上网权限所在的组"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|认证区域不存在",descrip=>""
=end
      def edit_authenticate_rule( hash )
        ATT::KeyLog.debug("编辑用户认证策略......")
        post_hash = get_edit_authenticate_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(UserAuthenticateCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("编辑用户认证错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除用户认证策略
描述: 删除用户认证策略
维护人: 张文杰
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的用户认证策略,还是删除目前所有的用户认证策略"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的用户认证策略名称,多个时使用&分割，全部删除时默认策略会被保留"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_authenticate_rule(hash)
        all_authenticate_names = []
        ATT::KeyLog.debug("删除用户认证策略......")
        if hash[:delete_type] == "全部删除"        
          all_authenticate_names = get_all_authenticate_names            
        else
          all_authenticate_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_authenticate_names.empty? # 不存在任何用户认证策略时,直接返回成功
        post_hash = {"opr" => "delete", "name" => all_authenticate_names}
        result_hash = AF::Login.get_session().post(UserAuthenticateCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑用户认证选项
描述: 编辑用户认证选项
维护人: 张文杰
参数:
id=>enable_domain,name=>启用域单点登录,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"启用禁用域单点登录"
id=>auto,name=>自动下发,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否自动下发，执行指定的登录脚本"
id=>sharekey,name=>共享密钥,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入共享密钥"
id=>listen,name=>启用监听数据,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否监听计算机登录域的数据"
id=>domain_server,name=>监听地址列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入监听的域控制器地址列表，多个地址以&隔开"
id=>enable_proxy,name=>启用Proxy单点登录,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"启用禁用Proxy单点登录"
id=>proxy_server,name=>代理服务器地址列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入Proxy代理服务器地址列表，多个地址以&隔开"
id=>enable_pop3,name=>启用Pop3单点登录,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"启用禁用Pop3单点登录"
id=>pop3_server,name=>邮件代理服务器地址列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入邮件服务器地址列表，多个地址以&隔开"
id=>enable_web,name=>启用Web单点登录,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"启用禁用Web单点登录"
id=>web_server,name=>Web认证服务器,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入Web认证服务器地址"
id=>server_opt,name=>启用认证重定向,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否使用认证重定向到此Web认证服务器"
id=>form,name=>用户表单名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入用户表单名称"
id=>keyword_opt,name=>认证关键字选项,type=>s,must=>false,default=>"认证成功关键字",value=>"认证成功关键字|认证失败关键字",descrip=>"选择认证的关键字"
id=>success,name=>成功关键字,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入认证成功的关键字"
id=>failure,name=>失败关键字,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入认证失败的关键字"
id=>enable_mirror,name=>启用镜像网口,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"启用禁用镜像网口"
id=>mirror_list,name=>镜像网口列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入镜像网口，多个以&隔开"
id=>jump,name=>认证跳转页面,type=>s,must=>false,default=>"最近请求的页面",value=>"最近请求的页面|注销页面|自定义页面URL",descrip=>"选择认证通过后，跳转页面"
id=>custom_url,name=>自定义页面URL,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入用户自定义页面的URL"
id=>conflict,name=>认证冲突,type=>s,must=>false,default=>"提示账号在其他IP上登录，不注销以前的登录",value=>"强制注销以前的登录，在当前IP上认证通过|提示账号在其他IP上登录，不注销以前的登录",descrip=>"认证冲突选项"
id=>enable_snmp,name=>启用SNMP设置,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"启用禁用SNMP设置"
id=>timeout,name=>访问SNMP超时设置,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"访问SNMP服务器的超时设置（秒）"
id=>interval,name=>访问SNMP时间间隔,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"访问SNMP服务器的时间间隔（秒）"
id=>server_snmp,name=>SNMP服务器列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"输入SNMP服务器，多个以&隔开"
id=>enable_autologout,name=>启用自动注销,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否自动注销指定时间内无流量的已认证用户"
id=>logout_time,name=>无流量时间,type=>s,must=>false,default=>"120",value=>"{text}",descrip=>"无流量时间（分钟）"
id=>post,name=>采用POST方式提交,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否采用POST方式提交用户名与密码"
id=>dns,name=>允许访问DNS服务,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"用户未通过认证前，是否允许访问DNS服务"
id=>base,name=>访问基本服务,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"未通过认证用户是否可以访问基本服务"
id=>chkmac,name=>MAC地址变动认证,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"mac地址发生变动时，是否需要重新认证"
id=>authfail,name=>启用冻结认证,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"冻结认证失败次数超过最大值的用户"
id=>times,name=>冻结失败最大值,type=>s,must=>false,default=>"2",value=>"{text}",descrip=>"冻结失败最大值（次）"
id=>minutes,name=>冻结时间,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"冻结时间（分钟）"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|认证区域不存在",descrip=>""
=end
      def edit_authenticate_option( hash )
        ATT::KeyLog.debug("编辑用户认证选项......")
        post_hash = get_edit_authenticate_option_post_hash( hash )
        result_hash = AF::Login.get_session().post(UserAuthenticateCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("编辑用户认证选项错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      
    end
  end
end
