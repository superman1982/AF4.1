# coding: utf8
module LocalPc
  module NetworkAccess
    module OtherApplicationHelper

      # 获取snmp的oid
      def get_snmp_oid( snmp_entry )
        snmp_oid_hash = { "系统描述" => ".1.3.6.1.2.1.1.1.0", "系统对象ID" => ".1.3.6.1.2.1.1.2.0",\
            "系统开机时间" => ".1.3.6.1.2.1.1.3.0", "系统授权" => ".1.3.6.1.2.1.1.4.0",\
            "系统名称" => ".1.3.6.1.2.1.1.5.0", "系统所处位置" => ".1.3.6.1.2.1.1.6.0",\
            "系统业务内容" => ".1.3.6.1.2.1.1.7.0" }

        return snmp_oid_hash["#{snmp_entry}"] if snmp_oid_hash.has_key?("#{snmp_entry}")
        return_fail("不支持的SNMP信息")
      end

      def input_user_and_passwd( hash )
        browser = Watir::IE.my_new
        browser.goto("http://#{hash[:authweb]}/webAuth")
        browser.maximize
        ATT::KeyLog.info("返回的页面正文部分为:#{browser.html}")
        browser.text_field(:index,1).set(hash[:username]) unless hash[:username].empty?
        if browser.text_field(:id,"password").exist?
          browser.text_field(:id,"password").set(hash[:passwd]) unless hash[:passwd].empty?
        elsif browser.text_field(:id,"passwd").exist?
          browser.text_field(:id,"passwd").set(hash[:passwd]) unless hash[:passwd].empty?
        end
        browser.button(:type, "submit").click
        browser.wait # 等待页面加载完毕
        all_html_text = browser.html
        browser.close if browser
        return all_html_text
      end

      # 使用拨号命令行工具拨号
      def  connect_adsl(connection, user, password)
        command = "rasdial #{connection} #{user} #{password}"
        ATT::KeyLog.info("要执行的命令是#{command}")
        exec_result = `#{command.to_gbk}` # 返回的结果是GBK编码的
        return exec_result.to_s.to_utf8
      end
      # 断开拨号连接
      def disconnect_adsl(connection)
        command = "rasdial #{connection} /disconnect"
        ATT::KeyLog.info("要执行的命令是#{command}")
        exec_result = `#{command.to_gbk}` # 返回的结果是GBK编码的
        return exec_result.to_s.to_utf8
      end

      # 从注册表中获取科来播放器的安装路径
      def get_pktbuilder_path_from_registry()
        Win32::Registry::HKEY_LOCAL_MACHINE.open(PKTBUILDER_REGISTRY_KEY) do |reg|
          pktbuilder_path = reg['Command'].gsub(/\\/, "/")
          ATT::KeyLog.info("科来播放器的安装路径是:#{pktbuilder_path}")
          return pktbuilder_path
        end
        ATT::KeyLog.error("请检查是否已安装了科来生成器")
        return_fail
      end
      
      # 获取要发送的数据包文件的全路径
      def packet_file_with_path( packfile )
        begin
          # 数据包文件名称含中文时,需要转换下编码
          full_path = Pathname.new(File.join(ATT::ConfigureManager.root, PACKET_FILR_DIR, packfile).to_gbk).realpath.to_s.to_utf8
        rescue Errno::ENOENT
          ATT::KeyLog.debug("项目根目录/#{PACKET_FILR_DIR}下不存在数据包文件: #{packfile}")
          ATT::KeyLog.debug("#{$!.class},#{$!.message}")
          return_fail
        end
        ATT::KeyLog.debug("要发送的数据包文件: #{full_path}")
        return full_path
      end

      # 启动科来数据包生成器
      def start_pktbuilder(autoit_ctl, pktbuilder_exe, shell_app)
        if autoit_ctl.WinExists(PKTBUILDER_TITLE)
          ATT::LocalPC.execute_cmd("tskill pktbuilder 2> NULL")
          sleep 5
        end
        shell_app.ShellExecute(pktbuilder_exe, '', '', 'open', 1)
        wait_result = autoit_ctl.WinWait(PKTBUILDER_TITLE, "", 120)
        if wait_result == 0
          ATT::KeyLog.error("打开科来数据包生成器超时")
          return_fail
        end
        if autoit_ctl.WinActivate(PKTBUILDER_TITLE) == 0 # 返回窗口的句柄
          ATT::KeyLog.error("未发现或无法激活科来数据包生成器窗口")
          return_fail
        end
        #autoit_ctl.WinSetState(PKTBUILDER_TITLE, "", @SW_MAXIMIZE) # 科来数据包生成器最大化显示
        ATT::KeyLog.info("成功打开科来数据包生成器....")
      end

      # 删除原来的所有数据包,并打开指定的数据包文件
      def delete_old_and_import_specified_file(autoit_ctl, packet_file_path)
        autoit_ctl.Send("^a") # 选择所有数据包
        sleep 2
        autoit_ctl.Send("{DELETE}") # 删除
        sleep 2
        autoit_ctl.Send("{ENTER}")  # 确定删除
        ATT::KeyLog.info("删除原有的数据包完毕...")
        # 导入指定的数据包文件
        #toolbar_text = autoit_ctl.ControlGetText(PKTBUILDER_TITLE, "", TOOL_BAR)
        #ATT::KeyLog.info("toolbar_text = #{toolbar_text}")
        autoit_ctl.ControlClick(PKTBUILDER_TITLE, "", TOOL_BAR, "left", 1, 25, 25) # 点击工具栏上的'导入'
        sleep 2
        autoit_ctl.ControlSend(OPEN_DIALOG_TITLE, "", "Edit1", packet_file_path.gsub(/\//, "\\")) # 在'打开'对话框内输入要发送的数据包文件路径
        sleep 2
		      autoit_ctl.Send("!o") # autoit_ctl.ControlClick(OPEN_DIALOG_TITLE, "", OPEN_FILE_BUTTON) # 点击打开按钮
        sleep 5 # 等待数据包文件打开
      end
      
      # 选择默认网卡
      def select_net_adapter(autoit_ctl,  nic)
        #autoit_ctl.ControlClick(PKTBUILDER_TITLE, "", TOOL_BAR, "left", 1, 545, 25) # 点击工具栏上的'网卡'
        autoit_ctl.ControlClick(PKTBUILDER_TITLE, "", MENU_BAR, "left", 1, 100, 10) # 点击菜单栏上的'发送'
        autoit_ctl.Send("+d") # 选择缺省网卡
        sleep 2
        adapter_index = nic.to_i - 1
        ATT::KeyLog.debug("选择索引是: #{adapter_index}的网卡...")
        autoit_ctl.ControlCommand(SELECT_ADAPTER_DIALOG_TITLE, "", NIC_COMBOX_CONTROL, "SetCurrentSelection", adapter_index)
        sleep 2
        autoit_ctl.ControlFocus(SELECT_ADAPTER_DIALOG_TITLE, "", CONFIRM_BUTTON) # 点击'确定'按钮
        autoit_ctl.ControlClick(SELECT_ADAPTER_DIALOG_TITLE, "", CONFIRM_BUTTON) # 点击'确定'按钮
      end

      # 设置突发模式
      def set_emergent_mode(autoit_ctl, emergent)
        sleep 2
        if emergent == "是"
          autoit_ctl.ControlCommand(SEND_ALL_PACKAGES_TITLE, "", EMERGENT_BUTTON, "Check", "")
        else
          autoit_ctl.ControlCommand(SEND_ALL_PACKAGES_TITLE, "", EMERGENT_BUTTON, "UnCheck", "")
        end
      end
      # 设置循环发送选项
      def set_loop_send_options(autoit_ctl, loop, looptimes, loopinterval)
        if loop == "是"
          autoit_ctl.ControlCommand(SEND_ALL_PACKAGES_TITLE, "", LOOP_SEND_BUTTON, "Check", "")
          autoit_ctl.ControlSetText(SEND_ALL_PACKAGES_TITLE, "", LOOP_TIMES_EDIT, looptimes)
          autoit_ctl.ControlSetText(SEND_ALL_PACKAGES_TITLE, "", LOOP_INTERVAL_EDIT, loopinterval)
        else
          autoit_ctl.ControlCommand(SEND_ALL_PACKAGES_TITLE, "", LOOP_SEND_BUTTON, "UnCheck", "")
        end
        sleep 2
      end

      # 在'发送全部数据包'窗口上获取要发送的数据包个数
      def total_count_to_be_sent(autoit_ctl) 
        total_count_text = autoit_ctl.ControlGetText(SEND_ALL_PACKAGES_TITLE, "", TOTAL_PACKAGES_COUNT) # 总数据包
        ATT::KeyLog.info("总数据包数: #{total_count_text}")
        if total_count_text.to_s.empty?
          ATT::KeyLog.info("未显示总数据包数,请检查数据包文件是否被打开了...")
          return_fail
        end
        if total_count_text.include?("=") # 勾选了循环发送
          total_count = total_count_text.split(" = ")[1]
        else
          total_count = total_count_text
        end
        ATT::KeyLog.info("total_count = #{total_count}")
        return total_count
      end
    
      # 检查是否已经有WinDump.exe进程存在,若有则全部杀掉
      def kill_windump_processes_existed()
        pid_array = find_pid_of_specified_process(WINDUMP_PROCESS)
        pid_array.each do |pid|
          tskill_command = "tskill #{pid}"
          ATT::LocalPC.execute_cmd(tskill_command)
        end
        ATT::KeyLog.error("进程:#{WINDUMP_PROCESS}不存在...")
      end	
    
      def wait_send_packet(timeout)
        i = 1
        while true 
          nc_arr = find_pid_of_specified_process("nc.exe")
          i +=1
          break if i>timeout || nc_arr.empty?
          sleep 1
        end
      end
      
      
      
      
    end
  end
end
