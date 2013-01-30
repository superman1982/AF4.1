# coding: utf8
=begin rdoc
作用: 封装执行主机上文件相关的操作
维护记录:
维护人      时间                  行为
gsj     2012-05-25              创建
=end
require "fileutils"
module LocalPc


=begin rdoc
类名: 文件操作
描述: 文件操作
=end
  class FileOperation < ATT::Base

=begin rdoc
关键字名: 新增内置漏洞配置文件
描述: 在本地创建内置漏洞配置文件,返回创建的配置文件的全路径(含文件名)
维护人: gsj
参数:
id=>hole_id,name=>漏洞ID,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"新增漏洞的ID,配置文件以此ID命名"
id=>hole_name,name=>漏洞名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"新增漏洞的名称,不能为空"
id=>hole_desc,name=>漏洞描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"新增漏洞的描述,可为空"
id=>impact,name=>攻击影响,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"新增漏洞的攻击影响,可为空"
id=>level,name=>危险等级,type=>s,must=>false,default=>"高",value=>"高|中|低",descrip=>"新增漏洞的危险等级"
id=>refers,name=>参考信息,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"参考信息,多个时使用'&'分隔"
id=>solutions,name=>解决方案,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"解决方案,每个解决方案的格式'更新的名称#更新的地址',如'Microsoft Security Update#http://www.microsoft.com/technet/security/bulletin/ms11-021.mspx',多个时使用'&'分隔"
id=>action,name=>动作,type=>s,must=>false,default=>"检测后拦截",value=>"检测后拦截|检测后放行|与云分析引擎联动|禁用",descrip=>"动作"
id=>type,name=>漏洞类型,type=>s,must=>false,default=>"worm",value=>"worm|network_device|database|file|backdoor|trojan|spyware|web|application|web_browse|media|dns|ftp|mail|tftp|system|telnet|shellcode|web_activex",descrip=>"漏洞类型"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>"期望结果"
=end
    def add_built_in_hole_cfgfile(hash)
      local_dir = Pathname.new(File.join(ATT::ConfigureManager.root, "temp")).realpath.to_s # 创建的文件存放在temp目录下
      hole_id = hash[:hole_id].to_i
      local_file = File.join(local_dir, "#{hole_id}.desc")
      
      File.open(local_file, "w") do |fp|
        fp.print("[RULES]#{TwoEnterLine}")
        fp.print("sid = #{hole_id}#{TwoEnterLine}")
        fp.print("name = #{hash[:hole_name]}#{TwoEnterLine}")
        fp.print("desc = #{hash[:hole_desc]}#{TwoEnterLine}")
        fp.print("impact = #{hash[:impact]}#{TwoEnterLine}")
        fp.print("danger_class = #{hash[:level].to_level_num}#{TwoEnterLine}")

        all_refer_text = get_all_refers_info_text( hash[:refers]) # 参考信息配置
        fp.print("#{all_refer_text}#{TwoEnterLine}")

        all_solution_text = get_all_solutions_info_text( hash[:solutions] ) # 解决方案配置
        fp.print("#{all_solution_text}#{TwoEnterLine}")
        
        fp.print("type = #{hash[:type].to_hole_type_id}#{TwoEnterLine}")
        fp.print("action = #{action_text_to_num(hash[:action])}#{TwoEnterLine}")
      end
      ATT::KeyLog.info("已创建漏洞配置文件,保存在:#{local_file}")
      return [ local_file.gsub(/:/, "\:") ]
    end

