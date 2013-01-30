# coding: utf8
module DeviceConsole
  module NetConfig
    module AdvancedNetConfigHelper

      #构造ARP表POST的json数据
      def create_arp_json(hash)
        data_hash ={"name" => "","ipAddress" => hash[:ip_address],"rst_status" => "正在获取...",\
            "macAddress" => hash[:mac_address],"ethName" => hash[:eth]
        }
        return data_hash
      end
      #获取新增ARP表项时要Post的数据
      def get_add_arp_table_post_hash(hash)
        data_hash = create_arp_json(hash)
        post_hash = {"opr" => "add","data" => data_hash}
        return post_hash
      end
      #获取arp表项IP所对应的ID，即name
      def get_arp_name(ip)
        post_hash = {"opr" =>"list"}
        result_hash = AF::Login.get_session().post(ArpConfigCGI, post_hash)
        if result_hash["success"]
          all_objects = result_hash["data"] # 数组的元素类型是hash
          all_objects.each do |object|
            if object["ipAddress"] == ip
              return object["name"]
            end
          end
          ATT::KeyLog.debug("输入的IP地址的不存在。。。。。")
          return_fail
        else
          ATT::KeyLog.info("获取地址:#{ip}的名称失败,错误消息是#{result_hash["msg"]}")
          raise ATT::Exceptions::NotFoundError,"获取列表失败"
        end
      end
      #获取编辑ARP表项时要Post的数据
      def get_edit_arp_table_post_hash(hash)
        if(hash[:ip_address] == "")
          hash[:ip_address] = hash[:old_ip_address]
        end
        data_hash = create_arp_json(hash)
        id = get_arp_name(hash[:old_ip_address])
        post_hash = {"opr" => "modify","id" => id,"data" => data_hash}
        return post_hash
      end
      # 获取设置DNS时要Post的数据
      def get_set_dns_server_and_proxy_post_hash( hash )
        # 初始值,下面再修改
        data_hash = {"dns_server" => {}, "dns_proxy" => {} }
        data_hash["dns_proxy"]["proxy_enable"] = {"enable" => false}
        data_hash["dns_proxy"]["proxy_disable"] = {"enable" => false}
        # 根据参数重新赋值
        data_hash["dns_server"]["first_dns"] = hash[:first_dns]
        data_hash["dns_server"]["second_dns"] = hash[:secondary_dns]
        if hash[:enable_dns_proxy].to_logic
          data_hash["dns_proxy"]["dnsproxy"] = "proxy_enable"
          data_hash["dns_proxy"]["proxy_enable"]["enable"] = true
        else
          data_hash["dns_proxy"]["dnsproxy"] = "proxy_disable"
          data_hash["dns_proxy"]["proxy_disable"]["enable"] = true
        end

        post_hash = {"opr" => "modify", "type" => "dns", "data" => data_hash}
        return post_hash
      end

      # 获取新增snmp管理主机时要Post的数据
      def get_add_snmp_host_manager_post_hash( hash )
        address_type = (hash[:addr_type] == "主机" ? 1 : 2)
        data_hash = {"name" => hash[:name], "addresstype" => address_type, "ipaddr" => hash[:address], "associatename" => hash[:community_name]}
        post_hash = {"opr" => "add", "data" => data_hash}
        return post_hash
      end
       # 获取新增snmp管理主机时要Post的数据
      def get_edit_snmp_host_manager_post_hash( hash )
        address_type = (hash[:addr_type] == "主机" ? 1 : 2)
        data_hash = {"name" => hash[:name], "addresstype" => address_type, "ipaddr" => hash[:address], "associatename" => hash[:community_name]}
        post_hash = {"opr" => "modify", "data" => data_hash}
        return post_hash
      end
      #获取编辑DHCP服务时要Post的数据
      def get_edit_dhcp(hash)
        param_hash = {"gw" => hash[:gw],"mask" => hash[:mask],"master_dns" => hash[:master_dns],\
            "slave_dns" => hash[:slave_dns],"master_wins" => hash[:master_wins],"slave_wins" => hash[:slave_wins]
        }
        range = hash[:range].split("&").join("\n")
        range_hash = {"range" => range}
        reserved_ip_hash = []
        groupcut = hash[:reserved].split("&")
        groupcut.each do |group|
          grouplist = group.split('/')
          list_hash = {"name" => grouplist[0].to_s,"ip" => grouplist[1].to_s,"mac" => grouplist[2].to_s,"machine" => grouplist[3].to_s}
          reserved_ip_hash << list_hash
        end
        reserved_hash = {"reserved_ip" => {"reserved" => reserved_ip_hash}}
        data_hash = {"interface" => hash[:interface],"lease" => hash[:lease],"param" => param_hash,"ip_range" => range_hash ,\
            "reserved" => reserved_hash
        }
        post_hash = {"opr" => "modify","data" => data_hash}
        return post_hash
      end
      #构造SNMP V3规则POST的json数据
      def create_snmp_v3_json(hash)
        if(hash[:safelevel] == "加密")
          safelevel = 1
        else
          safelevel = 2
          hash[:prikey] = ""
          hash[:confirm_prikey] = ""
        end
        data_hash ={"name" => hash[:name],"pubkey" => hash[:pubkey],"confirm_pubkey" => hash[:confirm_pubkey],\
            "prikey" => hash[:prikey],"confirm_prikey" => hash[:confirm_prikey],"safelevel" =>safelevel}
        return data_hash
      end
      #获取新增SNMP V3规则Post的数据
      def get_add_snmp_v3_rule_post_hash(hash)
        data_hash = create_snmp_v3_json(hash)
        post_hash = {"opr" => "add","data" => data_hash}
        return post_hash
      end
      #获取编辑SNMP V3规则Post的数据
      def get_edit_snmp_v3_rule_post_hash(hash)
        data_hash = create_snmp_v3_json(hash)
        post_hash = {"opr" => "modify","data" => data_hash}
        return post_hash
      end

    end
  end
end
