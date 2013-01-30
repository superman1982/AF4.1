# coding: utf8
module DeviceConsole
  module NetConfig
    module VirtualCableHelper

      # 获取新增虚拟网线时要post的数据
      def get_add_virtual_cable_post_hash( hash )
        data_hash = {"name" => hash[:name], "description" => hash[:description] }
        data_hash["line_one"] = "#{hash[:interface1]}"
        data_hash["line_two"] = "#{hash[:interface2]}"

        post_hash = { "opr" => "add", "data" => data_hash }
        return post_hash
      end


    end
  end
end
