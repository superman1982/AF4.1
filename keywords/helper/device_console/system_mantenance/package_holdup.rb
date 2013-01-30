# coding: utf8
module DeviceConsole
  module SystemMantenance
    module PackageHoldupHelper

      # 获取启禁实时拦截日志时要post的数据
      def get_enable_disable_realtime_holdup_log_post_hash( hash )
        post_hash = {"opr" => "", "name" => ""} # null
        if hash[:operation] == "启用"
          post_hash["opr"] = "open"
        else
          post_hash["opr"] = "close"
        end
        return post_hash
      end

      # 获取设置开启条件时要post的数据
      def get_set_enable_condition_and_enable_post_hash( hash )
        # 初始值,下面再修改
        data_hash = { "ip" => { "item" => "" }, "exclude" => { "item" => "" },
          "protocol" => { "type" => 0, "num" => "", "portSelect" => "all", "all" => true, "assign" => { "portNo" => "", "enable" => false } } }

        data_hash["ip"]["item"] = hash[:accept_ips].split("&").join("\r\n")
        data_hash["exclude"]["item"] = hash[:reject_ips].split("&").join("\r\n")
        data_hash["protocol"]["type"] = convert_protocol_type(hash[:protocol])
        if hash[:protocol] == "其他" && !hash[:protocol_num].to_s.empty?
          data_hash["protocol"]["num"] = hash[:protocol_num].to_i
        end
        if hash[:protocol] == "TCP" || hash[:protocol] == "UDP"
          if hash[:port_type] == "所有端口"
            data_hash["protocol"]["portSelect"] = "all"
            data_hash["protocol"]["all"] = true
          else
            data_hash["protocol"]["portSelect"] = "assign"
            data_hash["protocol"]["all"] = false
            data_hash["protocol"]["assign"]["enable"] = true
            data_hash["protocol"]["assign"]["portNo"] = hash[:port].to_i unless hash[:port].to_s.empty?
          end
        end
        post_hash = {"opr" => "submits", "data" => data_hash}
        return post_hash
      end
      # 转换协议类型
      def convert_protocol_type(protocol)
        tmp_hash = {"所有" => 0, "TCP" => 1, "UDP" => 2, "ICMP" => 3, "其他" => 4}
        return tmp_hash["#{protocol}"] if tmp_hash.has_key?("#{protocol}")
        return_fail("不支持的协议类型")
      end

      # 检查实时拦截日志,是否包含指定条件对应的记录
      def check_holdup_logs(realtime_log_array, hash )
        realtime_log_array.each do |one_log_hash|
          success = true
          if !hash[:s_ip].to_s.empty? && one_log_hash["source"] != hash[:s_ip].strip
            ATT::KeyLog.error("源错误,实际是#{one_log_hash["source"]},期望是#{hash[:s_ip]}")
            success = false
          end
          if success && !hash[:operation].to_s.empty? && !one_log_hash["action"].include?(hash[:operation].strip)
            ATT::KeyLog.error("动作错误,实际是#{one_log_hash["action"]},期望是#{hash[:operation]}")
            success = false
          end
          if success && !hash[:protocol].to_s.empty? && one_log_hash["proto"] != hash[:protocol]
            ATT::KeyLog.error("协议错误,实际是#{one_log_hash["proto"]},期望是#{hash[:protocol]}")
            success = false
          end
          if success && !hash[:content].to_s.empty? && !one_log_hash["ip"].include?(hash[:content])
            ATT::KeyLog.error("源到目标错误,实际是#{one_log_hash["ip"]},期望是#{hash[:content]}")
            success = false
          end
          if success && !hash[:device].to_s.empty? && one_log_hash["dev"] != hash[:device]
            ATT::KeyLog.error("设备错误,实际是#{one_log_hash["dev"]},期望是#{hash[:device]}")
            success = false
          end
          if success && !hash[:drop_flag].to_s.empty? && one_log_hash["dropflag"] != hash[:drop_flag]
            ATT::KeyLog.error("丢包标记错误,实际是#{one_log_hash["dropflag"]},期望是#{hash[:drop_flag]}")
            success = false
          end
          if success && !hash[:app_name].to_s.empty? && one_log_hash["appname"] != hash[:app_name]
            ATT::KeyLog.error("应用名称错误,实际是#{one_log_hash["appname"]},期望是#{hash[:app_name]}")
            success = false
          end
          if success && !hash[:app_rule].to_s.empty? && one_log_hash["apprule"] != hash[:app_rule]
            ATT::KeyLog.error("应用规则错误,实际是#{one_log_hash["apprule"]},期望是#{hash[:app_rule]}")
            success = false
          end
          return_ok if success # 当前记录符合指定的条件
        end
        # 没有一条记录符合指定的条件
        ATT::KeyLog.error("实时日志中不包含符合指定的条件的记录,当前的实时日志是#{realtime_log_array}")
        ATT::KeyLog.error("")
        return_fail
      end
      
    end
  end
end
