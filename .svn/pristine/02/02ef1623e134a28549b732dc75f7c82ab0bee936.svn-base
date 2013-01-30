# encoding: utf-8
=begin rdoc
作用: 防篡改页面配置
维护记录:
维护人      时间                  行为
[张文杰]     2012-12-19                     创建
=end

module DeviceConsole

  module ServerProtection


=begin rdoc
类名: 网站篡改防护
描述: 操作网站篡改防护的页面
=end
    class Tamper < ATT::Base

=begin rdoc
关键字名: 启禁防篡改功能
描述: 启禁防篡改功能
维护人: 张文杰
参数:
id=>enable_type,name=>操作类型,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"指定操作,是启用还是禁用"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def enable_disable_tamper(hash={})
        post_hash = {"opr" => "submitEnable","data" => {"enable" => hash[:enable_type] == "启用"}}
        result_hash = AF::Login.get_session().post(TamperCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("启用或禁用防篡改功能..错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增防篡改策略
描述: 新增防篡改策略
维护人: 王沃伦
参数:
id=>name,name=>策略名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"策略的名称"
id=>is_enable,name=>是否启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"指定操作,是启用还是禁用"
id=>url,name=>起始URL,type=>s,must=>false,default=>"http://www.sinfor.com",value=>"{text}",descrip=>"策略的起始URL"
id=>protect_server,name=>网站服务器,type=>s,must=>false,default=>"www.sinfor.com@_@192.168.0.1",value=>"{text}",descrip=>"指定防护的服务器,每个服务器之间用 '@;@' 隔开,一个服务器带两个信息,分别是域名,IP,两者用 '@_@'隔开"
id=>guard_level,name=>防护深度,type=>s,must=>false,default=>"5",value=>"1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20",descrip=>"最大防护的深度"
id=>guard_method,name=>篡改检测方式,type=>s,must=>false,default=>"精确匹配",value=>"精确匹配|模糊低|模糊中|模糊高",descrip=>"指定匹配的方法"
id=>is_check_guard_file,name=>是否检测资源文件篡改,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"指定是不是检测资源文件篡改"
id=>is_check_hotlink,name=>是否检测黑链,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"指定是不是检测黑链"
id=>is_alarm,name=>是否启用通知管理员,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"指定是不是检测黑链"
id=>alarm_email,name=>告警邮件,type=>s,must=>false,default=>"just_test@sinfor.com",value=>"{text}",descrip=>"指定告警邮件的接收者"
id=>alarm_sms,name=>告警短信,type=>s,must=>false,default=>"13729814897",value=>"{text}",descrip=>"指定告警短信发送的接收者"
id=>is_deter_visit_action,name=>是否阻止用户访问,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"指定是不是阻止用户访问"
id=>deter_visit_action,name=>指定阻止操作,type=>s,must=>false,default=>"提示页面",value=>"提示页面|重定向",descrip=>"单选钩子指定阻止操作"
id=>tippage,name=>提示页面,type=>s,must=>false,default=>"default.html",value=>"{text}",descrip=>"指定提示页面"
id=>redirect_url,name=>重定向URL,type=>s,must=>false,default=>"http://127.0.0.1",value=>"{text}",descrip=>"指定重定向的URL"
id=>is_enable_log,name=>是否启用记录日志,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"指定是不是记录日志"
id=>is_enable_manager,name=>是否启用网站维护管理员,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用网站维护管理员"
id=>manager_name,name=>网站维护管理员,type=>s,must=>false,default=>"admin",value=>"{text}",descrip=>"指定网站维护的管理员"
#id=>def_url,name=>网站维护页面,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"指定网站维护的页面"
id=>setting_page,name=>高级设置根目录页面,type=>s,must=>false,default=>"index.htm@;@index.html@;@index.asp@;@index.aspx@;@index.jsp@;@index.php@;@default.htm@;@default.html@;@default.asp@;@default.aspx@;@default.jsp@;@default.php",value=>"{text}",descrip=>"指定高级配置中的根默认页面,每个页面的配置之间用'@;@'隔开,前台配置的','号在这里应该转成'@;@'"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def add_tamper_policy(hash={})
        json_hash = get_add_tamper_hash(hash)
        DeviceConsole::check_post_result(TamperCGI,json_hash,{"info" => "新增防篡改策略"})
      end
      
=begin rdoc
关键字名: 删除防篡改策略
描述: 删除防篡改策略
维护人: 王沃伦
参数:
id=>name,name=>策略名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"策略的名字,以@;@作为分隔符号分隔,不支持全部删除"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def del_tamper_policy(hash={})
        json_hash = get_del_tamper_hash(hash)
        DeviceConsole::check_post_result(TamperCGI,json_hash,{"info" => "删除防篡改策略"})
      end

=begin rdoc
关键字名: 编辑防篡改策略
描述: 编辑防篡改策略
维护人: 王沃伦
参数:
id=>name,name=>策略名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"策略的名称"
id=>is_enable,name=>是否启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"指定操作,是启用还是禁用"
id=>url,name=>起始URL,type=>s,must=>false,default=>"http://www.sinfor.com",value=>"{text}",descrip=>"策略的起始URL"
id=>protect_server,name=>网站服务器,type=>s,must=>false,default=>"www.sinfor.com@_@192.168.0.1",value=>"{text}",descrip=>"指定防护的服务器,每个服务器之间用 '@;@' 隔开,一个服务器带两个信息,分别是域名,IP,两者用 '@_@'隔开"
id=>guard_level,name=>防护深度,type=>s,must=>false,default=>"5",value=>"1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20",descrip=>"最大防护的深度"
id=>guard_method,name=>篡改检测方式,type=>s,must=>false,default=>"精确匹配",value=>"精确匹配|模糊低|模糊中|模糊高",descrip=>"指定匹配的方法"
id=>is_check_guard_file,name=>是否检测资源文件篡改,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"指定是不是检测资源文件篡改"
id=>is_check_hotlink,name=>是否检测黑链,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"指定是不是检测黑链"
id=>is_alarm,name=>是否启用通知管理员,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"指定是不是检测黑链"
id=>alarm_email,name=>告警邮件,type=>s,must=>false,default=>"just_test@sinfor.com",value=>"{text}",descrip=>"指定告警邮件的接收者"
id=>alarm_sms,name=>告警短信,type=>s,must=>false,default=>"13729814897",value=>"{text}",descrip=>"指定告警短信发送的接收者"
id=>is_deter_visit_action,name=>是否阻止用户访问,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"指定是不是阻止用户访问"
id=>deter_visit_action,name=>指定阻止操作,type=>s,must=>false,default=>"提示页面",value=>"提示页面|重定向",descrip=>"单选钩子指定阻止操作"
id=>tippage,name=>提示页面,type=>s,must=>false,default=>"default.html",value=>"{text}",descrip=>"指定提示页面"
id=>redirect_url,name=>重定向URL,type=>s,must=>false,default=>"http://127.0.0.1",value=>"{text}",descrip=>"指定重定向的URL"
id=>is_enable_log,name=>是否启用记录日志,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"指定是不是记录日志"
id=>is_enable_manager,name=>是否启用网站维护管理员,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用网站维护管理员"
id=>manager_name,name=>网站维护管理员,type=>s,must=>false,default=>"admin",value=>"{text}",descrip=>"指定网站维护的管理员"
#id=>def_url,name=>网站维护页面,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"指定网站维护的页面"
id=>setting_page,name=>高级设置根目录页面,type=>s,must=>false,default=>"index.htm@;@index.html@;@index.asp@;@index.aspx@;@index.jsp@;@index.php@;@default.htm@;@default.html@;@default.asp@;@default.aspx@;@default.jsp@;@default.php",value=>"{text}",descrip=>"指定高级配置中的根默认页面"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def edit_tamper_policy(hash={})
        json_hash = get_edit_tamper_hash(hash)
        DeviceConsole::check_post_result(TamperCGI,json_hash,{"info" => "修改防篡改策略"})
      end
      #end of class Tamper
    end
    #don't add any code after here.

  end

end
