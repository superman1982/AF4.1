# coding: utf8
module DeviceConsole
  module NetConfig
    module InterfaceZoneHelper

      # 编辑物理接口时,获取post的hash数据
      def get_edit_physical_interface( hash )
        data_hash = { "static_ip" => false, "dhcp" => false, "adsl_dial" => false, "access" => false, "trunk" => false} # 初始值,下面再修改
        area_name,mac_address = get_physical_interface_original_setting(hash[:name], ["area_name", "mac"]) # 获取接口当前所属的区域和mac地址
        data_hash["area_name"] = hash[:area_name]
        data_hash["interface1"] = hash[:name]
        if hash[:interface2] == ""
          data_hash["interface2"] = "请选择接口"
        else
          data_hash["interface2"] = hash[:interface2]
        end
        data_hash["linkstatus"] = "<SPAN style=\"COLOR: red\">鏂?寮€</SPAN>" # 貌似是固定值        
        data_hash["name"] = hash[:name]
        data_hash["descript"] = hash[:description]
        data_hash["enable"] = hash[:enable].to_logic
        data_hash["eth_type"] = convert_eth_type(hash[:type]) # route trans virtual
        data_hash["waneth"] = hash[:is_wan].to_logic
        data_hash["link_type"] = convert_link_type(hash[:link_type])  # static_ip dhcp adsl_dial access trunk
        data_hash[data_hash["link_type"]] = true
        data_hash, link_check_hash = evaluate_part_default_data_hash(data_hash) # 给部分参数赋初始值
        
        if data_hash["eth_type"] == "route"  # 以下在路由类型下有效
          data_hash["allowping"] = hash[:enable_ping].to_logic
          if data_hash["link_type"] == "static_ip" # # 连接类型选择静态IP
            data_hash["ipaddress"] = "#{hash[:static_ip]}".gsub(/&/, "\r\n")
            data_hash["nextgateway"] = hash[:gateway]
          elsif data_hash["link_type"] == "dhcp" # # 连接类型选择DHCP
            data_hash["isGetGateway"] = hash[:dhcp_add_default_route].to_logic
          elsif data_hash["link_type"] == "adsl_dial" # # 连接类型选择ADSL拨号
            data_hash["username"] = hash[:adsl_account]
            data_hash["userpwd"] = hash[:adsl_passwd]
            data_hash["userpwd_temp"] = hash[:adsl_passwd]
            data_hash["dial_params"]["handshake"] = hash[:adsl_shake_time].to_i
            data_hash["dial_params"]["timeout"] = hash[:adsl_timeout].to_i
            data_hash["dial_params"]["conntimes"] = hash[:adsl_retry_times].to_i
            data_hash["dial_params"]["autodial"] = hash[:adsl_auto].to_logic
            data_hash["dial_params"]["addroute"] = hash[:adsl_add_default_route].to_logic
            data_hash["dial_params"]["replacedns"] = hash[:adsl_first_dns].to_logic
          end
          #　上下行带宽
          data_hash["line"]["up"] = convert_bandwidth(hash[:up_bandwidth])
          data_hash["line"]["down"] = convert_bandwidth(hash[:down_bandwidth])
          # 链路故障检测
          link_check_hash["enable"] = hash[:enable_link_trouble_check].to_logic
          if link_check_hash["enable"] # 启用了链路故障
            link_check_hash["linkcheck_method_inte"]["check_interval"] = hash[:check_interval].to_i
            link_check_hash["linkcheck_method_inte"]["check_bad_threshold"] = hash[:check_bad_threshold].to_i
            check_method = convert_link_check_method(hash[:check_method])
            link_check_hash["linkcheck_method_fs"]["linkcheck_method"] = check_method
            if check_method == "ping"
              link_check_hash["linkcheck_method_fs"]["ping"]["enable"] = true
              link_check_hash["linkcheck_method_fs"]["ping"]["destination_ip"] = hash[:ping_ip]
            elsif check_method == "dns_parse"
              link_check_hash["linkcheck_method_fs"]["dns_parse"]["enable"] = true
              link_check_hash["linkcheck_method_fs"]["dns_parse"]["dns_server"] = hash[:dns_server] if data_hash["link_type"] == "static_ip"
              link_check_hash["linkcheck_method_fs"]["dns_parse"]["dns_server_bk"] = ""
              link_check_hash["linkcheck_method_fs"]["dns_parse"]["parse_domain"] = hash[:dns_domain]
            end
          end
        elsif data_hash["eth_type"] == "trans" # 以下在透明类型下有效
          if data_hash["link_type"] == "access" # 连接类型选择Access
            data_hash["access_value"] = "#{hash[:access_id]}"
          elsif data_hash["link_type"] == "trunk" # 连接类型选择Trunk
            data_hash["natives"] = "#{hash[:native_id]}"
            data_hash["vlan"] = "#{hash[:vlan_scope]}"
          end
        end
        # 基本属性
        data_hash["basic_params"] = []
        data_hash["basic_params"] << "waneth" if data_hash["waneth"]
        data_hash["basic_params"] << "allowping" if data_hash["allowping"]
        # 高级配置
        data_hash["advancesetup"]["advancesetup_win"]["workmode"] = convert_work_mode(hash[:work_mode])
        data_hash["advancesetup"]["advancesetup_win"]["mtu"] = hash[:mtu].to_i
        # 接口的MAC地址,若不重新设置,则跟其原本的设置相同
        data_hash["advancesetup"]["advancesetup_win"]["mac"] = (hash[:mac].to_s.empty? ? mac_address : hash[:mac].to_s)
        if data_hash["waneth"] # 是wan口时删除2个键
          data_hash["advancesetup"]["advancesetup_win"].delete("mss")
          data_hash["advancesetup"]["advancesetup_win"].delete("closed")
        end
        
        post_hash = { "opr" => "modify", "data" => data_hash }
        return post_hash
      end
      
      # 编辑物理接口时,给部分参数赋初始值
      def evaluate_part_default_data_hash(data_hash)
        data_hash["allowping"] = false
        data_hash["ipaddress"] = ""
        data_hash["nextgateway"] = ""
        data_hash["isGetGateway"] = false
        data_hash["username"] = ""
        data_hash["userpwd"] = ""
        data_hash["userpwd_temp"] = ""
        data_hash["dial_params"] = {"timeout"=>80, "addroute"=>false, "conntimes"=>3, "handshake"=>20, "autodial"=>true, "replacedns" => false}
        data_hash["line"] = {"up" => 81920, "down" => 81920 }
        # 链路检测相关的
        link_check_hash =
          {
          "linkcheck_method_fs" => {
            "linkcheck_method" => "dns_parse",
            "dns_parse" => { "dns_server" => "", "dns_server_bk" => "", "parse_domain"=> "www.sangfor.com", "enable"=> false },
            "ping" => { "destination_ip" => "202.96.137.23", "enable"=> false }
          },
          "linkcheck_method_inte" => { "check_interval" => 2,"check_bad_threshold" => 3 },
          "enable" => false
        }
        data_hash["linkcheck"] = { "set_check_method" => { "linkcheck_win" => link_check_hash } }
        data_hash["access_value"] = "1"
        data_hash["natives"] = "1"
        data_hash["vlan"] = "1-1000"
        data_hash["advancesetup"] = { "advancesetup_win" => { "workmode"=>1, "mss"=>"closed","mtu"=>1500,"mac"=>"","closed"=>true }}
        return [data_hash, link_check_hash]
      end
      # 获取某个物理接口的某个属性
      def get_physical_interface_original_setting(eth_name, attrs)
        post_hash = { "opr" => "listItem", "name" => "#{eth_name}" }
        attr_values = []
        result_hash = AF::Login.get_session().post(InterfaceZoneCGI, post_hash)
        if result_hash["success"]
          data_hash = result_hash["data"] # eth_name物理接口的所有信息
          attrs.each do |attr|
            case attr
            when "area_name"
              ATT::KeyLog.info("名称是#{eth_name}的物理接口的区域是#{data_hash["area_name"]}")
              attr_values.push(data_hash["area_name"])
            when "mac"
              ATT::KeyLog.info("名称是#{eth_name}的MAC是#{data_hash["advancesetup"]["advancesetup_win"]["mac"]}")
              attr_values.push(data_hash["advancesetup"]["advancesetup_win"]["mac"])
            end
          end
          return attr_values
        else
          ATT::KeyLog.info("获取物理接口的信息失败,请检查物理接口是否存在")
          return_fail()
        end
      end
      
      # 转换接口类型
      def convert_eth_type(type)
        tmp_hash = {"路由" => "route", "透明" => "trans", "虚拟网线" => "virtual"}
        return tmp_hash["#{type}"] if tmp_hash.has_key?("#{type}")
        return_fail("不存在的接口类型")
      end
      # 连接类型
      def convert_link_type(link_type)
        tmp_hash = {"静态IP" => "static_ip", "DHCP" => "dhcp", "ADSL拨号" => "adsl_dial", "Access" => "access", "Trunk" => "trunk"}
        return tmp_hash["#{link_type}"] if tmp_hash.has_key?("#{link_type}")
        return_fail("不存在的连接类型")
      end
      # 转换带宽
      def convert_bandwidth(bandwidth)
        return_fail("不存在的带宽单位") unless bandwidth.to_s =~ /MB\/s|GB\/s|KB\/s/
        if bandwidth.to_s =~ /MB\/s/
          number = bandwidth.gsub(/MB\/s/, "").to_i
          result = number * 1024 * 8
        elsif bandwidth.to_s =~ /GB\/s/
          number = bandwidth.gsub(/GB\/s/, "").to_i
          result = number * 1024 * 1024 * 8
        elsif bandwidth.to_s =~ /KB\/s/
          number = bandwidth.gsub(/KB\/s/, "").to_i
          result = number * 8
        end
        return result
      end
      # 转换链接检测方法
      def convert_link_check_method( check_method )
        tmp_hash = {"PING" => "ping", "DNS解析" => "dns_parse"}
        return tmp_hash["#{check_method}"] if tmp_hash.has_key?("#{check_method}")
        return_fail("不存在的链接检测方法")
      end
      # 转换工作模式
      def convert_work_mode(work_mode)
        tmp_hash = {"自动协商" => 1, "全双工10M" => 2, "半双工10M" => 3, "全双工100M"  => 4,"半双工100M" => 5,"全双工1000M" => 6,
          "半双工1000M" => 7, "全双工10000M" => 8, "半双工10000M" => 9 }
        return tmp_hash["#{work_mode}"] if tmp_hash.has_key?("#{work_mode}")
        return_fail("不存在的工作模式")
      end

      # 检查某个物理接口当前的设置
      def check_interface_setting(interfaces_setting, hash )
        interfaces_setting.each do |interface|
          if interface["name"] == hash[:name]
            return_fail("描述错误") if !hash[:description].to_s.empty? && hash[:description] != interface["descript"]
            return_fail("WAN口错误") if hash[:is_wan] != "忽略" && hash[:is_wan].to_int != interface["wan"]
            return_fail("接口类型错误") if hash[:type] != "忽略" && convert_eth_type2(hash[:type]) != interface["ethtype"]
            return_fail("连接类型错误") if hash[:link_type] != "忽略" && convert_link_type2(hash[:link_type]) != interface["conntype"]
            return_fail("IP地址错误") if !hash[:address].to_s.empty? && convert_ip_address(hash[:address]) != interface["ip"]
            return_fail("拨号状态错误") if hash[:adsl_status] != "忽略" && convert_adsl_status(hash[:adsl_status]) != interface["connstatus"]
            return_fail("MTU错误") if !hash[:mtu].to_s.empty? && hash[:mtu] != interface["mtu"]
            if hash[:work_mode] == "自动协商"
              if !interface["speed"].include?(hash[:work_mode])
                return_fail("工作模式错误")
              end
            else
              if convert_work_mode2(hash[:work_mode])!=interface["speed"]
                return_fail("工作模式错误")
              end
            end
            return_fail("PING错误") if hash[:enable_ping] != "忽略" && hash[:enable_ping].to_int != interface["ping"]
            return_fail("网口状态错误") if hash[:interface_status]!= "忽略" && convert_interface_status(hash[:interface_status]) != interface["NICstatus"]
            return_fail("链路状态错误") if hash[:link_status] != "忽略" && convert_link_status(hash[:link_status]) != interface["linkstatus"]
            return_fail("状态错误") if !hash[:status].to_s.empty? && hash[:status].to_logic != interface["ethup"]
            return_ok
          end
        end
        ATT::KeyLog.info("物理接口#{hash[:name]}不存在")
        return_fail("物理接口不存在")
      end
      
      # 转换接口类型
      def convert_eth_type2(type)
        tmp_hash = {"路由" => 4, "透明" => 2, "虚拟网线" => 1}
        return tmp_hash["#{type}"] if tmp_hash.has_key?("#{type}")
        return_fail("不存在的接口类型")
      end
      # 转换连接类型
      def convert_link_type2(link_type)
        tmp_hash = {"静态IP" => "静态IP", "DHCP" => "DHCP", "ADSL拨号" => "ADSL拨号", "无效" => "---"}
        return tmp_hash["#{link_type}"] if tmp_hash.has_key?("#{link_type}")
        return_fail("不存在的连接类型")
      end
      # 转换IP地址
      def convert_ip_address( address )
        if address == "无效"
          return "---"
        else
          return address.to_s.gsub(/&/,"<br>")
        end
      end
      # 转换拨号状态
      def convert_adsl_status(adsl_status)
        return "---" if adsl_status == "无效"
        return "断开" if adsl_status == "断开"
        return "已连接" if adsl_status == "连接"
      end
      # 转换工作模式
      def convert_work_mode2(work_mode)
        tmp_hash = {"全双工10M" => "10Mb/s\n全双工|10Mb\/s\n全双工", "半双工10M" => "10Mb/s\n半双工|协商不成功", "全双工100M"  => "100Mb/s\n全双工|协商不成功",
          "半双工100M" => "100Mb/s\n半双工|协商不成功","全双工1000M" => "1000Mb/s\n全双工|协商不成功","半双工1000M" => "1000Mb/s\n半双工|协商不成功",
          "全双工10000M" => "10000Mb/s\n全双工|协商不成功", "半双工10000M" => "10000Mb/s\n半双工|协商不成功" }
        return tmp_hash["#{work_mode}"] if tmp_hash.has_key?("#{work_mode}")
        return_fail("不存在的工作模式")
      end
      # 转换网口状态
      def convert_interface_status(interface_status)
        tmp_hash = {"正常" => true, "断开" => false }
        return tmp_hash["#{interface_status}"] if tmp_hash.has_key?("#{interface_status}")
        return_fail("不存在的网口状态")
      end
      # 转换链路状态
      def convert_link_status(link_status)
        tmp_hash = {"故障" => 0, "正常" => 1, "未检测" => 2, "无效" => 3 }
        return tmp_hash["#{link_status}"] if tmp_hash.has_key?("#{link_status}")
        return_fail("不存在的链路状态")
      end

      # 点击连接按钮后,尝试10次检测其连接状态
      def dial_ten_times(eth_name)
        flag = false # 是否拨号成功
        10.times do # 连续5次检测连接状态
          onstatus_post_hash = {"opr" => "query", "type" => "onstatus", "name" => eth_name}
          result_hash_2 = AF::Login.get_session().post(AdslDialCGI, onstatus_post_hash)
          if result_hash_2["success"] # 拨号成功
            flag = true
            break
          end
          sleep 2
        end
        return flag
      end

      # 获取添加子接口时要post的数据
      def get_add_sub_interface_post_hash( hash )
        data_hash = {} # 初始值,下面再修改
        data_hash = get_sub_and_vlan_common_post_hash(data_hash, hash)

        data_hash["physical_port"] = "#{hash[:name]}"
        data_hash["vlan_id"] = "#{hash[:vlan_id]}"

        post_hash = { "opr" => "add", "data" => data_hash }
        return post_hash
      end
      # 添加子接口时,给部分参数赋初始值
      def evaluate_part_default_data_hash2(data_hash)
        data_hash["allowping"] = false
        data_hash["ipaddress"] = ""
        data_hash["nextgateway"] = ""
        data_hash["isGetGateway"] = false
        data_hash["static_ip"] = false
        data_hash["dhcp"] = false
        # 链路检测相关的
        link_check_hash =
          {
          "linkcheck_method_fs" => {
            "linkcheck_method" => "dns_parse",
            "dns_parse" => { "dns_server" => "使用接口自动获取的DNS", "parse_domain"=> "www.sangfor.com", "enable"=> false },
            "ping" => { "destination_ip" => "202.96.137.23", "enable"=> false }
          },
          "linkcheck_method_inte" => { "check_interval" => 2,"check_bad_threshold" => 3 },
          "enable" => false
        }
        data_hash["linkcheck"] = { "set_check_method" => { "linkcheck_win" => link_check_hash } }
        data_hash["advancesetup"] = { "advancesetup_win" => { "mtu"=>1500 }}
        return [data_hash, link_check_hash]
      end
