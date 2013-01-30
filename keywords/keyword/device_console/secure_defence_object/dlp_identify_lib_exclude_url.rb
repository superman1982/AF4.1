# coding: utf8
=begin rdoc
作用: 增删改DLP排除URL
维护记录:
维护人      时间                  行为
[王沃伦]     2012-08-25                     创建
=end

module DeviceConsole

  module SecureDefenceObject


=begin rdoc
类名: 数据泄密防护识别库_排除URL
描述: 对应页面的数据防泄密里的白名单的排除URL增删改
=end
    class DlpIdentifyLibExcludeUrl < ATT::Base

=begin rdoc
关键字名: 新增排除URL
描述: 新增排除URL
维护人: 王沃伦
参数:
id=>exclude_url,name=>排除URL列表,type=>s,must=>false,default=>"1.1.1.1",value=>"{text}",descrip=>"配置的排除URL地址列表,多个时用&号隔开"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def new_dlp_exclude_url(hash={})
        ATT::KeyLog.debug("新增排除URL......")
        post_hash = get_add_exclude_url_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(EXCLUDE_URL_CGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("新增排除URL..错误消息是#{result_hash["msg"]}")
          return_fail
        end  
      end

=begin rdoc
关键字名: 编辑排除URL
描述: 编辑排除URL
维护人: 王沃伦
参数:
id=>name,name=>旧URL,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"编辑的原URL"
id=>exclude_url,name=>排除URL列表,type=>s,must=>false,default=>"1.1.1.1",value=>"{text}",descrip=>"配置的排除URL地址列表,多个时用&号隔开"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def edit_dlp_exclude_url(hash={})
        ATT::KeyLog.debug("编辑排除URL......")
        post_hash = get_edit_exclude_url_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(EXCLUDE_URL_CGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("编辑排除URL..错误消息是#{result_hash["msg"]}")
          return_fail
        end  
      end

=begin rdoc
关键字名: 删除排除URL
描述: 删除排除URL
维护人: 王沃伦
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的排除URL,还是删除目前所有的排除URL"
id=>names,name=>URL列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的排除URL,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def del_dlp_exclude_url(hash={})
        ATT::KeyLog.debug("删除排除URL......")
        if hash[:delete_type] == "全部删除"
          all_dlp_exclude_url_policy_keys = DeviceConsole::get_all_object_attrib(EXCLUDE_URL_CGI, "DLP排除URL", "excldURL") # 获取所有DLP自定义敏感信息的名称,数组类型
        else
          all_dlp_exclude_url_policy_keys = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_dlp_exclude_url_policy_keys.size == 0
        post_hash = {"opr" => "delete", "name" => all_dlp_exclude_url_policy_keys }
        result_hash = AF::Login.get_session().post(EXCLUDE_URL_CGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("删除排除URL...错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end


      #end of class DlpIdentifyLibExcludeUrl
    end
    #don't add any code after here.

  end

end
