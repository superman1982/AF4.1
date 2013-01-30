# coding: utf8
module DeviceConsole
  module Ips
    module IpsRuleHelper

      # 新增IPS策略时要post的数据
      def get_add_ips_rule_post_hash( hash )
        data_hash = get_add_and_edit_ips_rule_common_post_hash( hash )

        post_hash = {"opr" => "add", "data" => data_hash}
        return post_hash
      end

      # 编辑IPS策略时要post的数据
      def get_edit_ips_rule_post_hash( hash )
        data_hash = get_add_and_edit_ips_rule_common_post_hash( hash )
        
        post_hash = {"opr" => "modify", "oldName" => hash[:oldname],"data" => data_hash}
        return post_hash
      end

      # 新增或编辑IPS策略时要post的公共数据
      def get_add_and_edit_ips_rule_common_post_hash( hash )
        if(hash[:name] == "")
          hash[:name] = hash[:oldname]
        end
        data_hash = {}
        data_hash["name"] = hash[:name]
        data_hash["desc"] = hash[:description]
        data_hash["src"] = { "src_zone" => hash[:source_zone].gsub(/&/, ",") }
        data_hash["dst"] = { "dst_zone" => hash[:dest_zone].gsub(/&/, ","), "dst_ipg" => hash[:dest_ipgs].gsub(/&/, ",") }

        data_hash["option"] = {"server" => false, "server_bug_list" => [], "client" => false, "client_bug_list" => [] }
        data_hash["option"]["server"] = hash[:enable_server].to_logic
        data_hash["option"]["server_bug_list"] = get_bug_list(hash[:server_holes])
        data_hash["option"]["client"] = hash[:enable_client].to_logic
        data_hash["option"]["client_bug_list"] = get_bug_list(hash[:client_holes])

        data_hash["opr"] = {"isaccept" => "", "accept" => false, "block" => false, "isloglabel" => [], "islog" => { "enable" => false }}
        if hash[:operation] == "拒绝"
          data_hash["opr"]["block"] = true
          data_hash["opr"]["isaccept"] = "block"
        else
          data_hash["opr"]["accept"] = true
          data_hash["opr"]["isaccept"] = "accept"
        end
        if hash[:record_log] == "是"
          data_hash["opr"]["isloglabel"] << "islog"
          data_hash["opr"]["islog"]["enable"] = true
        end

        data_hash["enable"] = hash[:enable].to_logic
        
        return data_hash
      end

      # hole_types 的值格式如'worm&network_device&database&backdoor&trojan&spyware&web&media&dns&ftp&mail&tftp&system&telnet&shellcode'
      def get_bug_list( hole_types )
        result_array = []
        hole_type_name_array = hole_types.split("&")
        hole_type_name_array.each do |hole_type_name|
          hole_type_id = hole_type_name.to_hole_type_id
          tmp_hash = {"id" => hole_type_id, "name" => hole_type_name}
          result_array << tmp_hash
        end
        return result_array
      end
      
    end
  end
end
