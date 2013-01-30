# coding: utf8
=begin rdoc
作用: 封装应用控制策略页面上的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-08              创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module ContentSecurity


=begin rdoc
类名: 应用控制策略
描述: 应用控制策略
=end
    class ApplicationControlStrategy < ATT::Base

=begin rdoc
关键字名: 新增应用控制策略
描述: 新增应用控制策略
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"应用控制策略的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此应用控制策略"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>source_group_type,name=>源用户类型,type=>s,must=>false,default=>"IP组",value=>"IP组|用户组",descrip=>"源用户选择IP组还是用户组"
id=>source_ip,name=>源IP组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当源用户选择IP组时,选择的IP组,多个时使用&分割"
id=>source_user,name=>源用户组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当源用户选择用户组时,选择的用户或组,若是用户组则使用其全路径,如'/默认组/',若是用户则直接使用用户名,多个时使用&分割,格式如'/默认组/&test'"
id=>dest_zone,name=>目的区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"目的区域,多个时使用&分割"
id=>dest_ip,name=>目的IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"目的IP组,多个时使用&分割"
id=>app_type,name=>控制类型,type=>s,must=>false,default=>"服务",value=>"服务|应用",descrip=>"服务/应用中勾选服务还是应用"
id=>services,name=>服务,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"服务/应用中勾选服务时,选择的服务,格式如'自定义服务/全部&预定义服务/ping&服务组/gtest'"
id=>apps,name=>应用,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"服务/应用中勾选应用时,选择的应用,格式如'IM传文件/阿里旺旺&HTTP应用/HTTP_POST&其他应用/其他应用'"
id=>take_effect_time,name=>生效时间,type=>s,must=>false,default=>"全天",value=>"{text}",descrip=>"生效时间,时间计划的名称"
id=>operation,name=>动作,type=>s,must=>false,default=>"允许",value=>"允许|拒绝",descrip=>"拒绝还是允许"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用勾选记录日志"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_application_control_strategy(hash)
        ATT::KeyLog.debug("add application control strategy......")
        post_hash = get_add_application_control_strategy_post_hash( hash )
        result_hash = AF::Login.get_session().post(ApplicationControlCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除应用控制策略
描述: 删除应用控制策略,删除类型选择全部删除时,删除除'默认策略'外的所有策略
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的应用控制策略,还是删除目前所有的应用控制策略"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的应用控制策略名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_application_control_strategy(hash)
        ATT::KeyLog.debug("delete application control strategy......")
        if hash[:delete_type] == "全部删除"
          all_appctrl_strategy_names = get_all_appctrl_strategy_names() # 数组类型,不包含'默认策略'
        else
          all_appctrl_strategy_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_appctrl_strategy_names.empty? # 不存在除'默认策略'外的任何应用控制策略时,直接返回成功
        post_hash = {"opr" => "delete", "name" => all_appctrl_strategy_names}
        result_hash = AF::Login.get_session().post(ApplicationControlCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 检查应用控制策略
描述: 在应用控制策略列表页面上,检查指定名称应用控制策略的设置是否与期望一致
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要检查的应用控制策略的名称"
id=>source_zone,name=>源区域,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的源区域,多个时使用&分割,为空时不检查此参数"
id=>source_user_ip,name=>源IP用户,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的源IP/用户,多个时使用&分割,为空时不检查此参数"
id=>dest_zone,name=>目的区域,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的目的区域,多个时使用&分割,为空时不检查此参数"
id=>dest_ip,name=>目的IP组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的目的IP组,多个时使用&分割,为空时不检查此参数"
id=>service_app,name=>服务应用,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的服务/应用,多个时使用&分割,为空时不检查此参数"
id=>take_effect_time,name=>生效时间,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望的生效时间,某个时间计划的名称,为空时不检查此参数"
id=>operation,name=>动作,type=>s,must=>false,default=>"忽略",value=>"允许|拒绝|忽略",descrip=>"期望的动作,忽略表示不检查此参数"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"忽略",value=>"是|否|忽略",descrip=>"期望是否记录日志,忽略表示不检查此参数"
id=>status,name=>状态,type=>s,must=>false,default=>"忽略",value=>"启用|禁用|忽略",descrip=>"期望的状态,忽略表示不检查此参数"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|应用控制策略不存在|源区域错误|源IP用户错误|目的区域错误|目的IP组错误|服务应用错误|生效时间错误|动作错误|记录日志错误|状态错误",descrip=>""
=end
      def check_application_control_strategy(hash)
        ATT::KeyLog.debug("检查应用控制策略#{hash[:name]}的设置")
        all_appctrl_strategys = DeviceConsole::list_all_objects_with_limit(ApplicationControlCGI, "应用控制策略")
        all_appctrl_strategys.each do |appctrl_strategy|
          if appctrl_strategy["name"] == hash[:name]
            check_appctrl_strategy_setting(appctrl_strategy, hash ) # 检查应用控制策略的设置是否与期望一致
          end
        end
        ATT::KeyLog.info("应用控制策略#{hash[:name]}不存在")
        return_fail("应用控制策略不存在")
      end

=begin rdoc
关键字名: 检查应用控制策略数目
描述: 检查应用控制策略当前的数目
参数:
id=>count,name=>策略数,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"期望存在的策略数目"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|策略数目错误",descrip=>""
=end
      def check_application_control_strategy_count(hash)
        post_hash = {"opr" => "list", "start" => 0, "limit" => 65535 }
        result_hash = AF::Login.get_session().post(ApplicationControlCGI, post_hash)
        if result_hash["success"]
          real_strategy_count = result_hash["count"]
          if real_strategy_count == hash[:count].to_i
            return_ok
          else
            ATT::KeyLog.info("实际应用控制策略数目是:#{real_strategy_count},期望策略数目是:#{hash[:count].to_i}")
            return_fail("策略数目错误")
          end
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end

=begin rdoc
关键字名: 启禁应用控制策略
描述: 启用或禁用应用控制策略
参数:
id=>names,name=>策略名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要启用或禁用的应用控制策略的名称,多个时使用&分割"
id=>operation,name=>操作,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"启用还是禁用指定的应用控制策略"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_application_control_strategy( hash )
        operation = (hash[:operation] == "启用" ? "enable" : "disable")
        post_hash = {"opr" => operation, "name" => hash[:names].split("&") }
        result_hash = AF::Login.get_session().post(ApplicationControlCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end

      
    end
  end
end
