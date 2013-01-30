# coding: utf8
module DeviceConsole
  module ContentSecurity
    module WebFiltrationHelper
      #构造URL过滤json数据格式
      def create_url_json_hash(hash)
        src_hash = {"src_zone" => "", "ip_user_group" => "", "ip_group" => {"src_ip" => "", "enable" => false },\
            "user_group" => { "src_user" => { "org" => "", "itemName" => "" }, "enable" => false }}
        src_hash["src_zone"] = hash[:source_zone].split("&").join(",")
        if hash[:source_group_type] == "IP组"
          src_hash["ip_user_group"] = "ip_group"
          src_hash["ip_group"]["src_ip"] = hash[:source_ip].split("&").join(",")
          src_hash["ip_group"]["enable"] = true
        elsif hash[:source_group_type] == "用户组"
          src_hash["ip_user_group"] = "user_group"
          src_hash["user_group"]["enable"] = true
          src_hash["user_group"]["src_user"]["org"] = hash[:source_user].split("&").join(",")
        end
        # URL分类,初始值,下面再修改
        dst_hash = {"dst_url_type"=>"", "request_type"=>[],"http_get"=>false,"http_post"=>false, "https"=>false }
        dst_hash["dst_url_type"] = hash[:url_type].split("&").join(",")
        if hash[:http_get] == "是"
          dst_hash["request_type"] << "http_get"
          dst_hash["http_get"] = true
        end
        if hash[:http_post] == "是"
          dst_hash["request_type"] << "http_post"
          dst_hash["http_post"] = true
        end
        if hash[:https] == "是"
          dst_hash["request_type"] << "https"
          dst_hash["https"] = true
        end
        if(hash[:name] == "")
            hash[:name] = hash[:oldname]
        end
        status_hash = {"name" => hash[:name], "description" => hash[:description], "enable" => hash[:enable].to_logic,\
            "log" => hash[:record_log].to_logic, "src" => src_hash, "dst" => dst_hash }
        status_hash["active_time"] = DeviceConsole::convert_active_time(hash[:take_effect_time]) # 生效时间
        # 动作,初始值,下面再修改
        status_hash["action_group"] = ""
        status_hash["allow"] = {"enable" => false}
        status_hash["reject"] = {"enable" => false}
        if hash[:operation] == "允许"
          status_hash["action_group"] = "allow"
          status_hash["allow"]["enable"] = true
        elsif hash[:operation] == "拒绝"
          status_hash["action_group"] = "reject"
          status_hash["reject"]["enable"] = true
        end
        return status_hash
      end

      # 获取新增URL过滤规则时要post的数据
      def get_add_url_filtration_rule_post_hash( hash )
        status_hash = create_url_json_hash(hash)
        post_hash = {"opr" => "add", "data" => { "status" => status_hash }}
        return post_hash
      end
      #获取编辑URL过滤规则时要post的数据
      def get_edit_url_filtration_rule_post_hash(hash)
        status_hash = create_url_json_hash(hash)
        post_hash = {"opr" => "modify", "oldName" => hash[:oldname], "data" => { "status" => status_hash }}
        return post_hash
      end
      #构造文件过滤json数据格式
      def create_file_json_hash(hash)
        src_hash = {"src_zone" => "", "ip_user_group" => "", "ip_group" => {"src_ip" => "", "enable" => false },\
            "user_group" => { "src_user" => { "org" => "", "itemName" => "" }, "enable" => false }}
        src_hash["src_zone"] = hash[:source_zone].split("&").join(",")
        if hash[:source_group_type] == "IP组"
          src_hash["ip_user_group"] = "ip_group"
          src_hash["ip_group"]["src_ip"] = hash[:source_ip].split("&").join(",")
          src_hash["ip_group"]["enable"] = true
        elsif hash[:source_group_type] == "用户组"
          src_hash["ip_user_group"] = "user_group"
          src_hash["user_group"]["enable"] = true
          src_hash["user_group"]["src_user"]["org"] = hash[:source_user].split("&").join(",")
        end
        # URL分类,初始值,下面再修改
        dst_hash = {"dst_filetype"=>"", "action_type"=>[],"upload"=>false,"download"=>false}
        dst_hash["dst_filetype"] = hash[:file_type].split("&").join(",")
        if hash[:up] == "是"
          dst_hash["action_type"] << "upload"
          dst_hash["upload"] = true
        end
        if hash[:down] == "是"
          dst_hash["action_type"] << "download"
          dst_hash["download"] = true
        end
        if(hash[:name] == "")
            hash[:name] = hash[:oldname]
        end
        status_hash = {"name" => hash[:name], "description" => hash[:description], "enable" => hash[:enable].to_logic,\
            "log" => hash[:record_log].to_logic, "src" => src_hash, "dst" => dst_hash }
        status_hash["active_time"] = DeviceConsole::convert_active_time(hash[:take_effect_time]) # 生效时间
        # 动作,初始值,下面再修改
        status_hash["action_group"] = ""
        status_hash["allow"] = {"enable" => false}
        status_hash["reject"] = {"enable" => false}
        if hash[:operation] == "允许"
          status_hash["action_group"] = "allow"
          status_hash["allow"]["enable"] = true
        elsif hash[:operation] == "拒绝"
          status_hash["action_group"] = "reject"
          status_hash["reject"]["enable"] = true
        end
        return status_hash
      end
      #获取新增文件过滤规则时要post的数据
      def get_add_file_filtration_rule_post_hash(hash)
        status_hash = create_file_json_hash(hash)
        post_hash = {"opr" => "add", "data" => { "status" => status_hash }}
        return post_hash
      end
      def get_edit_file_filtration_rule_post_hash(hash)
        status_hash = create_file_json_hash(hash)
        post_hash = {"opr" => "modify","oldName" => hash[:oldname], "data" => { "status" => status_hash }}
        return post_hash
      end

      
    end
  end
end
