# coding: utf-8
module DeviceConsole
  module ObjectDefinition
    module FileGroupHelper
      #获取新增URL分类库时要post的hash
      def get_add_file_group_post_hash(hash)
        data_hash = {"id" => "","name" => hash[:group_name],"depict" => hash[:description],"type" => ""}
        data_hash["type"] = hash[:type].split("&").join("\n")      
        post_hash = {"opr" => "add", "data"=> data_hash}
        return post_hash
      end
       def get_all_file_group_names()
        names = [] # 存放所有IP组的名称
        all_file_groups = DeviceConsole::list_all_objects(ObjectFileCGI, "文件类型组") # list_all_ip_groups
        all_file_groups.each do |file_group|
          names << file_group["name"] unless file_group["creator"] == ""
        end
        ATT::KeyLog.debug("所有文件类型组的名称:#{names.join(',')}")
        return names
      end
    end
  end
end