=begin
      # 获取所有子接口的名称,返回数组
      def get_all_sub_interface_names()
        names = [] # 存放所有子接口的名称
        all_sub_interfaces = list_all_sub_interfaces
        all_sub_interfaces.each do |sub_interface|
          names << sub_interface["name"]
        end
        ATT::KeyLog.debug("所有子接口的名称:#{names.join(',')}")
        return names
      end
      # 获取所有子接口列表,返回数组,元素类型是hash
      def list_all_sub_interfaces
        post_hash = {"opr" => "list"}
        result_hash = AF::Login.get_session().post(SubPortCGI, post_hash)
        if result_hash["success"]
          return result_hash["data"] # 数组的元素类型是hash
        else
          ATT::KeyLog.info("获取子接口列表失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=end
      def check_sub_interface_info(sub_interface_info_hash, hash )
        return_fail("描述错误") if !hash[:description].to_s.empty? && hash[:description] != sub_interface_info_hash["description"]
        return_fail("区域错误") if !hash[:zone].to_s.empty? && hash[:zone] != sub_interface_info_hash["zone"]
        ip_mask = sub_interface_info_hash["ip_mask"].gsub(/^(<br>)*|(<br>)*$/, '')
        ATT::KeyLog.debug("ip_mask = #{ip_mask}")
        return_fail("IP地址错误") if !hash[:address].to_s.empty? && convert_ip_address(hash[:address]) != ip_mask
        return_fail("MTU错误") if !hash[:mtu].to_s.empty? && hash[:mtu].to_i != sub_interface_info_hash["mtu"]
        return_fail("PING错误") if hash[:enable_ping] != "忽略" && hash[:enable_ping].to_logic != sub_interface_info_hash["enable_ping"]
        return_fail("链路状态错误") if hash[:link_status] != "忽略" && convert_link_status(hash[:link_status]) != sub_interface_info_hash["link_status"]
        return_ok
      end

      # 获取添加VLAN接口时要post的数据
      def get_add_vlan_interface_post_hash( hash )
        data_hash = {} # 初始值,下面再修改
        data_hash = get_sub_and_vlan_common_post_hash(data_hash, hash)

        data_hash["name"] = "veth.#{hash[:vlan_id]}"
        data_hash["vlan_id"] = "#{hash[:vlan_id]}"

        post_hash = { "opr" => "add", "data" => data_hash }
        return post_hash
      end

      # 新增子接口和VLAN接口时的公共参数处理
      def get_sub_and_vlan_common_post_hash(data_hash, hash)
        data_hash, link_check_hash = evaluate_part_default_data_hash2(data_hash) # 给部分参数赋初始值

        data_hash["depict"] = hash[:description]
        data_hash["allowping"] = hash[:enable_ping].to_logic
        data_hash["link_type"] = convert_link_type(hash[:link_type])
        data_hash[data_hash["link_type"]] = true

        if data_hash["link_type"] == "static_ip" # # 连接类型选择静态IP
          data_hash["ipaddress"] = "#{hash[:static_ip]}".gsub(/&/, "\r\n")
          data_hash["nextgateway"] = hash[:gateway]
        elsif data_hash["link_type"] == "dhcp" # # 连接类型选择DHCP
          data_hash["isGetGateway"] = hash[:get_default_gw].to_logic
        end
        #link_check_hash = get_link_check_hash(data_hash["link_type"], link_check_hash, hash[:enable_link_trouble_check], hash[:check_interval],hash[:check_method],hash[:ping_ip],hash[:dns_server],hash[:dns_domain])
        link_check_hash["enable"] = hash[:enable_link_trouble_check].to_logic
        if link_check_hash["enable"] # 启用了链路故障
          link_check_hash["linkcheck_method_inte"]["check_interval"] = hash[:check_interval].to_i
          link_check_hash["linkcheck_method_inte"]["check_bad_threshold"] = hash[:check_bad_threshold].to_i
          check_method = convert_link_check_method(hash[:check_method])
          link_check_hash["linkcheck_method_fs"]["linkcheck_method"] = check_method
          if check_method == "ping"
            link_check_hash["linkcheck_method_fs"]["ping"]["enable"] = true
            link_check_hash["linkcheck_method_fs"]["ping"]["destination_ip"] = hash[:ping_ip]
          elsif check_method == "dns_parse"
            link_check_hash["linkcheck_method_fs"]["dns_parse"]["enable"] = true
            link_check_hash["linkcheck_method_fs"]["dns_parse"]["dns_server"] = hash[:dns_server] if data_hash["link_type"] == "static_ip"
            link_check_hash["linkcheck_method_fs"]["dns_parse"]["parse_domain"] = hash[:dns_domain]
          end
        end
        if hash[:area_name] != nil and hash[:area_name] != "default" and hash[:area_name] != ""
          data_hash["area_name"] = hash[:area_name]
        else
          data_hash["area_name"] = "default"
        end
        # 基本属性
        data_hash["basic_params"] = []
        data_hash["basic_params"] << "allowping" if data_hash["allowping"]
        # 高级配置
        data_hash["advancesetup"]["advancesetup_win"]["mtu"] = hash[:mtu].to_i
        return data_hash
      end

      # 获取所有vlan接口的名称,返回数组
      def get_all_vlan_interface_names()
        names = [] # 存放所有子接口的名称
        all_vlan_interfaces = list_all_vlan_interfaces
        all_vlan_interfaces.each do |vlan_interface|
          names << vlan_interface["name"]
        end
        ATT::KeyLog.debug("所有vlan接口的名称:#{names.join(',')}")
        return names
      end
      # 获取所有vlan接口列表,返回数组,元素类型是hash
      def list_all_vlan_interfaces
        post_hash = {"opr" => "list","type" => "vlan"}
        result_hash = AF::Login.get_session().post(VlanCGI, post_hash)
        if result_hash["success"]
          return result_hash["data"] # 数组的元素类型是hash
        else
          ATT::KeyLog.info("获取vlan接口列表失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

      # 获取编辑VLAN接口时要post的数据
      def get_edit_vlan_interface_post_hash( hash )
        data_hash = {} # 初始值,下面再修改
        data_hash = get_sub_and_vlan_common_post_hash(data_hash, hash)

        if hash[:new_name].to_s.empty? # 新名称为空时,使用原本的名称
          data_hash["name"] = "#{hash[:name]}"
        else
          data_hash["name"] = "#{hash[:new_name]}"
        end
        data_hash["vlan_id"] = "#{hash[:name]}".split(".")[1].to_s
        data_hash["advancesetup"]["advancesetup_win"]["userdef"] = { "value" => 0, "enable" => false }
        data_hash["advancesetup"]["advancesetup_win"]["closed"] = { "enable" => false }
        data_hash["advancesetup"]["advancesetup_win"]["auto"] = { "enable" => false }

        post_hash = { "opr" => "modify", "type" => "vlan", "data" => data_hash }
        return post_hash
      end
      # 检查vlan接口的设置是否与期望一致
      def check_vlan_interface_info(vlan_info_hash, hash )
        # { "zone":"", "name":"veth.2", "type":0, "is_ping":true, "mtu":1500, "vlan_id":2, "is_link":0, "is_enable":true, "ip_mask":"200.200.85.124\/22<br>", "depict":""}
        return_fail("描述错误") if !hash[:description].to_s.empty? && hash[:description] != vlan_info_hash["depict"]
        return_fail("区域错误") if !hash[:zone].to_s.empty? && hash[:zone] != vlan_info_hash["zone"]
        ip_mask = vlan_info_hash["ip_mask"].gsub(/^(<br>)*|(<br>)*$/, '')
        ATT::KeyLog.debug("ip_mask = #{ip_mask}")
        return_fail("IP地址错误") if !hash[:address].to_s.empty? && convert_ip_address(hash[:address]) != ip_mask
        return_fail("MTU错误") if !hash[:mtu].to_s.empty? && hash[:mtu].to_i != vlan_info_hash["mtu"]
        return_fail("PING错误") if hash[:enable_ping] != "忽略" && hash[:enable_ping].to_logic != vlan_info_hash["is_ping"]
        return_fail("链路状态错误") if hash[:link_status] != "忽略" && convert_link_status(hash[:link_status]) != vlan_info_hash["is_link"]
        return_ok
      end
      
      # 获取添加区域时要post的数据
      def get_add_zone_post_hash( hash )
        interfaces_hash_info = check_forward_type_and_interfaces(hash[:forward_type], hash[:interfaces]) # 检查转发类型与参数中的接口是否匹配
        data_hash = get_add_and_edit_zone_common_post_hash(hash, interfaces_hash_info)

        post_hash = {"opr" => "add", "data" => data_hash }
        return post_hash
      end
      
      # 检查转发类型与参数中的接口是否匹配,返回forward_type下,参数interfaces指定的接口信息数组
      def check_forward_type_and_interfaces( forward_type, interfaces)
        all_interfaces_avaliable = get_all_interfaces_avaliable( forward_type ) # 获取所有可供当前转发类型选取的接口
        interface_array = interfaces.to_s.split("|") # 参数中的接口可能有多个
        interfaces_info = []
        interface_array.each do |interface|
          tmp_hash = {"text" => "#{interface}", "value" => convert_forward_type2( forward_type )}
          if all_interfaces_avaliable.include?(tmp_hash)
            interfaces_info << tmp_hash
          else
            ATT::KeyLog.error("接口#{interface}不属于转发类型:#{ forward_type }")
            return_fail("转发类型与接口不匹配")
          end
        end
        return interfaces_info # 返回forward_type下,参数interfaces指定的接口数组[{"text"=>"xx","value"=>y},{"text"=>"xx2","value"=>y2}]
      end
      # 返回forward_type下,参数interface_array指定的接口信息数组,不检查接口是否与转发类型匹配
      def get_interfaces_hash_info(interface_array, forward_type )
        interfaces_info = []
        interface_array.each do |interface|
          tmp_hash = {"text" => "#{interface}", "value" => convert_forward_type2( forward_type )}
          interfaces_info << tmp_hash
        end
        return interfaces_info # 返回forward_type下,参数interfaces指定的接口数组[{"text"=>"xx","value"=>y},{"text"=>"xx2","value"=>y2}]
      end
      # 转换转发类型
      def convert_forward_type(forward_type)
        tmp_hash = {"二层区域" => "two", "三层区域" => "three", "虚拟网线区域" => "virtual" }
        return tmp_hash["#{forward_type}"] if tmp_hash.has_key?("#{forward_type}")
        return_fail("不存在的转发类型")
      end
      # 转换转发类型2
      def convert_forward_type2(forward_type)
        tmp_hash = {"二层区域" => 2, "三层区域" => 4, "虚拟网线区域" => 1 }
        return tmp_hash["#{forward_type}"] if tmp_hash.has_key?("#{forward_type}")
        return_fail("不存在的转发类型")
      end
      # 获取所有可供某个转发类型选取的接口,返回数组,元素类型是hash: {"text" => "xx", "value" => x}
      def get_all_interfaces_avaliable(forward_type = "all")
        post_hash = {"opr" => "listAllEth", "action" => "add", "item" => ""}
        result_hash = AF::Login.get_session().post(ZoneCGI, post_hash)
        if result_hash["success"]
          ATT::KeyLog.info("成功获取所有可供所有区域选取的接口")
          all_interfaces = result_hash["data"]
          return all_interfaces if forward_type == "all" # 所有的接口, 返回数组
          return_interfaces = []
          all_interfaces.each do |interface_hash|
            if interface_hash["value"] == convert_forward_type2(forward_type)
              return_interfaces << interface_hash
            end
          end
          return return_interfaces
        else
          ATT::KeyLog.info("获取所有可供所有区域选取的接口失败")
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      
      # 转换三层区域下的管理地址
      def convert_manage_address( manage_address )
        all_ip_groups = get_all_ip_group_avaliable_by_zone()
        all_ip_groups.each do |ip_group_hash|
          if ip_group_hash["name"] == manage_address
            ATT::KeyLog.info("名称是#{manage_address}的IP组,其value=#{ip_group_hash["value"]}")
            return ip_group_hash["value"]
          end
        end
        return_fail("IP组不存在")
      end
      # 获取所有的IP组详细信息,返回数组,元素类型是hash
      def get_all_ip_group_avaliable_by_zone()
        post_hash = {"opr" => "list"}
        result_hash = AF::Login.get_session().post(ObjIpGroupCGI, post_hash)
        if result_hash["success"]
          ATT::KeyLog.info("成功获取所有IP组")
          return result_hash["data"] # 返回数组,元素类型是{ "name":"xxxx", "ip":"yyyy", "value":"0*yyyy", "depict":"zzzz"}
        else
          ATT::KeyLog.info("获取所有IP组失败")
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=begin
      # 获取所有区域的名称,返回数组
      def get_all_zone_names()
        names = [] # 存放所有区域的名称
        all_zones = list_all_zones
        all_zones.each do |zone|
          names << zone["name"]
        end
        ATT::KeyLog.debug("所有区域的名称:#{names.join(',')}")
        return names
      end
      # 获取所有区域列表,返回数组,元素类型是hash
      def list_all_zones
        post_hash = {"opr" => "list" }
        result_hash = AF::Login.get_session().post(ZoneCGI, post_hash)
        if result_hash["success"]
          return result_hash["data"] # 数组的元素类型是hash
        else
          ATT::KeyLog.info("获取区域列表失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=end
      # 获取编辑区域时要post的数据
      def get_edit_zone_post_hash( hash )
        original_interface_array = get_zone_original_setting(hash[:name], "interfaces")[0] # 区域原本包含的接口名称的数组
        ATT::KeyLog.debug("区域#{hash[:name]}原本包含的接口:#{original_interface_array.join(',')}")
        new_interface_array = hash[:interfaces].to_s.split("|") # 编辑区域关键字参数中传来的接口名称数组
        tmp_interface_array = new_interface_array - original_interface_array # 相对区域原本包含的接口,参数中新增加的接口组成的数组
        common_interface_array = new_interface_array - tmp_interface_array # 区域原本包含的接口和参数中的接口,二者共同包含的接口
        interfaces_hash_info = [] # forward_type下,指定的接口组成的数组,格式:[{"text"=>"xx","value"=>y},{"text"=>"xx2","value"=>y2}]
        unless tmp_interface_array.empty?
          ATT::KeyLog.debug("区域#{hash[:name]}原本不包含接口:#{tmp_interface_array.join(',')},现检查其是否与转发类型匹配...")
          interfaces_hash_info += check_forward_type_and_interfaces(hash[:forward_type], tmp_interface_array.join('|')) # 检查转发类型与参数中新增的接口是否匹配
        end
        unless common_interface_array.empty?
          interfaces_hash_info += get_interfaces_hash_info(common_interface_array, hash[:forward_type])
        end

        data_hash = get_add_and_edit_zone_common_post_hash(hash, interfaces_hash_info)
        post_hash = {"opr" => "modify", "data" => data_hash }
        return post_hash
      end
      
      # 新增和编辑区域时post数据中的公共部分
      def get_add_and_edit_zone_common_post_hash(hash, interfaces_hash_info)
        data_hash = { "two" => {"enable" => false}, "three" => {"enable" => false}, "virtual" => {"enable" => false},
          "selectmerge" => { "ethSelect" => [] },
          "mgroption" => { "address" => "", "option" => [ "webui", "ssh", "snmp" ], "webui" => true, "ssh" => true, "snmp" => true } }
        data_hash["name"] = hash[:name]
        data_hash["type"] = convert_forward_type(hash[:forward_type])
        data_hash[data_hash["type"]]["enable"] = true
        data_hash["selectmerge"]["ethSelect"] = interfaces_hash_info

        if data_hash["type"] == "three" # 三层区域下才有效
          data_hash["mgroption"]["webui"] = hash[:enable_webui].to_logic
          data_hash["mgroption"]["ssh"] = hash[:enable_ssh].to_logic
          data_hash["mgroption"]["snmp"] = hash[:enable_snmp].to_logic
          data_hash["mgroption"]["option"].delete("snmp") unless data_hash["mgroption"]["snmp"]
          data_hash["mgroption"]["option"].delete("ssh") unless data_hash["mgroption"]["ssh"]
          data_hash["mgroption"]["option"].delete("webui") unless data_hash["mgroption"]["webui"]
          data_hash["mgroption"]["address"] = hash[:manage_address].split("&").join(",")
        end
        return data_hash
      end

      # 获取某个区域的某个属性,是编辑页面显示的属性
      def get_zone_original_setting(zone_name, attrs)
        post_hash = { "opr" => "listItem", "name" => "#{zone_name}" }
        attr_values = []
        result_hash = AF::Login.get_session().post(ZoneCGI, post_hash)
        if result_hash["success"]
          data_hash = result_hash["data"] # zone_name区域的所有信息
          attrs.each do |attr|
            case attr
            when "interfaces" # 当前区域包含的接口
              interfaces_info_hash = data_hash["selectmerge"]["ethSelect"] # 数组,元素是hash,[ {"text": "eth1", "value": 4}, {"text": "eth3", "value": 4 } ]
              ATT::KeyLog.info("名称是#{zone_name}的区域包含的接口有:#{interfaces_info_hash}")
              interface_name_array = [] # 数组,存放当前区域包含的接口名称
              interfaces_info_hash.each do |interface_hash|
                interface_name_array << interface_hash["text"]
              end
              attr_values.push( interface_name_array )
            when ""
              ATT::KeyLog.info("名称是#{zone_name}的区域")
              attr_values.push()
            end
          end
          return attr_values
        else
          ATT::KeyLog.info("获取区域的信息失败,请检查区域'#{zone_name}'是否存在")
          return_fail
        end
      end

      # 获取新增接口联动时要post的数据
      def get_add_interface_linkage_post_hash( hash )
        interfaces_avaliable = get_all_interfaces_avaliable_by_linkage() # 获取所有可供当前接口联动选取的接口,数组
        interfaces = hash[:interfaces].to_s.split("&")
        interfaces_not_existed = interfaces - interfaces_avaliable # 不可使用或不存在的接口
        unless interfaces_not_existed.empty?
          ATT::KeyLog.info("接口:#{interfaces_not_existed.join(',')}不可用或不存在")
          return_fail
        end
        interfaces_hash_selected = []
        interfaces.each do |interface|
          tmp_hash = {"text" => "#{interface}", "value" => ""}
          interfaces_hash_selected << tmp_hash unless interfaces_hash_selected.include?(tmp_hash)
        end
        
        data_hash = {"name" => "#{hash[:name]}", "selectmerge" => {"mergeItem" => interfaces_hash_selected } }
        post_hash = {"opr" => "add", "data" => data_hash }
        return post_hash
      end
      
      # 获取所有可供当前接口联动选取的接口,返回接口名称组成的数组
      def get_all_interfaces_avaliable_by_linkage()
        post_hash = { "opr" => "PortLinkage_ListAllMergeOption" }
        result_hash = AF::Login.get_session().post(InterfaceLinkageCGI, post_hash)
        if result_hash["success"]
          all_interfaces = result_hash["data"]
          return_interfaces = []
          all_interfaces.each do |interface_hash|
            return_interfaces << interface_hash["text"]
          end
          ATT::KeyLog.info("所有可供当前接口联动选取的接口:#{return_interfaces.join(',')}")
          return return_interfaces
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=begin
      # 获取所有接口联动的名称,返回数组
      def get_all_linkage_names
        names = [] # 存放所有接口联动的名称
        all_linkages = list_all_linkages
        all_linkages.each do |linkage|
          names << linkage["name"]
        end
        ATT::KeyLog.debug("所有接口联动的名称:#{names.join(',')}")
        return names
      end
      # 获取所有接口联动列表,返回数组,元素类型是hash
      def list_all_linkages
        post_hash = {"opr" => "list" }
        result_hash = AF::Login.get_session().post(InterfaceLinkageCGI, post_hash)
        if result_hash["success"]
          return result_hash["data"] # 数组的元素类型是hash
        else
          ATT::KeyLog.info("获取接口联动列表失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=end
    end
  end
end
