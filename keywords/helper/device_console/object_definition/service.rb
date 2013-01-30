# coding: utf8
module DeviceConsole
  module ObjectDefinition
    module ServiceHelper

      # 获取新增服务组时要post的hash
      def get_add_service_group_post_hash( hash )
        data_hash = { "name" => "#{hash[:name]}", "desc" => "#{hash[:description]}" }
        data_hash["service"] = hash[:services].split("&").join(",")
        post_hash = {"opr" => "add", "data"=> data_hash }
        return post_hash
      end
=begin
      # 获取当前所有的服务组的名称,返回数组类型
      def get_all_service_group_names()
        names = [] # 存放所有服务组的名称
        all_service_groups = list_all_service_groups
        all_service_groups.each do |service_group|
          names << service_group["name"]
        end
        ATT::KeyLog.debug("所有服务组的名称:#{names.join(',')}")
        return names
      end
      # 获取所有服务组列表,返回数组,元素类型是hash
      def list_all_service_groups
        post_hash = {"opr" => "list"}
        result_hash = AF::Login.get_session().post(ServiceGroupCGI, post_hash)
        if result_hash["success"]
          return result_hash["data"] # 数组的元素类型是hash
        else
          ATT::KeyLog.info("获取服务组列表失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=end
      # 获取新增自定义服务时要post的hash
      def get_add_custom_service_post_hash( hash )
        data_hash = { "name" => "#{hash[:name]}", "desc" => "#{hash[:description]}" }
        data_hash["tcp"] = hash[:tcp].split("&").join("\r\n")
        data_hash["udp"] = hash[:udp].split("&").join("\r\n")
        data_hash["icmp"] = hash[:icmp].split("&").join("\r\n")
        data_hash["other"] = hash[:other]
        
        post_hash = {"opr" => "add", "data"=> data_hash }
        return post_hash
      end
=begin
      # 获取当前所有的自定义服务的名称,返回数组类型
      def get_all_custom_service_names()
        names = [] # 存放所有自定义服务的名称
        all_custom_services = list_all_custom_services
        all_custom_services.each do |custom_service|
          names << custom_service["name"]
        end
        ATT::KeyLog.debug("所有自定义服务的名称:#{names.join(',')}")
        return names
      end
      # 获取所有自定义服务列表,返回数组,元素类型是hash
      def list_all_custom_services
        post_hash = {"opr" => "list"}
        result_hash = AF::Login.get_session().post(CustomService, post_hash)
        if result_hash["success"]
          return result_hash["data"] # 数组的元素类型是hash
        else
          ATT::KeyLog.info("获取自定义服务列表失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=end



    end
  end
end
