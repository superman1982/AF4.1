# coding: utf8
module DeviceConsole
  module RunState
    module UserOnLineManagementHelper

      def get_ip_by_username(fatherpath, user_name)
        post_hash = {"opr" => "query", "limit" => "","start" => 0,"field" => "logintime","direction" => "DESC",\
            "group" => "#{fatherpath}"}
        # 查找用户组下的所有在线用户
        result_hash = AF::Login.get_session().post(UserManageOnLineCGI, post_hash)
        if result_hash["success"]
          result_hash["grid"]["data"].each do |item|
            if item["name"] == user_name
              ATT::KeyLog.info("用户组:#{fatherpath}下存在在线用户:#{user_name},其IP是#{item["ip"]}")
              return item["ip"]
            end
          end
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
        ATT::KeyLog.info("用户组:#{fatherpath}下不存在在线用户:#{user_name}")
        return_fail("用户不存在")
      end
      
    end
  end
end
