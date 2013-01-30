# coding: utf8
module DeviceConsole
  module ObjectDefinition
    module HoleLibraryHelper

      # 获取当前漏洞ID原来的信息,返回hash类型
      def get_original_setting_of_hole( hole_id )
        post_hash = {"opr" => "listItem", "name" => hole_id }
        result_hash = AF::Login.get_session().post(HoleLibraryCGI, post_hash)
        if result_hash["success"]
          return result_hash["data"]
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      # 修改设置的hash
      def get_new_setting_of_hole(old_data_hash, operation )
        new_data_hash = {"name" => "#{old_data_hash["name"]}", "bug_name" => old_data_hash["bug_name"],
        "bug_desc" => old_data_hash["bug_desc"], "attack_obj" => old_data_hash["attack_obj"],
        "danger_level" => get_level_text(old_data_hash["danger_level"]),
        "ref_infor" => old_data_hash["ref_infor"], "solution" => old_data_hash["solution"],
        "action" => "", "enable_intercept" => { "enable" => false }, "enable_pass" => { "enable" => false },
        "enable_action" => { "enable" => false }, "disable" => { "enable" => false } }

        operation_map = {"enable_intercept" => "检测后拦截", "enable_pass" => "检测后放行",
                         "enable_action" => "与云分析引擎联动", "disable" => "禁用"}
        operation_map.each do |oper_k, oper_v|
          if operation == oper_v
            new_data_hash[oper_k]["enable"] = true
            new_data_hash["action"] = oper_k
          end
        end
        return new_data_hash
      end

      def get_level_text(level_num)
        level_map = {1 => "高", 2 => "中", 3 => "低"}
        return "<font color=\"#ff0000\">#{level_map[level_num]}</font>"
      end
      
    end
  end
end