=begin rdoc
关键字名: 新增漏洞特征识别库规则
描述: 每次都在设备最初的hole_library.ini(已从设备下载到本地了)的基础上,增加一个Hole_Rule条目并使Hole_Cfg_Cnt加1
维护人: gsj
参数:
id=>hole_id,name=>漏洞ID,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"漏洞的ID,配置文件以此ID命名"
id=>hole_name,name=>漏洞名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"漏洞的名称,不能为空"
id=>type,name=>漏洞类型,type=>s,must=>false,default=>"worm",value=>"worm|network_device|database|file|backdoor|trojan|spyware|web|application|web_browse|media|dns|ftp|mail|tftp|system|telnet|shellcode|web_activex",descrip=>"漏洞类型"
id=>level,name=>危险等级,type=>s,must=>false,default=>"高",value=>"高|中|低",descrip=>"新增漏洞的危险等级"
id=>action,name=>动作,type=>s,must=>false,default=>"检测后拦截",value=>"检测后拦截|检测后放行|与云分析引擎联动|禁用",descrip=>"动作"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>"期望结果"
=end
    def add_hole_recognition_rule( hash )
      # 已从设备上下载下来,保存在本地的原始漏洞特征识别库
      original_hole_library_ini = Pathname.new(File.join(ATT::ConfigureManager.root, "bin", "hole_library.ini")).realpath.to_s
      local_dir = Pathname.new(File.join(ATT::ConfigureManager.root, "temp")).realpath.to_s # 创建的新文件存放在temp目录下
      local_file = File.join(local_dir, "hole_library.ini") # 创建的新文件存放在temp目录下,名称不变
      orig_fp = File.open(original_hole_library_ini, "r")
      new_fp = File.open(local_file, "w")

      show_flag = false # 下一行将显示漏洞总个数
      orig_fp.each_line do | line |
        if line =~ /\[Hole_Cfg\]/
          show_flag = true
        else
          if show_flag # 写入新增的条目,并将漏洞总个数加1
            if line =~ /Hole_Cfg_Cnt = (.*)/ # Hole_Cfg_Cnt = 2189
              original_count = $1.to_i # 原有漏洞的个数
              ATT::KeyLog.info("原有的漏洞个数:#{original_count}")
            else
              ATT::KeyLog.error("#{original_hole_library_ini}内的格式错误...")
              return_fail
            end
            hole_id = hash[:hole_id].to_i
            new_fp.print("[Hole_Rule_#{original_count}]#{OneEnterLine}")
            new_fp.print("sid = #{hole_id}#{OneEnterLine}")
            new_fp.print("name = #{hash[:hole_name]}#{OneEnterLine}")
            new_fp.print("type = #{hash[:type].to_hole_type_id}#{OneEnterLine}")
            new_fp.print("danger_class = #{hash[:level].to_level_num}#{OneEnterLine}")
            action = action_text_to_num(hash[:action])
            new_fp.print("action = #{action}#{OneEnterLine}")
            new_fp.print("old_action = #{action}#{TwoEnterLine}")

            new_fp.print("[Hole_Cfg]#{OneEnterLine}")
            new_fp.print("Hole_Cfg_Cnt = #{original_count + 1}#{TwoEnterLine}")
            break # 增加完新条目后,直接退出
          else
            new_fp.print(line) # 原来的内容直接写入
          end
        end
      end
      orig_fp.close # 关闭文件
      new_fp.close  # 关闭文件
      
      ATT::KeyLog.info("已在原始的漏洞特征识别库配置文件内新增了一个条目,保存在:#{local_file}")
      return [ local_file.gsub(/:/, "\:") ]
    end

