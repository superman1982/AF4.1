# coding: utf-8
require 'lib/util/autoit'
module LocalPc
  module NetworkAccess
    module AutoItSendPacketHelper
      
      def tcp_send(hash,processid, handle)
        #  hash.update({:size=>"1400",:fastest=>"false",:interval=>"1000",:count=>"5",:hope=>"成功",:close=>"no"})
        flag = "失败"
        ATT::KeyLog.info(hash.to_json)
        arr = hash[:dip].split(".")
        #    p handle
        #    p arr
        AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit4",arr[0])
        AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit3",arr[1])
        AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit2",arr[2])
        AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit1",arr[3])

        AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit5",hash[:port])
        AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit6",hash[:size])
        if hash[:fastest] == "true"
          AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","Button1","Check","")
        else
          AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","Button1","UnCheck","")
          cs = AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox1","FindString",hash[:interval])
          AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox1","SetCurrentSelection",cs)
          cs = AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox2","FindString",hash[:count])
          AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox2","SetCurrentSelection",cs)
          #AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox2","SelectString",arg["次数"])
        end
        if nil != hash[:file]&&"" != hash[:file]
          AF::AutoIt.ControlClick("[HANDLE:#{handle}]","","Button4")
          AF::AutoIt.ControlClick("[HANDLE:#{handle}]","","Button5")
          if AF::AutoIt.WinWait("打开","查找范围(&I):",20)==0
            return["Failed","WinWait:打开,等待超时"]
          end
          filepath = File.join(ATT::ConfigureManager.root,"data", "#{hash[:file]}")
          AF::AutoIt.ControlSend("打开", "查找范围(&I):", "Edit1", filepath.gsub("/","\\").to_utf8)
          AF::AutoIt.ControlClick("打开", "查找范围(&I):", "Button2")
        else
          AF::AutoIt.ControlClick("[HANDLE:#{handle}]","","Button3")
        end
        AF::AutoIt.ControlClick("[HANDLE:#{handle}]","","Button6")

        flag = "超时"

        for i in 1..20#检测是否没有连上或数据文件是否发送完毕
          sleep 5
          tcpclient_win = AF::AutoIt.get_hendles_by_pid_name(processid,"TcpClient")
          if tcpclient_win.length == 1
            if hash[:file].to_s==""
              speedstr = AF::AutoIt.ControlGetText("[HANDLE:#{handle}]","","Static7")
              speed = speedstr.gsub("KB/s","").strip.to_i
              if speed>0
                flag = "成功"
                break
              end
              next
            else
              sleep 1#正在发送数据,等待发送完毕,一共会等(1+5)*20=120秒
            end
          else
            tcpclient_win.each { |hwnd|
              text = AF::AutoIt.ControlGetText("[HANDLE:#{handle}]","","Static2")
              if  !text.include?("间隔")#连接失败或文件发送完毕
                if text.upcase.include?("ERR")||text.upcase.include?("FAIL")
                  ATT::KeyLog.info("连接不上服务端\n")
                  flag = "失败"
                end
                if text.include?("文件发送完毕")
                  ATT::KeyLog.info("文件发送完毕\n")
                  flag = "成功"
                end
                AF::AutoIt.ControlClick("[HANDLE:#{handle}]","","Button1")
              end
            }
            break
          end
        end
        ATT::KeyLog.info("连接超时") if flag=="超时"
        if flag == "失败"|| flag=="超时"||"true" ==  hash[:close].downcase
          handle = AF::AutoIt.get_hendles_by_pid_name(processid,"TcpClient")[0]
          AF::AutoIt.ControlClick("[HANDLE:#{handle}]","","Button8")
        end

        if flag == "成功"
          return_ok
        else
          return_fail
        end
      end

      # => 找到TcpClient的窗口,根据hash里面的一些信息
      def find_tcpclient_window(arg={})
        #找到所有符合该标题的窗口
        hwnds = AF::AutoIt.get_hendles_by_pid_name("",arg[:title])
        winhandle = nil
        hwnds.each{ |handle|
          flag = true
          if nil != arg[:dip]&&"" != arg[:dip]#查看ip是否符合
            arr = []
            arr.push AF::AutoIt.ControlGetText("[HANDLE:#{handle}]","","Edit4")
            arr.push AF::AutoIt.ControlGetText("[HANDLE:#{handle}]","","Edit3")
            arr.push AF::AutoIt.ControlGetText("[HANDLE:#{handle}]","","Edit2")
            arr.push AF::AutoIt.ControlGetText("[HANDLE:#{handle}]","","Edit1")
            ip = arr.join(".")
            puts ip
            if ip != arg[:dip]
              flag = false
            end
          end

          if flag && nil != arg[:port]&&"" != arg[:port]#查看端口是否符合
            tmp = AF::AutoIt.ControlGetText("[HANDLE:#{handle}]","","Edit5")
            puts tmp
            if tmp != arg[:port]
              flag = false
            end
          end

          if flag && nil != arg[:size]&& "" != arg[:size]#查看包大小是否符合
            tmp = AF::AutoIt.ControlGetText("[HANDLE:#{handle}]","","Edit6")
            if tmp != arg[:size]
              flag = false
            end
          end

          if flag         #查看是否最快,间隔,次数是否符合
            if arg[:fastest] == "true"
              if !AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","Button1","IsChecked","")
                flag = false
              end
            else
              if nil != arg[:interval]&&"" != arg[:interval]
                tmp = AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox1","GetCurrentSelection","")
                if tmp != arg[:interval]
                  flag = false
                end
              end

              if nil != arg[:count]&&"" != arg[:count]
                tmp = AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox2","GetCurrentSelection","")
                if tmp != arg[:count]
                  flag = false
                end
              end
            end
            if flag
              winhandle = handle
              break
            end
          end
        }
        return winhandle
      end
      
      def check_tcpclient_speed(hash)
        if hash[:title].to_s==""
          ATT::KeyLog.info("窗口标题不能为空")
          return_fail
        end
        ATT::KeyLog.info("查找条件是:#{hash.to_json}")
        winhandle = find_tcpclient_window(hash)
        if winhandle == nil
          ATT::KeyLog.error("没有找到符合条件的指定的发包工具窗口")
          return_fail
        else
          find=0
          ATT::KeyLog.info("期望最小速度为:#{hash[:min_speed]}KB/s")
          ATT::KeyLog.info("期望最大速度为:#{hash[:max_speed]}KB/s")
          5.times do#检查5次,有3次成功则认为成功
            speedstr = AF::AutoIt.ControlGetText("[HANDLE:#{winhandle}]","","Static7")
            speed = speedstr.gsub!("KB/s","").strip.to_i
            ATT::KeyLog.info("发包速度为:#{speed}KB/s")
            flag=true
            if(hash[:min_speed].to_s!="")
              if speed >= hash[:min_speed].strip.to_i
                flag=true;
              else
                flag=false
              end
            end
            flag2=true
            if(hash[:max_speed].to_s!="")
              if speed <=hash[:max_speed].strip.to_i
                flag2=true;
              else
                flag2=false
              end
            end
            find+=1 if flag&&flag2
            sleep 5
          end
          if find>=3
            ATT::KeyLog.info("发包速度达到了期望速度")
            return_ok
          else
            ATT::KeyLog.info("没有达到指定的速度")
            return_fail
          end
        end
      end

      def close_tcpclient_window(hash)
        if hash[:title]==nil||hash[:title]==""
          ATT::KeyLog.info("窗口标题不能为空")
          return_fail "失败"
        end
        ATT::KeyLog.info("查找条件是:#{hash.to_json}")
        winhandle = find_tcpclient_window(hash)

        if winhandle == nil
          ATT::KeyLog.info("没有找到符合条件的指定的发包工具窗口")
          return_fail "失败"
        else
          AF::AutoIt.ControlClick("[HANDLE:#{winhandle}]","","Button6")
          AF::AutoIt.ControlClick("[HANDLE:#{winhandle}]","","Button8")
          ATT::KeyLog.info("成功关闭指定窗口")
          return_fail "成功"
        end
      end

      # => 根据NewClient的配置进行操作handle对应的窗口
      def newclient_send_udp(hash,handle)
        flag=false
        if handle.to_i > 0
          #      arr = arg["目的ip"].split('.')
          arr = hash[:dip].split(".")
          AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","Button5","Check","")

          AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit4",arr[0])
          AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit3",arr[1])
          AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit2",arr[2])
          AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit1",arr[3])

          AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit5",hash[:port])
          AF::AutoIt.ControlSetText("[HANDLE:#{handle}]","","Edit6",hash[:size])
          if hash[:fastest] == "true"
            AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","Button2","Check","")
          else
            cs = AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox1","FindString",hash[:interval])
            AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox1","SetCurrentSelection",cs)
            cs = AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox2","FindString",hash[:count])
            AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox2","SetCurrentSelection",cs)
            #AF::AutoIt.ControlCommand("[HANDLE:#{handle}]","","ComboBox2","SelectString",arg["次数"])
          end
          AF::AutoIt.ControlClick("[HANDLE:#{handle}]","","Button1")
          flag=true
        end
        if(flag==true)
          ATT::KeyLog.info("发送udp包成功")
          return_ok
        else
          ATT::KeyLog.info("发送udp包失败,工具窗口没有找到")
          return_fail
        end
      end

      def stop_new_client(hash)
        AF::AutoIt.close_window_by_pid_name(nil,"Server")do |handlers|
          handlers.each{|handle|
            port = AF::AutoIt.ControlGetText("[HANDLE:#{handle}]","","TEdit1")
            status = AF::AutoIt.ControlGetText("[HANDLE:#{handle}]","","TButton1")
            if port == hash[:port]
              ATT::KeyLog.info("tcp server在#{hash[:port]}已经开启,现在关闭它")
              AF::AutoIt.WinClose("[HANDLE:#{handle}]","")
              return_ok
              break
            end
          }
          ATT::KeyLog.info("关闭tcpserver失败,没找到对应的窗口")
          return_fail
        end
      end
      
    end
  end
end
