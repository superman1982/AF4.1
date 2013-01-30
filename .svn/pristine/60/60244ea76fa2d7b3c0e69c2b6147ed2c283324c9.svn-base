# coding: utf8
module DeviceConsole
  module FireWall
    module DosDefenceHelper

      # 获取设置内网防护策略时要post的数据
      def get_set_intranet_dos_defence_post_hash( hash )
        config_hash = { "srcaddrfilter" => "",
          "rpassanyip" => { "enable" => false },
          "rpassfollowips" => {"enable" => false, "tpassfollowips" => ""},
          "selevn" => "",
          "rline3" => { "enable" => false },
          "rline2" => { "enable" => false },
          "lexceptip" => "以下IP地址发起的攻击不会被拦截",
          "exceptiplist" => "",
          "maxtcpnum" => 1024, "maxpktnum" => 10240, "blocktime" => 2,
          "action" => { "log" => false },
          "enable" => false
        }
        config_hash["enable"] = hash[:enable].to_logic
        config_hash["srczone"] = hash[:source_zone].gsub(/&/, ",")
        if hash[:source_filter] == "允许任意源IP"
          config_hash["rpassanyip"]["enable"] = true
          config_hash["srcaddrfilter"] = "rpassanyip"
        else # 允许指定源IP
          config_hash["rpassfollowips"]["enable"] = true
          config_hash["rpassfollowips"]["tpassfollowips"] = hash[:source_ips].gsub(/&/, "\n")
          config_hash["srcaddrfilter"] = "rpassfollowips"
        end
        if hash[:env_deployment] == "二层"
          config_hash["rline2"]["enable"] = true
          config_hash["selevn"] = "rline2"
        else
          config_hash["rline3"]["enable"] = true
          config_hash["selevn"] = "rline3"
        end
        config_hash["exceptiplist"] = hash[:exclude_ips].gsub(/&/, "\n")
        config_hash["maxtcpnum"] = hash[:tcp_conn].to_i
        config_hash["maxpktnum"] = hash[:max_times].to_i
        config_hash["blocktime"] = hash[:block_time].to_i
        config_hash["action"]["log"] = hash[:record_logs].to_logic

        post_hash = {"opr" => "modify", "type" => "DDOSIN", "data" => { "DDOSInConfig" => config_hash } }
        return post_hash
      end

      # 获取新增外网防护策略时要post的数据
      def get_add_internet_dos_defence_policy_post_hash( hash )
        ddos_defend_hash = {} # DOS攻击防护
        ddos_defend_hash["dstipgroup"] = hash[:dos_dstip_group].gsub(/&/, ",")
        ddos_defend_hash["checkboxicmps"] = { "icmpfloodgate" => hash[:icmp_threshold].to_i, "enable" => hash[:icmp_defence].to_logic}
        ddos_defend_hash["checkboxudps"] = {"udpfloodgate" => hash[:udp_threshold].to_i, "enable" => hash[:udp_defence].to_logic }
        ddos_defend_hash["checkboxsyns"] = { "synactivegate" => hash[:syn_dstip_activate_threshold].to_i,
          "syndropgate" => hash[:syn_dstip_drop_threshold].to_i,
          "synsrcgate" => hash[:syn_srcip_threshold].to_i,
          "enable" => hash[:syn_defence].to_logic }
        ddos_defend_hash["checkboxdnss"] = { "dnsdstgate" => hash[:dns_threshold].to_i, "enable" => hash[:dns_defence].to_logic }
        
        config_hash = { "name" => hash[:name], "desc" => hash[:description], "srczone" => hash[:source_zone].gsub(/&/, ","),
          "checkboxarp" => {"arpfloodgate" => 5000, "enable" => false },
          "scandefend" => { "checkboxips" => {"ipscangate" => 4000, "enable" => false }, "checkboxports" => { "portcangate" => 4000, "enable" => false } },
          "ddos" => { "ddosset" => { "ddosdefend" => ddos_defend_hash } },
          "basepkt" => { "pkt" => [] },
          "invalidpkt" => { "ippkt" => [], "tcppkt" => [] },
          "action" => {"log" => hash[:record_logs].to_logic, "drop" => hash[:block].to_logic },
          "enable" => hash[:enable].to_logic
        }
        config_hash["checkboxarp"]["enable"] = hash[:arp_defence].to_logic
        config_hash["checkboxarp"]["arpfloodgate"] = hash[:arp_threshold].to_i

        config_hash["scandefend"]["checkboxips"]["enable"] = hash[:ipscan_defence].to_logic
        config_hash["scandefend"]["checkboxips"]["ipscangate"] = hash[:ipscan_threshold].to_i
        config_hash["scandefend"]["checkboxports"]["enable"] = hash[:portscan_defence].to_logic
        config_hash["scandefend"]["checkboxports"]["portcangate"] = hash[:portscan_threshold].to_i
        config_hash["basepkt"]["pkt"] = get_data_packet_defence_value(hash[:data_packet_defence]) # 多个攻击类型用&分隔
        config_hash["invalidpkt"]["ippkt"] = get_ip_protocol_packet_value(hash[:ip_protocol_options])
        config_hash["invalidpkt"]["tcppkt"] = get_tcp_protocol_packet_value(hash[:tcp_protocol_options])

        post_hash = {"opr" => "add", "type" => "DDOSOUT", "data" => { "DDOSOutConfig" => config_hash } }
        return post_hash
      end

      # 根据传来的数据包攻击类型参数,返回对应的数值,返回数组
      # data_packet_defence, 多个攻击类型用&分隔
      def get_data_packet_defence_value( data_packet_defence )
        defence_text_array = data_packet_defence.split("&")
        data_packet_defence_map = {"未知协议类型防护" => 1, "TearDrop攻击防护" => 2, "IP数据块分片传输防护" => 3,
          "LAND攻击防护" => 4, "WinNuke攻击防护" => 5, "Smurf攻击防护" => 6, "超大ICMP数据攻击防护" => 8  }

        defence_value = []
        defence_text_array.each do |defence_text|
          defence_value << data_packet_defence_map[defence_text]
        end
        return defence_value
      end
      # 根据传来的IP协议报文选项参数,返回对应的数值,返回数组
      # ip_protocol_options, 多个报文选项用&分隔
      def get_ip_protocol_packet_value( ip_protocol_options )
        options_text_array = ip_protocol_options.split("&")
        ip_protocol_options_map = {"错误的IP报文选项防护" => 1, "IP时间戳选项报文防护" => 2, "IP安全选项报文防护" => 3,
          "IP数据流项报文防护" => 4, "IP记录路由选项报文防护" => 5, "IP宽松源路由选项报文防护" => 6, "IP严格源路由选项报文防护" => 7  }

        defence_value = []
        options_text_array.each do |option_text|
          defence_value << ip_protocol_options_map[option_text]
        end
        return defence_value
      end
      # 根据传来的TCP协议报文选项参数,返回对应的数值,返回数组
      # tcp_protocol_options, 多个报文选项用&分隔
      def get_tcp_protocol_packet_value( tcp_protocol_options )
        options_text_array = tcp_protocol_options.split("&")
        tcp_protocol_options_map = {"SYN数据分片传输防护" => 1, "TCP报头标志位全为0防护" => 2, "SYN和FIN标志位同时为1防护" => 3,
          "仅FIN标志位为1防护" => 4 }

        defence_value = []
        options_text_array.each do |option_text|
          defence_value << tcp_protocol_options_map[option_text]
        end
        return defence_value
      end

      # 获取所有外网防护策略的名称
      def get_all_internet_dos_defence_policy_names
        names = [] # 存放所有外网防护策略的名称
        post_hash = {"opr" => "list", "type" => "DDOSOUT"}
        result_hash = AF::Login.get_session().post(InternetDosAttackCGI, post_hash)
        if result_hash["success"]
          all_internet_dos_defence_policys = result_hash["data"] # 数组的元素类型是hash
          all_internet_dos_defence_policys.each do |internet_dos_defence_policy|
            names << internet_dos_defence_policy["name"]
          end
          ATT::KeyLog.debug("所有外网防护策略的名称:#{names.join(',')}")
          return names
        else
          ATT::KeyLog.info("获取外网防护策略列表失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      
    end
  end
end
