# coding: utf8
module DeviceConsole
  module ObjectDefinition
    module IpGroupHelper

      # 获取新增IP组时要post的hash
      def get_add_ip_group_post_hash( hash )
        data_hash = { "name" => "#{hash[:group_name]}", "depict" => "#{hash[:description]}" }
        data_hash["ranges"] = hash[:ip_addresses].split("&").join("\r\n")
        post_hash = {"opr" => "add", "data"=> data_hash }
        return post_hash
      end

      # 获取当前所有IP组名称(不包含'全部'IP组),返回数组
      def get_all_ip_group_names()
        names = [] # 存放所有IP组的名称
        all_ip_groups = DeviceConsole::list_all_objects(ObjectIpGroupCGI, "IP组") # list_all_ip_groups
        all_ip_groups.each do |ip_group|
          names << ip_group["name"] unless ip_group["name"] == "全部"
        end
        ATT::KeyLog.debug("所有IP组的名称:#{names.join(',')}")
        return names
      end
=begin
      # 获取所有IP组列表,返回数组,元素类型是hash
      def list_all_ip_groups
        post_hash = {"opr" => "list"}
        result_hash = AF::Login.get_session().post(ObjectIpGroupCGI, post_hash)
        if result_hash["success"]
          return result_hash["data"] # 数组的元素类型是hash
        else
          ATT::KeyLog.info("获取IP组列表失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=end
      # 解析域名返回IP地址
      def get_ip_address_of_domain( retry_times, domain_name )
        post_hash = {"opr" => "dns", "data" => {"dns" => domain_name, "retry" => retry_times.to_i} }
        result_hash = AF::Login.get_session().post(ObjectIpGroupCGI, post_hash)
        if result_hash["success"]
          ip_address = result_hash["data"]["ip"]
          ATT::KeyLog.info("解析域名#{domain_name}成功:#{ip_address}")
          return ip_address # 数组的元素类型是hash
        else
          ATT::KeyLog.info("解析域名#{domain_name}失败,错误消息是#{result_hash["msg"]}")
          return_fail("解析域名失败")
        end
      end


    end
  end
end
