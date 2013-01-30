# coding: utf8
=begin rdoc
作用: 自定义敏感信息的增删改
维护记录:
维护人      时间                  行为
[王沃伦]     2012-08-24                     创建
=end

module DeviceConsole

  module SecureDefenceObject


=begin rdoc
类名: 数据泄密防护识别库_敏感信息
描述: 增删改自定义的敏感信息
=end
    class DlpIdentifyLib < ATT::Base

=begin rdoc
关键字名: 新增自定义敏感信息
描述: 增加自定义敏感信息
维护人: 王沃伦
参数:
# 名称、敏感信息定义
id=>name,name=>名称,type=>s,must=>false,default=>"test",value=>"{text}",descrip=>"配置的自定义敏感信息的名称"
id=>suspic,name=>敏感信息定义,type=>s,must=>false,default=>"test",value=>"{text}",descrip=>"配置的自定义敏感信息的内容,为正则表达式"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def new_userdefine_suspic(hash={})
        ATT::KeyLog.debug("新增自定义敏感信息......")
        post_hash = get_add_def_dlp_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(USER_DEFINE_SUSPIC_CGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑自定义敏感信息
描述: 编辑自定义敏感信息
维护人: 王沃伦
参数:
id=>name,name=>名称,type=>s,must=>false,default=>"test",value=>"{text}",descrip=>"配置的自定义敏感信息的名称"
id=>suspic,name=>敏感信息定义,type=>s,must=>false,default=>"test",value=>"{text}",descrip=>"配置的自定义敏感信息的内容,为正则表达式"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def edit_userdefine_suspic(hash={})
        ATT::KeyLog.debug("编辑自定义敏感信息......")
        post_hash = get_edit_def_dlp_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(USER_DEFINE_SUSPIC_CGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除自定义敏感信息
描述: 删除自定义敏感信息
维护人: 王沃伦
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的自定义敏感信息,还是删除目前所有的自定义敏感信息"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的自定义敏感信息名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def del_userdefine_suspic(hash={})
        ATT::KeyLog.debug("删除自定义敏感信息......")
        if hash[:delete_type] == "全部删除"
          all_user_define_dlp_policy_names = DeviceConsole::get_all_object_names(USER_DEFINE_SUSPIC_CGI, "DLP自定义敏感信息") # 获取所有DLP自定义敏感信息的名称,数组类型
        else
          all_user_define_dlp_policy_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_user_define_dlp_policy_names.size == 0
        post_hash = {"opr" => "delete", "name" => all_user_define_dlp_policy_names }
        result_hash = AF::Login.get_session().post(USER_DEFINE_SUSPIC_CGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end


      #end of class DlpIdentifyLib
    end
    #don't add any code after here.

  end

end
