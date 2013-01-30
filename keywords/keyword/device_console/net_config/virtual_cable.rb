# coding: utf8
=begin rdoc
作用: 封装虚拟网线模块的关键字
维护记录:
维护人      时间                  行为
gsj      2011-12-07             创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module NetConfig


=begin rdoc
类名: 虚拟网线
描述: 虚拟网线
=end
    class VirtualCable < ATT::Base

=begin rdoc
关键字名: 新增虚拟网线
描述: 新增虚拟网线
参数:
id=>name,name=>虚拟网线名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"虚拟网线名称,不能为空"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>interface1,name=>接口一,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"虚拟网线接口一,不能为空"
id=>interface2,name=>接口二,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"虚拟网线接口二,不能为空"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_virtual_cable( hash )
        ATT::KeyLog.debug("add virtual cable......")
        post_hash = get_add_virtual_cable_post_hash( hash )
        result_hash = AF::Login.get_session().post(VirtualCableCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除虚拟网线
描述: 删除指定的虚拟网线
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的虚拟网线,还是删除目前所有的虚拟网线"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的虚拟网线名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_virtual_cable( hash )
        ATT::KeyLog.debug("delete virtual cable......")
        if hash[:delete_type] == "全部删除"
          cable_name_array = DeviceConsole::get_all_object_names(VirtualCableCGI, "虚拟网线")
        else
          cable_name_array = hash[:names].split("&") 
        end
        return_ok if cable_name_array.empty? # 已经没有任何虚拟网线了
        post_hash = {"opr" => "delete", "name" => cable_name_array }
        result_hash = AF::Login.get_session().post(VirtualCableCGI, post_hash)
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
