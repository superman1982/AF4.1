# coding: utf8
=begin rdoc
作用: 运行状态下的在线用户管理
维护记录:
维护人      时间                  行为
gsj      2012-01-09             创建
=end
require "zlib"

module DeviceConsole

  module RunState


=begin rdoc
类名: 在线用户管理
描述: 在线用户管理
=end
    class UserOnLineManagement < ATT::Base

=begin rdoc
关键字名: 注销在线用户
描述: 处理在线用户
参数:
id=>usernames,name=>用户名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要注销的用户名,多个时使用&分隔"
id=>fatherpath,name=>父组,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"注销用户所属的父组,必须是全路径,如/AF"
id=>ip,name=>ip,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"注销某个ip对应的用户时,此用户的IP地址"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|用户不存在",descrip=>"期望结果,默认成功"
=end
      def force_logoff_user(hash)
        post_hash = {"opr" => "logoff",  "name" => [] }
        fatherpath = hash[:fatherpath] + '/' if hash[:fatherpath] != '/' && hash[:fatherpath] !~ /\/$/
        fatherpath = hash[:fatherpath] if hash[:fatherpath] == '/'
        crc = Zlib.crc32(fatherpath)
        hash[:usernames].split("&").each do |user_name|
          tmp_hash = {"GrpCrc" => crc }
          if hash[:ip].to_s.empty?
            tmp_hash["IP"] = get_ip_by_username(fatherpath, user_name)
          else
            tmp_hash["IP"] = hash[:ip]
          end
          post_hash["name"] << tmp_hash
        end
        result_hash = AF::Login.get_session().post(UserManageOnLineCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end



    end
  end
end
