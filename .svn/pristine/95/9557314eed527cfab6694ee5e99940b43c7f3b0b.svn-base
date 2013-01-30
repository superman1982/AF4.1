# coding: utf8
module DeviceConsole
  module SecureDefenceObject
    module DlpIdentifyLibExcludeUrlHelper
      # 新增排除URL时要post的数据
      def get_add_exclude_url_rule_post_hash( hash )
        data_hash = get_add_or_edit_exclude_url_rule_post_hash( hash )

        post_hash = {"opr" => "add", "data" => data_hash}
        return post_hash
      end

      # 编辑排除URL时要post的数据
      def get_edit_exclude_url_rule_post_hash( hash )
        data_hash = get_add_or_edit_exclude_url_rule_post_hash( hash )
        
        post_hash = {"opr" => "modify", "data" => data_hash}
        return post_hash
      end

      # 新增或编辑排除URL时要post的数据
      def get_add_or_edit_exclude_url_rule_post_hash( hash )
        data_hash = {}
        data_hash["excldURL_old"] = hash[:name] ? hash[:name] : "" 
        data_hash["descript"] = "woolenAutoTest"
        data_hash["excldURL"] = hash[:exclude_url].gsub(/&/, "\n")


        return data_hash
      end
    end
  end
end
