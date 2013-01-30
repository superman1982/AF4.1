# coding: utf8
=begin rdoc
作用: 封装对象定义下时间计划的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-07              创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module ObjectDefinition


=begin rdoc
类名: 时间计划
描述: 时间计划
=end
    class TimePlan < ATT::Base

=begin rdoc
关键字名: 新增单次时间计划
描述: 新增单次时间计划
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"时间计划的名称"
id=>start_time,name=>开始时间,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"时间格式是'2011-12-07#12:30:05'"
id=>end_time,name=>结束时间,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"时间格式是'2011-12-07#12:30:10'"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|开始时间大于结束时间",descrip=>""
=end
      def add_single_time_plan(hash)
        ATT::KeyLog.debug("add single time plan......")
        compare_start_time_and_end_time("#{hash[:start_time]}", "#{hash[:end_time]}") # 检查开始时间是否不大于结束时间
        post_hash = get_add_single_time_plan_post_hash( hash )
        result_hash = AF::Login.get_session().post(SingleTimePlanCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除单次时间计划
描述: 删除单次时间计划
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的单次时间计划,还是删除目前所有的单次时间计划"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定单次时间计划的名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_single_time_plan(hash)
        ATT::KeyLog.debug("delete single time plans......")
        if hash[:delete_type] == "全部删除"
          all_single_time_plan_names = DeviceConsole::get_all_object_names(SingleTimePlanCGI, "单次时间计划") # 数组类型
        else
          all_single_time_plan_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_single_time_plan_names.empty?
        post_hash = {"opr" => "delete", "name" => all_single_time_plan_names}
        result_hash = AF::Login.get_session().post(SingleTimePlanCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增循环时间计划
描述: 新增循环时间计划
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"时间计划的名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>time_slots,name=>时间段,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"每个时间段的格式是'星期二-星期三##12点05分-18点30分',多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|不支持的周期|时间格式错误|时间段格式错误|开始周期应不大于结束周期|开始时间应小于结束时间",descrip=>""
=end
      def add_loop_time_plan(hash)
        ATT::KeyLog.debug("add loop time plan......")
        post_hash = get_add_loop_time_plan_post_hash( hash )
        result_hash = AF::Login.get_session().post(LoopTimePlanCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除循环时间计划
描述: 删除循环时间计划,当删除类型选择全部删除时,不删除'全天'时间计划
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的循环时间计划,还是删除目前所有的循环时间计划"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定循环时间计划的名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_loop_time_plan(hash)
        ATT::KeyLog.debug("delete loop time plans......")
        if hash[:delete_type] == "全部删除"
          all_loop_time_plan_names = get_all_loop_time_plan_names() # 数组类型,不包含'全天'时间计划
        else
          all_loop_time_plan_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_loop_time_plan_names.empty?
        post_hash = {"opr" => "delete", "name" => all_loop_time_plan_names}
        result_hash = AF::Login.get_session().post(LoopTimePlanCGI, post_hash)
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
