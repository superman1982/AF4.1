# encoding: utf-8
=begin rdoc
作用: 封装对象定义下文件类型组的操作
维护记录:
维护人      时间                  行为
[zwjie]     2012-12-28                     创建
=end

module DeviceConsole

  module ObjectDefinition


=begin rdoc
类名: 文件类型组
描述: 文件类型组
=end
    class FileGroup < ATT::Base

=begin rdoc
关键字名: 新增文件类型组
描述: 新增文件类型组
维护人: zwjie
参数:
id=>group_name,name=>文件类型组名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"文件类型组名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"文件类型组描述"
id=>type,name=>文件类型,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"文件类型,多个时使用&分割,如.mp3&.mv"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def add_file_group(hash={})
        ATT::KeyLog.debug("add file group......")
        post_hash = get_add_file_group_post_hash( hash )
        result_hash = AF::Login.get_session().post(ObjectFileCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除文件类型组
描述: 删除文件类型组
维护人: zwjie
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的文件类型,还是删除目前除'内置'外的所有文件类型"
id=>group_names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的文件类型名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_file_group(hash={})
        ATT::KeyLog.debug("delete url library......")
        if hash[:delete_type] == "全部删除"
          all_file_group_names = get_all_file_group_names() # 数组类型,不包含'全部'IP组
        else
          all_file_group_names = hash[:group_names].to_s.split("&") # 数组类型
        end
        return_ok if all_file_group_names.empty?
        post_hash = {"opr" => "delete", "name" => all_file_group_names}
        result_hash = AF::Login.get_session().post(ObjectFileCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end


      #end of class FileGroup
    end
    #don't add any code after here.

  end

end
