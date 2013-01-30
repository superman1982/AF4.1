# coding: utf-8
module DeviceConsole
  module RunState
    module FluxViewHelper
      # => 定义的上下限(check_data),和检测的hash,以及得出的类型,来检测是否符合预期
      # check_data 上下限数组
      # data_hash 获得的某个线路 的哈希
      # type 要检测的哈希对应键值数组
      # 返回真假,抛出ATT失败异常
      def check_up_down(direction,check_data,data_hash,type)
        # => 上传或下载
        case direction
        when "上传"
          # => 上传值大于等于下限,小于等于上限
          if data_hash[type][0].to_i >= check_data[0].to_i and data_hash[type][0].to_i <= check_data[1].to_i
            ATT::KeyLog.info("符合预期速度~!当前上传为:: #{data_hash[type][0]}")
            return true
          else
            ATT::KeyLog.info("没有符合预期速度~!当前上传为:: #{data_hash[type][0]}")
          end
        when "下载"
          # => 上传值大于等于下限,小于等于上限
          if data_hash[type][1].to_i >= check_data[0].to_i and data_hash[type][1].to_i <= check_data[1].to_i
            ATT::KeyLog.info("符合预期速度~!当前下载为:: #{data_hash[type][1]}")
            return true
          else
            ATT::KeyLog.info("没有符合预期速度~!当前下载为:: #{data_hash[type][1]}")
          end
        else
          ATT::KeyLog.error("不是上传也不是下载,不可能走到这里的")
          return_fail
        end
        return false
      end

      def check_n_times_data(hash,send_hash,info)
        pass_time = 0
        hash[:check_times].to_i.times {
          return_data = DeviceConsole::list_all_objects(FluxViewCgi,info,send_hash)
          is_check_ok = check_data(hash,return_data)
          if is_check_ok
            pass_time += 1 
          else
            ATT::KeyLog.info("#{info}没有达到预期")
          end
          sleep 1
        }
        if pass_time >= hash[:check_times].to_i * 0.6
          ATT::KeyLog.info("#{info}达到预期,pass_time = #{pass_time} hash[:check_times] = #{hash[:check_times]}")
          return_ok
        else
          ATT::KeyLog.error("#{info}没有达到预期!!!!,pass_time = #{pass_time} hash[:check_times] = #{hash[:check_times]}")
          return_fail
        end
      end

      
      def check_data(hash,data_array)
        if not data_array.kind_of?(Array)
          ATT::KeyLog.error("进来的Data数据不是数组,下面是具体的data数据::")
          ATT::KeyLog.error(data_array)
          return_fail
        end
        data_array.each { |data_hash|
          # => 先匹配线路名字,名字一致后匹配其他
          if data_hash["name"] == hash[:name]
            check_data = hash[:check_data].split("@;@")
            if check_data[0].to_i > check_data[1].to_i or check_data.length != 2
              ATT::KeyLog.error("检测范围的值错了~!!数据::#{hash[:check_data]}")
              return_fail
            end
            # => 速率或百分比
            if hash[:check_type] == "速率"
              return check_up_down(hash[:check_direction],check_data,data_hash,"instantaneous")
            elsif hash[:check_type] == "百分比"
              if check_data[0].to_i > 100 or check_data[1].to_i > 100
                ATT::KeyLog.error("检测范围的百分比错了~!!数据::#{check_data.join(",")}")
                return_fail
              end
              return check_up_down(hash[:check_direction],check_data,data_hash,"proportion")
            else
              ATT::KeyLog.error("不是速率也不是百分比,不可能走到这里的")
              return_fail
            end
          end
        }
        ATT::KeyLog.error("没有一个线路名称名字,名称是#{hash[:name]}")
        return_fail
      end
    end
  end
end
