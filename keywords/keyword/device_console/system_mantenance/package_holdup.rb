# coding: utf8
=begin rdoc
作用: 封装数据包拦截日志与直通页面上的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-08              创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module SystemMantenance


=begin rdoc
类名: 数据包拦截日志与直通
描述: 数据包拦截日志与直通
=end
    class PackageHoldup < ATT::Base

=begin rdoc
关键字名: 启禁实时拦截日志
描述: 启用或禁用实时拦截日志
参数:
id=>operation,name=>操作,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"启用还是禁用实时拦截日志"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_realtime_holdup_log(hash)
        ATT::KeyLog.debug("enable or disable realtime holdup log......")
        post_hash = get_enable_disable_realtime_holdup_log_post_hash( hash )
        result_hash = AF::Login.get_session().post(TraceDropCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 开启实时拦截日志并直通
描述: 开启实时拦截日志并直通
参数:
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_realtime_holdup_log_and_bypass(hash)
        ATT::KeyLog.debug("enable realtime holdup log and bypass......")
        post_hash = {"opr" => "bypass", "name" => ""} # null
        result_hash = AF::Login.get_session().post(TraceDropCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 设置开启条件并开启
描述: 设置开启条件并开启实时拦截日志
参数:
id=>accept_ips,name=>指定IP地址,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"指定IP地址,可以是单个IP,IP范围,子网,多个时使用&分割"
id=>reject_ips,name=>排除IP地址,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"排除IP地址,可以是单个IP,IP范围,子网,多个时使用&分割"
id=>protocol,name=>协议类型,type=>s,must=>false,default=>"所有",value=>"所有|TCP|UDP|ICMP|其他",descrip=>"协议类型"
id=>protocol_num,name=>协议号,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择其他时,输入的协议号,可为空"
id=>port_type,name=>端口类型,type=>s,must=>false,default=>"所有端口",value=>"所有端口|指定端口",descrip=>"协议类型选择TCP或UDP时,勾选的端口类型"
id=>port,name=>指定端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"端口类型选择指定端口时,输入的端口号,可为空"
id=>operation,name=>操作,type=>s,must=>false,default=>"开启",value=>"开启|开启并直通",descrip=>"点击开启实时拦截日志,还是开启实时拦截日志并直通"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def set_enable_condition_and_enable(hash)
        post_hash = get_set_enable_condition_and_enable_post_hash( hash )
        result_hash = AF::Login.get_session().post(TraceDropCGI, post_hash)
        if result_hash["success"] # 设置开启条件成功
          if hash[:operation] == "开启" # 不选择直通
            post_hash = {"opr" => "open"}
            ATT::KeyLog.info("设置开启条件成功,现开启...")
          else
            post_hash = {"opr" => "bypass"}
            ATT::KeyLog.info("设置开启条件成功,现开启并直通...")
          end
          result_hash = AF::Login.get_session().post(TraceDropCGI, post_hash)
          if result_hash["success"] # 开启或开启并直通成功
            return_ok
          else
            ATT::KeyLog.info("开启或开启并直通失败,错误消息是#{result_hash["msg"]}")
            return_fail
          end
        else
          ATT::KeyLog.info("设置开启条件失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 查看实时拦截日志
描述: 查看实时拦截日志,实时日志中有一条记录符合指定的条件就行
参数:
id=>s_ip,name=>源,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源"
id=>operation,name=>动作,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"动作,控制台列表中对应的列包含此参数值即可,不必完全相同"
id=>protocol,name=>协议,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"使用的协议"
id=>content,name=>源到目标,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源到目标,控制台列表中对应的列包含此参数值即可,不必完全相同"
id=>device,name=>设备,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"设备"
id=>link,name=>线路,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"线路"
id=>drop_flag,name=>丢包标记,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"丢包标记"
id=>app_name,name=>应用名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"应用名称"
id=>app_rule,name=>应用规则,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"应用规则"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|无拦截日志",descrip=>""
=end
      def check_realtime_holdup_logs(hash)
        ATT::KeyLog.debug("check realtime holdup logs......")
        realtime_log_array = DeviceConsole::list_all_objects(TraceDropCGI, "实时拦截日志")
        return_fail("无拦截日志") if realtime_log_array.empty?
        check_holdup_logs(realtime_log_array, hash ) # 检查实时拦截日志,是否包含指定条件对应的记录
      end


    end
  end
end