=begin rdoc
关键字名: 增加web漏洞自定义规则
描述: 增加web漏洞自定义规则,需要将最新的web.rule规则下载下来并解密保存到ATT的Bin下使用
维护人: lxy
参数:
id=>flag,name=>是否原始文件添加,type=>s,must=>false,default=>"否",value=>"否|是",descrip=>"为是时会从提供的最原始的文件增加，否则的话会使用已添加过的文件中继续添加"
id=>protocol,name=>协议,type=>s,must=>false,default=>"tcp",value=>"tcp|udp|icmp",descrip=>"协议内容，默认为tcp"
id=>sourceip,name=>源IP,type=>s,must=>false,default=>"any",value=>"{text}",descrip=>"源IP地址，若所有地址则为any"
id=>sourceport,name=>源端口,type=>s,must=>false,default=>"any",value=>"{text}",descrip=>"源端口，若所有端口则为any"
id=>direction,name=>方向,type=>s,must=>false,default=>"<>",value=>"<>|->|<-",descrip=>"数据流的方向"
id=>destionationip,name=>目标IP,type=>s,must=>false,default=>"any",value=>"{text}",descrip=>"目标IP地址，若所有地址则为any，"
id=>destionationport,name=>目标端口,type=>s,must=>false,default=>"any",value=>"{text}",descrip=>"目标端口，若所有端口则为any"
id=>msg,name=>消息msg,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"规则中msg字段值"
#id=>content,name=>内容content,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"规则中content字段值"
id=>sid,name=>标识sid,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"规则中sid字段值"
id=>classtype,name=>类型classtype,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"规则中classtype字段值"
id=>holetypeid,name=>漏洞类型编号,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"规则中holetype-id字段值"
id=>ruletype,name=>规则类型,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"规则中ruletype字段值"
id=>other,name=>其它附加字段,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"规则中其它字段值，请与完整格式填写，如byte_jump:1,2,string,oct; 最后的分号也需要提供"
id=>number,name=>增加条数,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"增加多少条此规则,SID会给定的规则上增加，在此值不为1时，若其它参数中有XYXYXY的话则会被替换成SID的数值."
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>"期望结果"
=end
    def add_web_hole_custom_rule( hash )
      original_file = obtain_filepath(obtain_att_directory("bin"),"web.rules")
      noencrypt_directory = obtain_att_directory("temp/noencrypt")
      Dir.mkdir(noencrypt_directory) if ! File.exists?(noencrypt_directory)
      webrule_file = File.join(noencrypt_directory,"web.rules").gsub("/","\\\\")
      if hash[:flag] == "否"
        File.copy(original_file,noencrypt_directory) if ! File.exists?(webrule_file)
        log "don't rebuild the file, append the rule to the file name is #{webrule_file}."    
      elsif hash[:flag] == "是"
        File.delete(webrule_file) if File.exists?(webrule_file)
        File.copy(original_file,noencrypt_directory)
        log "rebuid the file name is #{webrule_file} for adding the rule." 
      else
        log "The argument error of the flag. Details:#{hash[:flag]}."
        return_fail
      end
      whole_rule = ""
      rule_head = "alert #{hash[:protocol]} #{hash[:sourceip]} #{hash[:sourceport]} #{hash[:direction]} #{hash[:destionationip]} #{hash[:destionationport]} "
      for i in (1..hash[:number].to_i)
        msg_content = ""
        sid = hash[:sid].to_i+i-1
        if hash[:other].nil? || hash[:other].empty?
          msg_content = "(msg:\"#{hash[:msg]}\";classtype:#{hash[:classtype]};sid:#{sid};holetype-id:#{hash[:holetypeid]};ruletype:#{hash[:ruletype]};)"
        else
          other_content = ""
          if hash[:other][-1..-1] == ";"
            other_content = hash[:other]
          else
            other_content = hash[:other]+";"
          end
          msg_content = "(msg:\"#{hash[:msg]}\";classtype:#{hash[:classtype]};sid:#{sid};#{other_content}holetype-id:#{hash[:holetypeid]};ruletype:#{hash[:ruletype]};)\n"
        end      
        whole_rule += rule_head + msg_content+"\n"
        whole_rule.gsub!("XYXYXY","#{sid}") if i != 1
      end
      whole_rule.gsub!("\r","")
      log "the add rule is #{whole_rule}."
      file_handle = File.open(webrule_file,"a")
      file_handle.write(whole_rule)
      file_handle.close      
    end
    
=begin rdoc
关键字名: 使用ruledestool加解密文件夹并返回路径
描述: 对给定的两个文件夹进行加解密操作
维护人: lxy
参数:
id=>sourcefile,name=>源文件夹,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"默认给定的路径为ATT工程temp目录下noenctrypt"
id=>destionationfile,name=>目标文件夹,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"默认给定的路径为ATT工程temp目录下enctrypt"
id=>action,name=>加解密,type=>s,must=>false,default=>"加密",value=>"加密|解密",descrip=>"加密时为加密"
id=>returnfilename,name=>文件名,type=>s,must=>false,default=>"web.rules",value=>"{text}",descrip=>"返回文件所在的路径，若此文件名为空，则返回处理后的文件夹目录"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>"期望结果"
=end
    def enctrypt_and_dectrypt( hash )    
      tool_path = obtain_filepath(obtain_att_directory("bin"),"rule_des_tool.exe")
      source_file = hash[:sourcefile]
      destionation_file = hash[:destionationfile]
      action = ""  
      source_file = obtain_att_directory("temp/noencrypt") if hash[:sourcefile].nil? || hash[:sourcefile].empty?
      destionation_file = obtain_att_directory("temp/encrypt") if hash[:destionationfile].nil? || hash[:destionationfile].empty?
      if hash[:action] == "加密"
        action = "des"
      elsif hash[:action] == "解密"
        action = "sed"
      else
        return_fail("Unknown action method of rule-des-tool")
      end
      return_fail if ! File.exists?(source_file)
      Dir.mkdir(destionation_file) if ! File.exists?(destionation_file)
      command = "#{tool_path} #{source_file} #{destionation_file} #{action}"
      log "The command is #{command}."
      #system(command)
      ATT::LocalPC.execute_cmd(command)
      if hash[:returnfilename].empty?
        return destionation_file
      else
        return obtain_filepath(destionation_file,hash[:returnfilename])
      end 
    end

