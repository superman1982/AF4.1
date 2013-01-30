# coding: utf-8
module DeviceConsole
  module ServerProtection
    module TamperHelper
      def get_add_tamper_hash(hash)
        result_hash = {}
        result_hash["opr"] = "add"
        result_hash["data"] = get_commond_data_hash(hash)
        return  result_hash
      end
      def get_del_tamper_hash(hash)
        result_hash = {}
        result_hash["opr"] = "delete"
        result_hash["name"] = hash[:name].to_s.split("@;@")
        return result_hash

      end
      def get_edit_tamper_hash(hash)
        result_hash = {}
        result_hash["opr"] = "modify"
        result_hash["data"] = get_commond_data_hash(hash)
        return  result_hash
      end

      def get_commond_data_hash(hash)
        data_hash = {}
        data_hash["enable_guard"] = {}
        data_hash["enable_guard"]["enable"] = ( hash[:is_enable] == "是")
        data_hash["enable_guard"]["webname"] = hash[:name]
        data_hash["enable_guard"]["url"] = hash[:url]
        data_hash["enable_guard"]["web_server"] = {}
        data_hash["enable_guard"]["web_server"]["array"] = []
        hash[:protect_server].split("@;@").each { |server|
          server_array = server.split("@_@")
          server_hash = {}
          # => 0是server域名, 1是serverIP
          server_hash["name"] = server_array[0]
          server_hash["ip"] = server_array[1]
          #server_hash["type"] = 0
          data_hash["enable_guard"]["web_server"]["array"] << server_hash
        }
        data_hash["enable_guard"]["guard_level"] = hash[:guard_level].to_i
        data_hash["enable_guard"]["method"] = 1 if hash[:guard_method] == "精确匹配"
        data_hash["enable_guard"]["method"] = 2 if hash[:guard_method] == "模糊低"
        data_hash["enable_guard"]["method"] = 3 if hash[:guard_method] == "模糊中"
        data_hash["enable_guard"]["method"] = 4 if hash[:guard_method] == "模糊高"

        data_hash["enable_guard"]["check_hotlink"] = ( hash[:is_check_hotlink] == "是" )
        data_hash["enable_guard"]["check_guard_file"] = ( hash[:is_check_guard_file] == "是" )

        # => 网站篡改后
        data_hash["enable_guard"]["action"] = get_data_action_hash(hash)
        data_hash["enable_guard"]["manager"] = {"name" => hash[:manager_name], "def_url" => "", "enable" => (hash[:is_enable_manager] == "是")}

        # => 高级配置中的默认页面
        data_hash["enable_guard"]["setting_page"] = hash[:setting_page].gsub("@;@", ",")

        return data_hash
      end

      def get_data_action_hash(hash)
        action_hash = {}
        action_hash["send_msg"] = {"email" => hash[:alarm_email], "sms" => hash[:alarm_sms], "enable" => (hash[:is_alarm] == "是")}
        action_hash["deter_visit"] = {}
        action_hash["deter_visit"]["tip_page"] = {}
        action_hash["deter_visit"]["location"] = {}
        action_hash["deter_visit"]["enable"] = ( hash[:is_deter_visit_action] == "是" )
        if hash[:deter_visit_action] == "提示页面"
          action_hash["deter_visit"]["action"] = "tip_page"
          action_hash["deter_visit"]["tip_page"]["enable"] = true
          action_hash["deter_visit"]["location"]["enable"] = false
        elsif hash[:deter_visit_action] == "重定向"
          action_hash["deter_visit"]["action"] = "location"
          action_hash["deter_visit"]["tip_page"]["enable"] = false
          action_hash["deter_visit"]["location"]["enable"] = true
        end
        action_hash["deter_visit"]["location"]["url"] = hash[:redirect_url]
        action_hash["deter_visit"]["tip_page"]["set_tip_page"] = {"tippage" => hash[:tippage]}
        action_hash["enable_log"] = ( hash[:is_enable_log] == "是" )
        return action_hash
      end
    end
  end
end
