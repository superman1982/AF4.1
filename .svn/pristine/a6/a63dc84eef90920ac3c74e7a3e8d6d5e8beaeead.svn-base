=begin rdoc
模块名: 设备后台
描述: 封装设备后台的操作
=end
module DeviceBack

  module_function

  # 从ps aux | grep process的结果中查找出进程的ID
  def get_pid_from_jobs(ps_result, process)
    pid_array = []
    process_escape = Regexp.escape(process)
    ps_result.each do |line|
      if line =~ /#{process_escape}/ && line !~ /grep/
        line_arr = line.to_s.split
        ATT::KeyLog.info("找到了指定的后台进程:#{process},其ID是#{line_arr[1]}")
        pid_array << line_arr[1].strip
      end
    end
    if pid_array.empty?
      ATT::KeyLog.info("未找到进程#{process}")
      raise ATT::Exceptions::NotFoundError,"进程不存在"
    end
    ATT::KeyLog.info("进程#{process}的ID是#{pid_array.join(',')}")
    return pid_array
  end
  
end
