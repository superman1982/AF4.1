# coding: utf-8
require 'md5'
module DeviceConsole
  module FluxManager
    module PassageWayHelper
      def get_enable_disable_hash(hash)
        flag = false if hash[:enable] == "禁用"
        flag = true if hash[:enable] == "启用"
        return result_hash = {"opr" => "submit", "enable" => flag}
      end

      def get_add_passage_hash(hash)
        result_hash = {"opr" => "add"}
        result_hash["data"] = get_passage_data_hash(hash)
        return result_hash
      end
      def get_edit_passage_hash(hash)
        result_hash = {"opr" => "edit"}
        result_hash["data"] = get_passage_data_hash(hash)
        # => 下面的几行代码是使用ID来定位规则的,坑爹的ID
        filter_hash = {"filter_name" => "name", "filter_value" => hash[:name],"filter_equal" => false}
        this_id = DeviceConsole::get_all_object_attrib(FluxManagerCGI, "流控通道", "id",filter_hash)
        result_hash["data"]["channelID"] = this_id[0]
        result_hash["data"]["range"]["usergroup_obj"]["usergrp"]["itemName"] = this_id[0]
        return result_hash
      end
      def get_del_passage_hash(hash)
        result_hash = {"opr" => "delete"}
        result_hash["id"] = []
        if hash[:name] == "全部删除"
          filter_hash = {"filter_name" => "name", "filter_value" => "默认通道","filter_equal" => true}
          result_hash["id"] = DeviceConsole::get_all_object_attrib(FluxManagerCGI, "流控通道", "id",filter_hash)
        else
          hash[:name].split("@;@").each { |name|
            filter_hash = {"filter_name" => "name", "filter_value" => name,"filter_equal" => false}
            this_id = DeviceConsole::get_all_object_attrib(FluxManagerCGI, "流控通道", "id",filter_hash)
            result_hash["id"] << this_id[0]
          }
        end
        return result_hash
      end
      def get_add_exclude_hash(hash)
        result_hash = {"opr" => "addExclude"}
        result_hash["data"] = get_exclude_hash(hash)
        return result_hash
      end
      def get_edit_exclude_hash(hash)
        result_hash = {"opr" => "modifyExclude"}
        result_hash["data"] = get_exclude_hash(hash)
        return result_hash
      end
      def get_del_exclude_hash(hash)
        result_hash = {"opr" => "deleteExclude"}
        result_hash["name"] = []
        if hash[:name] == "全部删除"
          result_hash["name"] = DeviceConsole::get_all_object_attrib(FluxManagerCGI, "流控通道排除","name",{"list_hash" =>{"opr" =>"listExclude"}})
        else
          hash[:name].split("@;@").each { |name|
            result_hash["name"] << name
          }
        end
        return result_hash
      end
      
      def get_exclude_hash(hash)
        result_hash = {}
        result_hash["name"] = hash[:name]
        result_hash["type"] = hash[:type]
        result_hash["dip"] = hash[:dip]
        return result_hash
      end

      def get_passage_data_hash(hash)
        data_hash = {}
        # => 带宽通道设置 页面的数据内容
        data_hash["enable"] = ( hash[:enable] == "是" )
        data_hash["fatherID"] = ""   # => 暂时不知道这个id是干嘛使的,抓了两次都是空,暂定为永空
        data_hash["channelID"] = []   # => 暂时不知道这个id是干嘛使的,抓了两次都是空,暂定为永空
        # => 我这里是猜的,不知道它那串数字是怎么来的,感觉像MD5
        #data_hash["channelID"] << MD5.new(hash[:user_group]).to_s if hash[:user_group] != nil and hash[:user_group] != ""
        data_hash["hide"] = get_data_hide_hash(hash)
        data_hash["name"] = hash[:name]
        data_hash["line"] = hash[:line].to_i
        data_hash["type"] = get_data_type_hash(hash)
        data_hash["sip"] = get_data_sip_hash(hash)
        data_hash["advance"] = {"misc" => (hash[:is_enable_advance] == "是")}
        # => 变化了几次配置都不知道下面这个policy是具体哪个配置项,一直都不变的
        data_hash["policy"] = {"select" => "avg","avg" => true, "free" => false}

        # => 通道使用内容 页面的数据内容
        data_hash["range"] = get_data_rang_hash(hash)
        return data_hash
      end

      def get_data_hide_hash(hash)
        hide_hash = {}
        hide_hash["hide"] = {}
        hide_hash["hide"]["upmax"] = []
        hide_hash["hide"]["downmax"] = []
        hide_hash["hide"]["upsure"] = []
        hide_hash["hide"]["downsure"] = []
        hide_hash["hide"]["filetype"] = ""
        hide_hash["hide"]["url"] = ""
        hide_hash["hide"]["all"] = ""
        hide_hash["hide"]["unknown"] = ""
        hide_hash["hide"]["line_status"] = []
        return hide_hash
      end

      # => 获得 带宽通道类型中 的限制带宽和保持带宽的配置hash数据
      def get_data_type_hash(hash)
        type_hash = {}
        type_hash["guarantee"] = {}
        type_hash["guarantee"]["up"] = {}
        type_hash["guarantee"]["down"] = {}
        type_hash["limit"] = {}
        type_hash["limit"]["up"] = {}
        type_hash["limit"]["down"] = {}
        type_hash["limit"]["enable"] = false
        type_hash["guarantee"]["enable"] = false
        type_hash["type_sel"] = "limit" if hash[:passage_type] == "限制通道"
        type_hash["limit"]["enable"] = true if hash[:passage_type] == "限制通道"
        type_hash["type_sel"] = "guarantee" if hash[:passage_type] == "保证通道"
        type_hash["guarantee"]["enable"] = true if hash[:passage_type] == "保证通道"
        type_hash["guarantee"]["up"]["assured"] = hash[:ensure_up_rate].to_i if hash[:ensure_up_rate] != nil and hash[:ensure_up_rate] != ""
        type_hash["guarantee"]["up"]["upsure_speed"] = hash[:ensure_up_speed].to_i if hash[:ensure_up_speed] != nil and hash[:ensure_up_speed] != ""
        type_hash["guarantee"]["up"]["max"] = hash[:ensure_upmax_rate].to_i if hash[:ensure_upmax_rate] != nil and hash[:ensure_upmax_rate] != ""
        type_hash["guarantee"]["up"]["upmax_speed"] = hash[:ensure_upmax_speed].to_i if hash[:ensure_upmax_speed] != nil and hash[:ensure_upmax_speed] != ""
        type_hash["guarantee"]["down"]["assured"] = hash[:ensure_down_rate].to_i if hash[:ensure_down_rate] != nil and hash[:ensure_down_rate] != ""
        type_hash["guarantee"]["down"]["downsure_speed"] = hash[:ensure_down_speed].to_i if hash[:ensure_down_speed] != nil and hash[:ensure_down_speed] != ""
        type_hash["guarantee"]["down"]["max"] = hash[:ensure_downmax_rate].to_i if hash[:ensure_downmax_rate] != nil and hash[:ensure_downmax_rate] != ""
        type_hash["guarantee"]["down"]["downmax_speed"] = hash[:ensure_downmax_speed].to_i if hash[:ensure_downmax_speed] != nil and hash[:ensure_downmax_speed] != ""
        type_hash["guarantee"]["priority"] = hash[:ensure_priority]
        type_hash["limit"]["up"]["max"] = hash[:limit_upmax_rate].to_i if hash[:limit_upmax_rate] != nil and hash[:limit_upmax_rate] != ""
        type_hash["limit"]["up"]["upmax_speed"] = hash[:limit_upmax_speed].to_i if hash[:limit_upmax_speed] != nil and hash[:limit_upmax_speed] != ""
        type_hash["limit"]["down"]["max"] = hash[:limit_downmax_rate].to_i if hash[:limit_downmax_rate] != nil and hash[:limit_downmax_rate] != ""
        type_hash["limit"]["down"]["downmax_speed"] = hash[:limit_downmax_speed].to_i if hash[:limit_downmax_speed] != nil and hash[:limit_downmax_speed] != ""
        type_hash["limit"]["priority"] = hash[:limit_priority]
        return type_hash
      end

      def get_data_sip_hash(hash)
        sip_hash = {}
        sip_hash["up"] = {"max" => hash[:single_ip_up_max].to_i}
        sip_hash["down"] = {"max" => hash[:single_ip_down_max].to_i}
        sip_hash["enable"] = ( hash[:is_enable_single_ip_speed] == "是" )
        return sip_hash
      end

      # => 通道使用范围相关的配置内容
      def get_data_rang_hash(hash)
        rang_hash = {}
        rang_hash["custom_app"] = {}
        if hash[:apply_app_type] == "所有应用"
          rang_hash["app_sel"] = "all_app"
          rang_hash["all_app"] = true
          rang_hash["custom_app"]["enable"] = false
        elsif hash[:apply_app_type] == "自定义"
          rang_hash["app_sel"] = "custom_app"
          rang_hash["custom_app"]["enable"] = true
          rang_hash["all_app"] = false
        end
        rang_hash["custom_app"]["sub"] = {}
        rang_hash["custom_app"]["sub"]["app"] = []
        hash[:custom_app_selected].split("@;@").each { |app|
          app_arry = app.split("@_@")
          if app_arry.length != 3
            ATT::KeyLog.error("填写的应用选择个数不对")
            return_fail 
          end
          app_hash = {}
          case app_arry[0]
          when "应用类型"
            app_hash["type"] = 0
          when "网站类型"
            app_hash["type"] = 1
          when "文件类型"
            app_hash["type"] = 2
          else
            ATT::KeyLog.error("不符合的应用类型~!!#{app_arry[0]}")
            return_fail
          end
          app_hash["serviceType"] = app_arry[1]
          app_hash["serviceName"] = app_arry[2]
          rang_hash["custom_app"]["sub"]["app"] << app_hash
        }
        rang_hash["ipgroup_obj"] = {}
        rang_hash["usergroup_obj"] = {}
        if hash[:apply_obj_type] == "IP组"
          rang_hash["obj_sel"] = "ipgroup_obj"
          rang_hash["ipgroup_obj"]["enable"] = true
          rang_hash["usergroup_obj"]["enable"] = false
        elsif hash[:apply_obj_type] == "用户"
          rang_hash["obj_sel"] = "usergroup_obj"
          rang_hash["ipgroup_obj"]["enable"] = false
          rang_hash["usergroup_obj"]["enable"] = true
        end
        rang_hash["ipgroup_obj"]["ipgrp"] = hash[:ip_group]
        rang_hash["usergroup_obj"]["usergrp"] = {}
        rang_hash["usergroup_obj"]["usergrp"]["org"] = hash[:user_group]
        # => 我这里是猜的,不知道它那串数字是怎么来的,感觉像MD5, 明显不是MD5来的
        #rang_hash["usergroup_obj"]["usergrp"]["itemName"] = MD5.new(hash[:user_group]).to_s
        rang_hash["time"] = hash[:time_group_name]
        rang_hash["ipgroup"] =  hash[:dstip_group]
        rang_hash["sub_port"] = {}
        rang_hash["vlan"] = {}
        if hash[:interface_selected] == "子接口"
          rang_hash["sub"] = "sub_port"
          rang_hash["sub_port"]["enable"] = true
          rang_hash["vlan"]["enable"] = false
        elsif hash[:interface_selected] == "vlan"
          rang_hash["sub"] = "vlan"
          rang_hash["sub_port"]["enable"] = false
          rang_hash["vlan"]["enable"] = true
        end
        rang_hash["sub_port"]["sub_eth"] = hash[:sub_eth]
        rang_hash["vlan"]["vlan_eth"] = hash[:vlan_eth]
        return rang_hash
      end
    end
  end
end
