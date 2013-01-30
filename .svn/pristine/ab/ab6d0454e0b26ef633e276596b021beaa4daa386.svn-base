# coding: utf8
module DeviceConsole
  module System
    module SystemConfigurationHelper

      def get_set_system_time_post_hash( hash )
        data_hash = {"zone" => { "select" => "+8" }, "sync" => { "server" => "pool.ntp.org" }}
        data_hash["datetime"] = {"date" => "#{hash[:date]}", "time" => "#{hash[:time]}"}

        post_hash = { "opr" => "modify", "data" => data_hash }
        return post_hash
      end
      
    end
  end
end
