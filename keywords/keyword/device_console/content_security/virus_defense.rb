# coding: utf8
=begin rdoc
作用: 封装病毒防御策略页面上的操作
维护记录:
维护人      时间                  行为
zwj     2012-12-11                     创建
=end

module DeviceConsole

  module ContentSecurity


=begin rdoc
类名: 病毒防御策略
描述: 病毒防御策略
=end
    class VirusDefense < ATT::Base

=begin rdoc
关键字名: 编辑病毒防御策略
描述: 编辑病毒防御策略
维护人: zwjie
参数:
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用杀毒策略"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>source_group_type,name=>源用户类型,type=>s,must=>false,default=>"IP组",value=>"IP组|用户组",descrip=>"源用户选择IP组还是用户组"
id=>source_ip,name=>源IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"当源用户选择IP组时,选择的IP组,多个时使用&分割"
id=>source_user,name=>源用户组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当源用户选择用户组时,选择的用户或组,若是用户组则使用其全路径,如'/默认组/',若是用户则直接使用用户名,多个时使用&分割,格式如'/默认组/&test'"
id=>dest_zone,name=>目的区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"目的区域,多个时使用&分割"
id=>dest_ip,name=>目的IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"目的IP组,多个时使用&分割"
id=>virus_http,name=>HTTP杀毒,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用http杀毒"
id=>virus_ftp,name=>FTP杀毒,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用ftp杀毒"
id=>virus_pop3,name=>POP3杀毒,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用pop3杀毒"
id=>virus_smtp,name=>SMTP杀毒,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用smtp杀毒"
id=>virus_filetype,name=>杀毒文件类型,type=>s,must=>false,default=>"bat&com&exe&vbs",value=>"{text}",descrip=>"杀毒文件类型，多个时使用&分割"
id=>enable_url,name=>是否启用排除URL,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用排除Url"
id=>url_list,name=>排除URL列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"排除Url列表，多个时使用&分割"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用勾选记录日志"
id=>operation,name=>阻断,type=>s,must=>true,default=>"是",value=>"是|否",descrip=>"是否阻断"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def edit_virus_rule(hash)
        ATT::KeyLog.debug("add virus policy  control strategy......")
        post_hash = get_edit_virus_defense_strategy_post_hash( hash )
        result_hash = AF::Login.get_session().post(VirusDefenseCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      #end of class TestVirusDefense
    end
    #don't add any code after here.

  end

end
