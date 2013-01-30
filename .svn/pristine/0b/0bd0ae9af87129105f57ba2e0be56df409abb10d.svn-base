# coding: utf8
module DeviceBack
  module NetworkOperationHelper

    # 检查链路检测间隔
    def link_check_interval(tcpdump_result, interval_hoped)
      seconds_array = [] # 存放发起DNS请求时的时间
      tcpdump_result.each_line do |line|
        temp = line.split()[0].to_s  # 每行中第一个空格之前的内容
        if temp =~ /.*:.*:/ && line =~ /A\?/ # 是链路检测时的包
          time_str = temp.split(".")[0].to_s
          ATT::KeyLog.debug(time_str)
          hour, minute, second = time_str.split(":")
          seconds_array.push(second.to_i) unless seconds_array.include?(second.to_i)
        end
      end
      # 对比各时间,检测相邻两个间的间隔
      wrong_size = 0
      seconds_array.each_index do |index|
        if index + 1 < seconds_array.size()
          interval = seconds_array[index + 1] - seconds_array[index]
          interval += 60 if interval < 0 # 跨分钟了
          if interval != interval_hoped.to_i
            wrong_size += 1
            ATT::KeyLog.debug("实际间隔#{interval}(#{seconds_array[index + 1]}-#{seconds_array[index]})!=期望间隔#{interval_hoped}")
          end
        end
      end
      if wrong_size > 2
        ATT::KeyLog.debug("抓包结果:\n#{tcpdump_result}")
        return_fail
      end
      return_ok
    end

    # 检查是否已经有tcpdump进程存在,若有则全部杀掉
    def kill_tcpdump_processes_existed( devicename )
      ssh_connection = ATT::TestDevice.new( devicename )
      ps_value, ps_result = ssh_connection.exec_command( PS_GREP_TCPDUMP )
      ATT::KeyLog.error("执行命令:#{PS_GREP_TCPDUMP}的返回值是#{ps_value},返回结果是:\n#{ps_result}")
      begin
        tcpdump_pid_array = DeviceBack::get_pid_from_jobs(ps_result, "tcpdump") # 从ps aux | tcpdump的结果中查找出进程的ID
      rescue ATT::Exceptions::NotFoundError # 当前无tcpdump进程存在
        ATT::KeyLog.error("当前无tcpdump进程存在")
      end
      if defined?(tcpdump_pid_array) && !tcpdump_pid_array.nil? && !tcpdump_pid_array.empty?
        tcpdump_pid_array.each do |pid|
          ssh_connection.exec_command("kill -9 #{pid}")
          ATT::KeyLog.info("已强制杀死进程:#{pid}")
        end
      end
    end
    
  end
end
