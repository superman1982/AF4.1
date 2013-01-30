# coding: utf8
=begin rdoc
作用: IPS页面配置
维护记录:
维护人      时间                  行为
gsj     2012-05-11                     创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module Ips


=begin rdoc
类名: IPS页面配置
描述: IPS页面配置
=end
    class IpsRule < ATT::Base

=begin rdoc
关键字名: 新增IPS策略
描述: 新增IPS策略
维护人: gsj
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"IPS策略名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此IPS规则"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>dest_zone,name=>目的区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"目的区域,多个时使用&分割"
id=>dest_ipgs,name=>目的IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"目的IP组,多个时使用&分割"
id=>enable_server,name=>保护服务器,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选'保护服务器'"
id=>server_holes,name=>服务器漏洞,type=>s,must=>false,default=>"worm&network_device&database&backdoor&trojan&spyware&web&media&dns&ftp&mail&tftp&system&telnet&shellcode",value=>"{text}",descrip=>"服务器漏洞类型,可选的漏洞类型含:worm,network_device,database,backdoor,trojan,spyware,web,media,dns,ftp,mail,tftp,system,telnet,shellcode,多个时使用&分割"
id=>enable_client,name=>保护客户端,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选'保护客户端'"
id=>client_holes,name=>客户端漏洞,type=>s,must=>false,default=>"worm&file&backdoor&trojan&spyware&application&web_browse&system&shellcode&web_activex",value=>"{text}",descrip=>"客户端漏洞类型,可选的漏洞类型含:worm,file,backdoor,trojan,spyware,application,web_browse,system,shellcode,web_activex,多个时使用&分割"
id=>operation,name=>动作,type=>s,must=>false,default=>"拒绝",value=>"允许|拒绝",descrip=>"拒绝还是允许"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用勾选记录日志"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>""
=end
      def add_ips_rule(hash)
        ATT::KeyLog.debug("新增IPS策略......")
        post_hash = get_add_ips_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(IPSCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑IPS策略
描述: 编辑IPS策略
维护人: gsj
参数:
id=>oldname,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"需要编辑的IPS策略名称"
id=>name,name=>新名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"IPS策略名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此IPS规则"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>dest_zone,name=>目的区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"目的区域,多个时使用&分割"
id=>dest_ipgs,name=>目的IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"目的IP组,多个时使用&分割"
id=>enable_server,name=>保护服务器,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选'保护服务器'"
id=>server_holes,name=>服务器漏洞,type=>s,must=>false,default=>"worm&network_device&database&backdoor&trojan&spyware&web&media&dns&ftp&mail&tftp&system&telnet&shellcode",value=>"{text}",descrip=>"服务器漏洞类型,可选的漏洞类型含:worm,network_device,database,backdoor,trojan,spyware,web,media,dns,ftp,mail,tftp,system,telnet,shellcode,不选时不用选这个，多个时使用&分割"
id=>enable_client,name=>保护客户端,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选'保护客户端'"
id=>client_holes,name=>客户端漏洞,type=>s,must=>false,default=>"worm&file&backdoor&trojan&spyware&application&web_browse&system&shellcode&web_activex",value=>"{text}",descrip=>"客户端漏洞类型,可选的漏洞类型含:worm,file,backdoor,trojan,spyware,application,web_browse,system,shellcode,web_activex,不选时不用选这个，多个时使用&分割"
id=>operation,name=>动作,type=>s,must=>false,default=>"拒绝",value=>"允许|拒绝",descrip=>"拒绝还是允许"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用勾选记录日志"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>""
=end
      def edit_ips(hash)
        ATT::KeyLog.debug("编辑IPS策略......")
        post_hash = get_edit_ips_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(IPSCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除IPS策略
描述: 删除所有或指定的IPS策略
维护人: gsj
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的IPS策略,还是删除目前所有的IPS策略"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的IPS策略名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_ips(hash)
        ATT::KeyLog.debug("删除IPS策略......")
        if hash[:delete_type] == "全部删除"
          all_ips_policy_names = DeviceConsole::get_all_object_names(IPSCGI, "IPS策略") # 获取所有IPS策略的名称,数组类型
        else
          all_ips_policy_names = hash[:names].to_s.split("&") # 数组类型
        end
        post_hash = {"opr" => "delete", "name" => all_ips_policy_names }
        result_hash = AF::Login.get_session().post(IPSCGI, post_hash)
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