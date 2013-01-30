# encoding: utf-8
=begin rdoc
作用: 封装对象定义下URL分类库的操作
维护记录:
维护人      时间                  行为
[zwjie]     2012-12-27                     创建
=end

module DeviceConsole

  module ObjectDefinition


=begin rdoc
类名: URL分类库
描述: URL分类库
=end
    class UrlLibrary < ATT::Base

=begin rdoc
关键字名: 新增URL类型
描述: 新增URL类型
维护人: zwjie
参数:
id=>group_name,name=>URL组名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"URL组名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"URL组描述"
id=>url,name=>URL,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"URL,多个时使用&分割,如www.sina.com&www.baidu.com"
id=>keyword,name=>域名关键字,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"域名关键字,多个时使用&分割,如SINA&BAIDU"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>""
=end
      def add_url_library(hash={})
        ATT::KeyLog.debug("add url library......")
        post_hash = get_add_url_library_post_hash( hash )
        result_hash = AF::Login.get_session().post(ObjectURLCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除URL类型
描述: 删除URL类型
维护人: zwjie
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的URL类型,还是删除目前除'内置'外的所有URL类型"
id=>group_names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的URL类型名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_url_library(hash={})
        ATT::KeyLog.debug("delete url library......")
        if hash[:delete_type] == "全部删除"
          all_url_library_names = get_all_url_library_names() # 数组类型,不包含'全部'IP组
        else
          all_url_library_names = hash[:group_names].to_s.split("&") # 数组类型
        end
        return_ok if all_url_library_names.empty?
        post_hash = {"opr" => "delete", "name" => all_url_library_names}
        result_hash = AF::Login.get_session().post(ObjectURLCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end


      #end of class UrlLibrary
    end
    #don't add any code after here.

  end

end
