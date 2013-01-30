# coding: utf8
module LocalPc
  module FileOperationHelper

    # 参考信息配置
    def get_all_refers_info_text( refers )
      refer_count = 1
      all_refer_text = ""
      refers.split("&").each do |refer|
        all_refer_text += "ref#{refer_count} = #{refer}#{OneEnterLine}"
        refer_count += 1
      end
      all_refer_text = "reference_num = #{refer_count-1}#{OneEnterLine}" + all_refer_text
      return all_refer_text
    end

    # 解决方案配置
    def get_all_solutions_info_text( solutions )
      solution_count = 1
      all_solution_text = ""
      solutions.split("&").each do |solution|
        update_name, update_address = solution.split("#")
        all_solution_text += "sname#{solution_count} = #{update_name}#{OneEnterLine}solution#{solution_count} = #{update_address}#{OneEnterLine}"
        solution_count += 1
      end
      all_solution_text = "solution_num = #{solution_count-1}#{OneEnterLine}" + all_solution_text
      return all_solution_text
    end

    # 内置漏洞的动作转换成数字
    def action_text_to_num( hole_action )
      operation_map = {"检测后拦截" => 1, "检测后放行" => 2, "与云分析引擎联动" => 3, "禁用" => 4 }
      if operation_map.has_key?("#{hole_action}")
        return operation_map["#{hole_action}"]
      else
        ATT::KeyLog.error("未知的漏洞动作:#{hole_action}")
        return_fail
      end
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
