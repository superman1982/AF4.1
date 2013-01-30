# coding: utf8
module DeviceConsole
  module RunState
    module IpBlockStatHelper
      # 解除封锁IP 时要post的数据
      def get_relieve_ipblock_post_hash( hash )
        ids = []
        hash[:block_ip_str].split("&").each do |ip_str|
          ids << ip_str
        end
        post_hash = {"opr" => "deblock", "ids" => ids, "clearall" => false}
        return post_hash
      end

      # 清除所有封锁IP 时要post的数据
      def get_clear_ipblock_post_hash( hash )
        ids = []
        DeviceConsole::get_all_object_attrib(IP_BLOCK_STAT_CGI, " 封锁IP ", "ip").each do |ip_str|
          ids << ip_str
        end
        post_hash = {"opr" => "deblock", "ids" => ids, "clearall" => true}
        return post_hash
      end

    end
  end
end
