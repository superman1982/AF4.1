module LocalPc
  module SystemManagementHelper

    # 返回指定名称的进程所有进程ID,返回数组
    def find_pid_of_specified_process( process_name )
      tasklist_command = "tasklist | find \"#{process_name}\""
      tasklist_result = ATT::LocalPC.execute_cmd(tasklist_command)
      ATT::KeyLog.debug("执行#{tasklist_command}的结果是:#{tasklist_result.dump}")
      pid_array = []
      tasklist_result.each do |result_line|
        temp_array = result_line.strip.split()
        if temp_array[0] == process_name # 若有多个同名进程时,仅返回第一个进程的ID
          process_id = temp_array[1]
          ATT::KeyLog.error("进程:#{process_name}的ID=#{process_id}...")
          pid_array << process_id
        end
      end
      return pid_array
    end

    #取att绝对路径
    def obtain_att_root()
      (Pathname.new(File.expand_path(ATT::ConfigureManager.root)).realpath).to_s.to_gbk
    end
    
    #获取att的目录下的文件夹目录
    def obtain_att_directory(sub_directory,filename = nil)
      return File.join(obtain_att_root,sub_directory).gsub("/","\\\\").to_gbk if filename.nil?||filename.empty?
      File.join(obtain_att_root,sub_directory,filename).gsub("/","\\\\").to_gbk
    end	
    
    #查找路径下给定的文件名
    def obtain_filepath(dest_dir,filename)
      require 'find'
      raise ArgumentError,"the argument can't be nil." if dest_dir.nil? || filename.nil?  
      gbk_dest_dir = dest_dir.to_gbk
      gbk_filename = filename.to_gbk
      Find.find(gbk_dest_dir) do |filepath|
        filepath_arr = filepath.split("/")
        return (Pathname.new(File.expand_path(filepath)).realpath).to_s.gsub("/","\\\\") if (filepath_arr[-1].downcase == gbk_filename.downcase && !File.directory?(filepath) )
      end
      raise StandardError,"Not find named :#{filename} file in the dir:#{dest_dir}."
    end	    

  end
end
