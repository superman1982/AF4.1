# coding: utf8
module DeviceConsole
  module System
    module LogSettingHelper

      # 设置内置数据中心
      def get_inner_dc_setting_post_hash(hash)
        local_hash = { "merge" => true, "enable" => true, 
          "del_before_days" => { "max_days" => 15,"enable" => false  },
          "del_lt_disk_percent" => {"max_percent" => 80, "enable" => false } }
        
        local_hash["enable"] = hash[:enable_inner_dc].to_logic
        if hash[:method] == "天数"
          local_hash["del_before_days"]["enable"] = true
          local_hash["del_before_days"]["max_days"] = hash[:days].to_i
        elsif hash[:method] == "磁盘空间"
          local_hash["del_lt_disk_percent"]["enable"] = true
          local_hash["del_lt_disk_percent"]["max_percent"] = hash[:percentage].to_i
        end
        local_hash["merge"] = hash[:enable_merge].to_logic
        post_hash = { "opr" => "modify", "type" => "local", "data" => {"local" => local_hash } }
        return post_hash
      end

    end
  end
end
