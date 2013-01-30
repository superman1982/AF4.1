# coding: utf8
module DeviceConsole
  module NetConfig
    module RouteHelper
      
      # 新增静态路由时,获取post的hash数据
      def get_add_single_static_route_post_hash( hash )
        data_hash = {"name" => ""}
        data_hash["dest_ip"] = "#{hash[:dest_address]}"
        data_hash["dest_mask"] = "#{hash[:netmask]}"
        data_hash["next_ip"] = "#{hash[:next_nop]}"
        data_hash["eth"] = "#{hash[:interface]}"
        data_hash["metric"] = hash[:metric_value].to_i

        post_hash = {"opr" => "addSgle", "data" => data_hash}
        return post_hash
      end

      # 获取指定路由的名称,返回数组
      def get_static_route_names( routes ) # 每个静态路由的格式如'目的地址/网络掩码/下一跳IP/度量值'
        route_array = routes.split("&")
        hash_info_of_static_routes = DeviceConsole::list_all_objects(StaticRouteCGI, "静态路由")
        static_route_name_array = []
        
        route_array.each do |route_str|
          route_name = -1 # route_str 对应的route 的name
          dest_ip, mask, next_ip, metric = route_str.split("/")
          if dest_ip.to_s.empty? || mask.to_s.empty? || next_ip.to_s.empty? || metric.to_s.empty?
            ATT::KeyLog.debug("静态路由:#{route_str}的格式错误")
            return_fail("静态路由格式错误")
          end
          hash_info_of_static_routes.each do |one_route_info|
            if one_route_info["destmask"] == mask && one_route_info["metric"] == metric.to_i && \
                one_route_info["dest"] == dest_ip && one_route_info["nexthop"] == next_ip
              route_name = one_route_info["name"] # 整型
              break
            end
          end
          if route_name == -1
            ATT::KeyLog.debug("静态路由:#{route_str}不存在")
            return_fail("静态路由不存在")
          end
          static_route_name_array << route_name
        end
        ATT::KeyLog.debug("静态路由:#{routes}的names:#{static_route_name_array.join(',')}")
        return static_route_name_array
      end

  
    end
  end
end
