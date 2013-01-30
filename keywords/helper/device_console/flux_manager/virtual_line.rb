# coding: utf-8
module DeviceConsole
  module FluxManager
    module VirtualLineHelper
      def get_add_vline_hash(hash)
        result_hash = {"opr" => "addLine"}
        result_hash["data"] = get_vline_data_hash(hash)
        return result_hash
      end
      def get_edit_vline_hash(hash)
        result_hash = {"opr" => "modifyLine"}
        result_hash["data"] = get_vline_data_hash(hash)
        return result_hash
      end
      def get_del_vline_hash(hash)
        result_hash = {"opr" => "deleteLine"}
        result_hash["line"] = hash[:line_num].to_i
        return result_hash
      end
      def get_vline_data_hash(hash)
        data_hash = {}
        data_hash["line"] = hash[:line_num] if hash[:line_num] != nil and hash[:line_num] != ""
        data_hash["name"] = "线路" + hash[:line_num] if hash[:line_num] != nil and hash[:line_num] != ""
        data_hash["out_eth"] = hash[:out_eth]
        data_hash["up"] = hash[:up]
        data_hash["down"] = hash[:down]
        return data_hash
      end

      def get_add_vline_rule_hash(hash)
        result_hash = {"opr" => "add"}
        result_hash["data"] = get_vline_rule_data_hash(hash)
        return result_hash
      end
      def get_edit_vline_rule_hash(hash)
        result_hash = {"opr" => "modify"}
        result_hash["data"] = get_vline_rule_data_hash(hash)
        return result_hash
      end
      def get_del_vline_rule_hash(hash)
        result_hash = {"opr" => "delete"}
        list_hash = {"opr" => "list","start" =>0,"limit" => 50}
        case hash[:name]
        when "全部删除"
          result_hash["name"] = DeviceConsole::get_all_object_attrib(FluxVlineCGI,"删除虚拟线路规则","name",{"list_hash" => list_hash})
        else
          hash[:name].split("@;@").each{|id|
            result_hash["name"] = []
            result_hash["name"] << DeviceConsole::get_all_object_attrib(FluxVlineCGI,"删除虚拟线路规则","name",{"list_hash" => list_hash})[id.to_i - 1]
          }
        end
        return result_hash
      end

      def get_vline_rule_data_hash(hash)
        data_hash = {"name" => ""}
        list_hash = {"opr" => "list","start" =>0,"limit" => 50}
        data_hash["name"] = DeviceConsole::get_all_object_attrib(FluxVlineCGI,"编辑虚拟线路规则","name",{"list_hash" => list_hash})[hash[:name].to_i - 1] if hash[:name]!=nil and hash[:name] != ""
        data_hash["protocol"] = { "type" => hash[:type].downcase, "number" => hash[:proto_num]}
        data_hash["protocol"]["number"] = "" if hash[:type] != "其他"
        data_hash["lan"] = {}
        data_hash["lan"]["specified_ip"] = {}
        data_hash["lan"]["specified_port"] = {}
        if hash[:lan_ip] == "所有IP"
          data_hash["lan"]["lan_ip"] = "all_ip"
          data_hash["lan"]["all_ip"] = true
          data_hash["lan"]["specified_ip"]["enable"] = false
        elsif hash[:lan_ip] == "指定IP范围"
          data_hash["lan"]["lan_ip"] = "specified_ip"
          data_hash["lan"]["all_ip"] = false
          data_hash["lan"]["specified_ip"]["enable"] = true
        end
        if hash[:lan_port] == "所有端口"
          data_hash["lan"]["lan_port"] = "all_port"
          data_hash["lan"]["all_port"] = true
          data_hash["lan"]["specified_port"]["enable"] = false
        elsif hash[:lan_port] == "指定端口范围"
          data_hash["lan"]["lan_port"] = "specified_port"
          data_hash["lan"]["all_port"] = false
          data_hash["lan"]["specified_port"]["enable"] = true
        end
        data_hash["lan"]["specified_ip"]["ip_range"] = hash[:lan_ip_range]
        data_hash["lan"]["specified_port"]["port_range"] = hash[:lan_port_range]
        
        data_hash["wan"] = {}
        data_hash["wan"]["specified_ip"] = {}
        data_hash["wan"]["specified_port"] = {}
        if hash[:wan_ip] == "所有IP"
          data_hash["wan"]["wan_ip"] = "all_ip"
          data_hash["wan"]["all_ip"] = true
          data_hash["wan"]["specified_ip"]["enable"] = false
        elsif hash[:wan_ip] == "指定IP范围"
          data_hash["wan"]["wan_ip"] = "specified_ip"
          data_hash["wan"]["all_ip"] = false
          data_hash["wan"]["specified_ip"]["enable"] = true
        end
        if hash[:wan_port] == "所有端口"
          data_hash["wan"]["wan_port"] = "all_port"
          data_hash["wan"]["all_port"] = true
          data_hash["wan"]["specified_port"]["enable"] = false
        elsif hash[:wan_port] == "指定端口范围"
          data_hash["wan"]["wan_port"] = "specified_port"
          data_hash["wan"]["all_port"] = false
          data_hash["wan"]["specified_port"]["enable"] = true
        end
        data_hash["wan"]["specified_ip"]["ip_range"] = hash[:wan_ip_range]
        data_hash["wan"]["specified_port"]["port_range"] = hash[:wan_port_range]

        data_hash["line"] = {"target_line" => hash[:target_line], "bridge_list" => hash[:target_line]}
        return data_hash
      end
    end
  end
end
