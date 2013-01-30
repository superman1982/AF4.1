# coding: utf8
module DeviceConsole
  module ContentSecurity
    module ApplicationControlStrategyHelper

      # 获取新增应用控制策略时要post的数据
      def get_add_application_control_strategy_post_hash( hash )
        # 源,初始值,下面再修改
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
        # 目的
        dst_hash = { "dst_zone" => hash[:dest_zone].split("&").join(","), "dst_ip" => hash[:dest_ip].split("&").join(",") }
        # 应用/服务,初始值,下面再修改
        srv_hash = {"srv_app_group" => "", "srv_group" => {"srv"=>"","enable"=>false}, "app_group" => {"app"=>"","enable"=>false} }
        if hash[:app_type] == "服务"
          srv_hash["srv_app_group"] = "srv_group"
          srv_hash["srv_group"]["enable"] = true
          srv_hash["srv_group"]["srv"] = hash[:services].split("&").join(",")
        elsif hash[:app_type] == "应用"
          srv_hash["srv_app_group"] = "app_group"
          srv_hash["app_group"]["enable"] = true
          srv_hash["app_group"]["app"] = hash[:apps].split("&").join(",")
        end
        status_hash = {"name" => hash[:name], "description" => hash[:description], "enable" => hash[:enable].to_logic,\
            "log" => hash[:record_log].to_logic, "src" => src_hash, "dst" => dst_hash, "srv" => srv_hash }
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

        post_hash = {"opr" => "add", "orgName" => "", "data" => { "status" => status_hash }}
        return post_hash
      end
=begin
      # 转换生效时间
      def convert_active_time( take_effect_time )
        post_hash = {"opr" => "listAllTime" }
        result_hash = AF::Login.get_session().post(TimePlanObjCGI, post_hash)
        if result_hash["success"]
          all_time_plans = result_hash["data"] # 数组,元素类型是hash,格式{"name"=>"", "value"=>"", "depict"=>""}
          all_time_plans.each do |time_plan|
            if time_plan["name"] == take_effect_time
              ATT::KeyLog.info("获取时间计划列表成功,#{take_effect_time}对应的值是#{time_plan["value"]}")
              return time_plan["value"]
            end
          end
        else
          ATT::KeyLog.info("获取时间计划列表失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=end
      # 获取当前所有应用控制策略的名称(不包含'默认策略'),返回数组
      def get_all_appctrl_strategy_names
        names = [] # 存放所有应用控制策略的名称
        all_appctrl_strategys = DeviceConsole::list_all_objects_with_limit(ApplicationControlCGI, "应用控制策略") # 数组,元素是hash类型
        all_appctrl_strategys.each do |appctrl_strategy|
          names << appctrl_strategy["name"] unless appctrl_strategy["name"] == "默认策略"
        end
        ATT::KeyLog.debug("所有应用控制策略的名称:#{names.join(',')}")
        return names
      end

      # 检查应用控制策略的设置是否与期望一致
      def check_appctrl_strategy_setting(appctrl_strategy, hash )
        # { "src_ip":"ipgrp211,ipgrp212", "description":"\u63cf\u8ff0", "status":1, "name":"appctrl1", "log":false, "src_ip_content":"1.1.1.1-1.1.1.100,2.2.2.2,4.3.2.2", "num":1, "active_time":"\u5168\u5929", "dst_zone":"zone211,zone212", "src_zone":"zone211,zone212", "action":true, "service_app":"\u81ea\u5b9a\u4e49\u670d\u52a1\/\u5168\u90e8,\u9884\u5b9a\u4e49\u670d\u52a1\/ping,\u670d\u52a1\u7ec4\/\u5168\u90e8", "dst_ip":"\u5168\u90e8"}
        unless hash[:source_zone].to_s.empty?
          return_fail("源区域错误") unless after_processed_object_equal?(hash[:source_zone], appctrl_strategy["src_zone"] )
        end
        unless hash[:source_user_ip].to_s.empty?
          return_fail("源IP用户错误") unless after_processed_object_equal?(hash[:source_user_ip], appctrl_strategy["src_ip"] )
        end
        unless hash[:dest_zone].to_s.empty?
          return_fail("目的区域错误") unless after_processed_object_equal?(hash[:dest_zone], appctrl_strategy["dst_zone"] )
        end
        unless hash[:dest_ip].to_s.empty?
          return_fail("目的IP组错误") unless after_processed_object_equal?(hash[:dest_ip], appctrl_strategy["dst_ip"] )
        end
        unless hash[:service_app].to_s.empty?
          return_fail("服务应用错误") unless after_processed_object_equal?(hash[:service_app], appctrl_strategy["service_app"] )
        end
        unless hash[:take_effect_time].to_s.empty?
          return_fail("生效时间错误") unless hash[:take_effect_time] == appctrl_strategy["active_time"]
        end
        unless hash[:operation] == "忽略"
          return_fail("动作错误") unless hash[:operation].to_logic == appctrl_strategy["action"]
        end
        unless hash[:record_log] == "忽略"
          return_fail("记录日志错误") unless hash[:record_log].to_logic == appctrl_strategy["log"]
        end
        unless hash[:status] == "忽略"
          return_fail("状态错误") unless hash[:status].to_int == appctrl_strategy["status"]
        end
        return_ok
      end
      # 判断两个字符串分离出的数组是否相同
      def after_processed_object_equal?( object_str, object_hoped_str)
        tmp_array_1 = object_str.split("&")
        tmp_array_2 = object_hoped_str.split(",")
        if (tmp_array_1 - tmp_array_2).empty? && (tmp_array_2 - tmp_array_1).empty?
          return true
        else
          return false
        end
      end
    end
  end
end
