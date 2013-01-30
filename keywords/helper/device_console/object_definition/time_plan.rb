# coding: utf8
module DeviceConsole
  module ObjectDefinition
    module TimePlanHelper

      # 检查开始时间是否不大于结束时间
      def compare_start_time_and_end_time(start_time, end_time)
        s_time = start_time.gsub(/#/, ' ').to_time
        e_time = end_time.gsub(/#/, ' ').to_time
        ATT::KeyLog.info("开始时间:#{s_time},结束时间:#{e_time}")
        return_fail("开始时间大于结束时间") if s_time > e_time
      end
      
      # 获取新增单次时间计划时要post的数据
      def get_add_single_time_plan_post_hash( hash )
        sdate, stime = hash[:start_time].split("#")
        edate, etime = hash[:end_time].split("#")
        ATT::KeyLog.info("开始日期:#{sdate},开始时间:#{stime},结束日期:#{edate},结束时间:#{etime}")
        data_hash = {"name"=>hash[:name],"sdate"=>"#{sdate}","stime"=>"#{stime}","edate"=>"#{edate}","etime"=>"#{etime}"}
        post_hash = {"opr" => "add", "data" => data_hash}
        return post_hash
      end

      # 获取新增循环时间计划时要post的数据
      def get_add_loop_time_plan_post_hash( hash )
        time_array = []
        slot_array = hash[:time_slots].to_s.split("&")
        slot_array.each do |time_slot| # time_slot的格式: 星期二-星期三##12点05分-18点30分
          dates, times = time_slot.to_s.split("##")
          sday, eday = dates.to_s.split("-") # 星期二, 星期三
          stime, etime = times.to_s.split("-") # 12点05分, 18点30分
          if sday.to_s.empty? || eday.to_s.empty? || stime.to_s.empty? || etime.to_s.empty?
            ATT::KeyLog.info("错误的时间段格式:#{time_slot}")
            return_fail("时间段格式错误")
          end
          start_day = convert_day_per_week(sday) # 整型
          end_day = convert_day_per_week(eday) # 整型
          start_hour, start_minute = convert_hour_and_minute(stime)  # 二者都是整型
          end_hour, end_minute = convert_hour_and_minute(etime)  # 二者都是整型
          compare_start_and_end(start_day, end_day, start_hour, start_minute, end_hour, end_minute)
          one_time_slot = [ {"h" => start_hour, "m" => start_minute}, {"h" => end_hour, "m" => end_minute} ]
          time_array << {"day" => [start_day, end_day], "time" => one_time_slot }
        end
        data_hash = { "name" => hash[:name], "depict" => hash[:description], "time" => time_array}
        post_hash = {"opr" => "add", "data" => data_hash}
        return post_hash
      end

      # 周期转换成对应的数字
      def convert_day_per_week(day)
        tmp_hash = {"星期一" => 1, "星期二" => 2, "星期三" => 3, "星期四" => 4, "星期五" => 5, "星期六" => 6, "星期日" => 0}
        return tmp_hash["#{day}"] if tmp_hash.has_key?("#{day}")
        return_fail("不支持的周期")
      end
      # 将'18点30分'转换成[18,30]
      def convert_hour_and_minute(time_str)
        if !time_str.include?("点") || !time_str.include?("分")
          ATT::KeyLog.info("错误的时间格式:#{time_str}")
          return_fail("时间格式错误")
        end
        time_str.gsub!(/分/, '')
        hour, minute = time_str.split("点")
        ATT::KeyLog.info("#{time_str}转换为:#{hour},#{minute}")
        return [ hour.to_i, minute.to_i ]
      end
      # 比较开始周期和结束周期,比较开始时间和结束时间
      def compare_start_and_end(start_day, end_day, start_hour, start_minute, end_hour, end_minute)
        startday = (start_day == 0 ? 7 : start_day)
        endday = (end_day == 0 ? 7 : end_day)
        if startday > endday # 正确的: start_day <= end_day && start_hour:start_minute < end_hour:end_minute
          ATT::KeyLog.info("开始周期#{startday}大于结束周期#{endday}")
          return_fail("开始周期应不大于结束周期")
        end
        if (start_hour * 60 + start_minute) >= (end_hour * 60 + end_minute)
          ATT::KeyLog.info("开始时间#{start_hour}:#{start_minute}不小于结束时间#{end_hour}:#{end_minute}")
          return_fail("开始时间应小于结束时间")
        end
      end

      # 获取当前所有循环时间计划名称(不包含'全天'时间计划),返回数组
      def get_all_loop_time_plan_names
        names = [] # 存放所有循环时间计划的名称
        all_loop_time_plans = DeviceConsole::list_all_objects(LoopTimePlanCGI, "循环时间计划") # 数组类型,元素是hash类型
        all_loop_time_plans.each do |loop_time_plan|
          names << loop_time_plan["name"] unless loop_time_plan["name"] == "全天"
        end
        ATT::KeyLog.debug("所有循环时间计划的名称:#{names.join(',')}")
        return names
      end

    
    end
  end
end