=begin rdoc
关键字名: 检查PC文件内容
描述: 检查普通文件中是否包含指定的文本内容
参数:
id=>file,name=>文件,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"检查哪个文件,必须带全路径,如'E:/tcpdump.txt'"
id=>checkpoint,name=>检查点,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"检查指定的文件内是否包含该检查点,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|检查点不存在|文件不存在",descrip=>""
=end
    def check_common_file_content(hash)
      unless File.exists?(hash[:file])
        ATT::KeyLog.error("文件:#{hash[:file]}不存在,请检查...")
        return_fail
      end
      file_content = IO.read(hash[:file])
      ATT::KeyLog.info("文件#{hash[:file]}的内容是:\n#{file_content.dump}")
      unless hash[:checkpoint].empty?
        check_point_array = hash[:checkpoint].to_s.split("&")
        check_point_array.each do |point|
          if file_content.include?(point)
            ATT::KeyLog.info("文件#{hash[:file]}包含检查点:#{point}")
          else
            ATT::KeyLog.info("文件#{hash[:file]}的内容是:\n#{file_content}")
            ATT::KeyLog.info("不包含检查点:#{point}")
            return_fail("检查点不存在")
          end
        end
      end
      return_ok
    end
    
=begin rdoc
关键字名: 新建文件
描述: 新建一个指定内容的文件
参数:
id=>file,name=>文件,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"在哪来新建什么文件,必须带全路径,如'E:/tcpdump.txt'"
id=>file_content,name=>文件内容,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"新建文件的内容,如'ABCddd'"
id=>is_recover,name=>是否覆盖,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"新建时是否覆盖文件"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"新建文件是否成功"
=end
    def creat_file(hash)
      FileUtils.mkdir_p(File.dirname(hash[:file])) rescue Exception { 
        ATT::KeyLog.info("这里新建目录出了错误的 #{File.dirname(hash[:file])} ") } # =>   有事没事先新建目录
      if File.exists?(hash[:file]) and hash[:is_recover] == "否"
        ATT::KeyLog.error("文件存在,并且不选择覆盖,新建文件失败 -> 文件是: #{hash[:file]}")
        return_fail
      elsif File.exists?(hash[:file]) and hash[:is_recover] == "是"
        File.delete(hash[:file])
      end
      created_file = File.new(hash[:file],"w+")
      created_file.print("#{hash[:file_content]}")
      created_file.close
      file_content = IO.read(hash[:file])
      ATT::KeyLog.info("文件#{hash[:file]}的内容是:\n#{file_content}")
      return_ok
    end
    
=begin rdoc
关键字名: 复制文件到指定路径
描述: 新建一个指定内容的文件
参数:
id=>src_file,name=>源文件路径,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源文件路径,必须带全路径,如'E:/tcpdump.txt'"
id=>dst_file,name=>目的文件路径,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"目的文件路径,必须带全路径,如'F:/tcpdump.txt'"
id=>is_recover,name=>是否覆盖,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"复制时是否覆盖文件"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"新建文件是否成功"
=end
    def copy_file(hash)
      if hash[:dst_file][-1,1] == "/" or hash[:dst_file][-1,1] == "\\"
        ATT::KeyLog.info("目的文件是个目录诶~~============= ")
        FileUtils.mkdir_p(hash[:dst_file]) rescue Exception { 
          ATT::KeyLog.info("这里新建目录出了错误的 #{File.dirname(hash[:dst_file])} ") } # =>   有事没事先新建目录
        hash[:dst_file] = hash[:dst_file] + File.basename(hash[:src_file])
      else
        FileUtils.mkdir_p(File.dirname(hash[:dst_file])) rescue Exception { 
          ATT::KeyLog.info("这里新建目录出了错误的 #{File.dirname(hash[:dst_file])} ") } # =>   有事没事先新建目录
      end
      if File.exists?(hash[:dst_file]) and hash[:is_recover] == "否"
        ATT::KeyLog.error("文件存在,并且不选择覆盖,新建文件失败 -> 源文件是: #{hash[:src_file]} 目的文件是: #{hash[:dst_file]}")
        return_fail
      elsif File.exists?(hash[:dst_file]) and hash[:is_recover] == "是"
        File.delete(hash[:dst_file])
      end
      FileUtils.cp_r(hash[:src_file],hash[:dst_file])
      file_content = IO.read(hash[:src_file])
      ATT::KeyLog.info("源文件#{hash[:src_file]}的内容是:\n#{file_content}")
      return_ok
    end

  end
end
