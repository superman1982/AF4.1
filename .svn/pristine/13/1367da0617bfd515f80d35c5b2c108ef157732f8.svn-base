# coding: utf8
=begin rdoc
作用: 封装对象定义下服务的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-07              创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module ObjectDefinition


=begin rdoc
类名: 服务
描述: 服务
=end
    class Service < ATT::Base

=begin rdoc
关键字名: 新增服务组
描述: 新增服务组
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"服务组的名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"服务组的描述"
id=>services,name=>服务,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"服务组包含的服务,如'预定义服务/any',多个时使用&分割,如'自定义服务/全部&预定义服务/any',可为空"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_service_group(hash)
        ATT::KeyLog.debug("add service group......")
        post_hash = get_add_service_group_post_hash( hash )
        result_hash = AF::Login.get_session().post(ServiceGroupCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除服务组
描述: 删除服务组
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的服务组,还是删除目前所有的服务组"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的服务组名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_service_group(hash)
        ATT::KeyLog.debug("delete service groups......")
        if hash[:delete_type] == "全部删除"
          all_service_group_names = DeviceConsole::get_all_object_names(ServiceGroupCGI, "服务组") # 数组类型
        else
          all_service_group_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_service_group_names.empty?
        post_hash = {"opr" => "delete", "name" => all_service_group_names}
        result_hash = AF::Login.get_session().post(ServiceGroupCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增自定义服务
描述: 新增自定义服务
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"自定义服务的名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"自定义服务的描述"
id=>tcp,name=>TCP端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"TCP协议的端口号或端口号范围,多个时使用&分割,如'81&82-90'"
id=>udp,name=>UDP端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"UDP协议的端口号或端口号范围,多个时使用&分割,如'81&82-90'"
id=>icmp,name=>ICMP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"ICMP协议,格式如'type:8,code:0',多个时使用&分割,如'type:8,code:0&type:9,code:1'"
id=>other,name=>其他协议号,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"其他协议号,只能填写一个协议号"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_custom_service(hash)
        ATT::KeyLog.debug("add custom service......")
        post_hash = get_add_custom_service_post_hash( hash )
        result_hash = AF::Login.get_session().post(CustomService, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除自定义服务
描述: 删除自定义服务
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的自定义服务,还是删除目前所有的自定义服务"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的自定义服务名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_custom_service(hash)
        ATT::KeyLog.debug("delete custom services......")
        if hash[:delete_type] == "全部删除"
          all_custom_service_names = DeviceConsole::get_all_object_names(CustomService, "自定义服务") # 数组类型
        else
          all_custom_service_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_custom_service_names.empty?
        post_hash = {"opr" => "delete", "name" => all_custom_service_names}
        result_hash = AF::Login.get_session().post(CustomService, post_hash)
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
