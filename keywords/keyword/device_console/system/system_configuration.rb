# coding: utf8
=begin rdoc
作用: 封装系统节点下系统配置页面上的操作
维护记录:
维护人      时间                  行为
gsj      2011-12-09             创建
=end

module DeviceConsole

  module System


=begin rdoc
类名: 系统配置
描述: 系统配置
=end
    class SystemConfiguration < ATT::Base

=begin rdoc
关键字名: 获取设备时间
描述: 获取设备时间,返回当前日期和当前时间,格式如2011-10-11,13\:20\:30
参数:
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def get_system_time(hash)
        ATT::KeyLog.debug("get system time of time......")
        post_hash = {"opr" => "list"}
        result_hash = AF::Login.get_session().post(SystemTimeCGI, post_hash)
        if result_hash["success"]
          date = result_hash["data"]["datetime"]["date"]
          time = result_hash["data"]["datetime"]["time"]
          ATT::KeyLog.info("系统日期:#{date},系统时间:#{time}")
          return [date, time.gsub(/:/, "\\:")]
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 设置设备时间
描述: 设置设备时间
参数:
id=>date,name=>日期,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"日期,格式2011-10-11"
id=>time,name=>时间,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"时间,格式13:20:30"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def set_system_time(hash)
        ATT::KeyLog.debug("get system time of time......")
        post_hash = get_set_system_time_post_hash( hash )
        result_hash = AF::Login.get_session().post(SystemTimeCGI, post_hash)
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
