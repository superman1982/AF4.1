# coding: utf-8
module DeviceConsole
  module ObjectDefinition
    module UrlLibraryHelper
      #获取新增URL分类库时要post的hash
      def get_add_url_library_post_hash(hash)
        data_hash = {"id" => "","name" => hash[:group_name],"depict" => hash[:description],"url" => "","keyword" => ""}
        data_hash["url"] = hash[:url].split("&").join("\n")
        data_hash["keyword"] = hash[:keyword].split("&").join("\n")
        post_hash = {"opr" => "add", "data"=> data_hash}
        return post_hash
      end
       def get_all_url_library_names()
        names = [] # 存放所有IP组的名称
        all_url_groups = DeviceConsole::list_all_objects(ObjectURLCGI, "URL分类库") # list_all_ip_groups
        all_url_groups.each do |url_group|
          names << url_group["name"] unless url_group["inside"]
        end
        ATT::KeyLog.debug("所有URL分类库的名称:#{names.join(',')}")
        return names
      end
    end
  end
end
