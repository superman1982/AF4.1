# coding: utf8
module DeviceConsole
  module SecureDefenceObject
    module DlpIdentifyLibHelper
      # 新增自定义敏感信息时要post的数据
      def get_add_def_dlp_rule_post_hash( hash )
        data_hash = get_add_or_edit_def_dlp_rule_post_hash( hash )

        post_hash = {"opr" => "add", "data" => data_hash}
        return post_hash
      end

      # 编辑自定义敏感信息时要post的数据
      def get_edit_def_dlp_rule_post_hash( hash )
        data_hash = get_add_or_edit_def_dlp_rule_post_hash( hash )
        
        post_hash = {"opr" => "modify", "data" => data_hash}
        return post_hash
      end

      # 新增或编辑自定义敏感信息时要post的数据
      def get_add_or_edit_def_dlp_rule_post_hash( hash )
        data_hash = {}
        data_hash["name"] = hash[:name]
        data_hash["descript"] = "woolenTest"
        data_hash["expression"] = hash[:suspic]


        return data_hash
      end

    end
  end
end
