module AF
  module Servers
    class Mail_Server
      # => 在新线程运行smtp的服务器
      def start_smtp_server()
        Thread.new {
          init_thread_data_hash({:type => "smtp_server_listen"})
          begin
            while (session = @smtp_server_socket.accept)
              Thread.new(session) do |accept_session|
                init_thread_data_hash({:type => "smtp_server_session", :start_time => Time.now, :socket => accept_session, :smtp_rcpt_addrs => []})
                accept_session.write("220 " + @welcome_word + "\r\n")
                smtp_request()
                destory_thread_data_hash()
              end
            end
          rescue
            ATT::KeyLog.error("Smtp客户连接线程出错了,跑出了以下异常")
            ATT::KeyLog.error($!.to_s)
            return_error
          ensure
            @server_socket.close
          end
          return_ok
        }
      end

      # => 每个回话连接处理函数
      def smtp_request()
        is_login = false
        is_done = false
        loop do
          return true if is_done
          request_str = get_request
          next if request_str == nil
          request_str.chomp!()
          ATT::KeyLog.debug("获得的 request 是:::#{request_str}")
          if request_str == nil
            sleep 1 # => 稍微睡一下,避免过度占用CPU
            next
          end
          case(request_str)
          when /^EHLO/i
            ATT::KeyLog.debug("进入 EHLO request 是:::#{request_str}")
            do_smtp_EHLO(request_str)
          when /^AUTH/i
            ATT::KeyLog.debug("进入 AUTH request 是:::#{request_str}")
            do_smtp_AUTH(request_str)
          when /^HELO/i
            ATT::KeyLog.debug("进入 HELO request 是:::#{request_str}")
            do_smtp_HELO(request_str)
          when /^MAIL/i
            ATT::KeyLog.debug("进入 MAIL request 是:::#{request_str}")
            do_smtp_MAIL(request_str)
          when /^RCPT/i
            ATT::KeyLog.debug("进入 RCPT request 是:::#{request_str}")
            do_smtp_RCPT(request_str)
          when /^DATA/i
            ATT::KeyLog.debug("进入 DATA request 是:::#{request_str}")
            do_smtp_DATA(request_str)
          when /^RSET/i
            ATT::KeyLog.debug("进入 RSET request 是:::#{request_str}")
            do_smtp_RSET()
          when /^SEND/i
            ATT::KeyLog.debug("进入 SEND request 是:::#{request_str}")
            do_smtp_SEND(request_str)
          when /^SOML/i
            ATT::KeyLog.debug("进入 SOML request 是:::#{request_str}")
            do_smtp_SOML(request_str)
          when /^SAML/i
            ATT::KeyLog.debug("进入 SAML request 是:::#{request_str}")
            do_smtp_SAML(request_str)
          when /^VRFY/i
            ATT::KeyLog.debug("进入 VRFY request 是:::#{request_str}")
            do_smtp_VRFY(request_str)
          when /^HELP/i
            ATT::KeyLog.debug("进入 HELP request 是:::#{request_str}")
            do_smtp_HELP(request_str)
          when /^NOOP/i
            ATT::KeyLog.debug("进入 NOOP request 是:::#{request_str}")
            do_smtp_NOOP(request_str)
          when /^TURN/i
            ATT::KeyLog.debug("进入 TURN request 是:::#{request_str}")
            do_smtp_TURN(request_str)
          when /^STARTTLS/i
            ATT::KeyLog.debug("进入 QUIT request 是:::#{request_str}")
            is_done = do_smtp_STARTTLS()
          when /^QUIT/i
            ATT::KeyLog.debug("进入 QUIT request 是:::#{request_str}")
            is_done = do_smtp_QUIT()
          else
            ATT::KeyLog.debug("进入 do_smtp_unknow_request request 是:::#{request_str}")
            do_smtp_unknow_request()
          end
        end
      rescue
        ATT::KeyLog.error("Error we get on : \n #{$!.to_s} \n #{$!.backtrace.join("\n     ")}") rescue nil
      ensure
        @thread_data_hash[Thread.current][:socket].close rescue nil
      end

      def do_smtp_EHLO(request_str)
        reply("250-Sangfor_Test_Mail_Server")
        reply("250-SIZE")
        reply("250 HELP")
        return true
      end

      def do_smtp_HELO(request_str)
        reply("250 Sangfor_Test_Mail_Server")
        return true
      end

      def do_smtp_AUTH(request_str)
        auth_param = (request_str.split(/\s+/)+['', '', ''])[1]
        reply("502 only can AUTH LOGIN") if auth_param == nil
        if auth_param.downcase == "login"
          reply("334 dxNlcm5hbWU6") #334 Username:
          user = get_request()
          if user_in_userlist(user)
            reply("334 UGFzc3dvcmQ6") #334 Passowrd:
            passwd = get_request()
            if user_passwd_ok(user,passwd)
              reply("235 auth successfully")
            else
              reply("554 auth fail")
            end
          else
            reply("554 auth user didn't exsist")
          end
        else
          reply("554 auth only support login")
        end
        #reply("250 Sangfor_Test_Mail_Server")
      end

      def user_in_userlist(user)
        # => 暂时任意人登录都当作成功
        return true
      end

      def user_passwd_ok(user,passwd)
        # => 暂时任意人登录都当作成功
        return true
      end

      def do_smtp_MAIL(request_str)
        #param = (request_str.split(/\s+/)+['', '', ''])[1]
        #ATT::KeyLog.debug("拆分出来的 do_smtp_MAIL 参数是:#{param}")
        request_str =~ /\<(.*)\>/
        ATT::KeyLog.debug("匹配到的Mail from字符串是:#{Regexp.last_match[1]}")
        if (@thread_data_hash[Thread.current][:smtp_from_addr] = Regexp.last_match[1]) != nil
          reply("250 OK From:<#{@thread_data_hash[Thread.current][:smtp_from_addr]}>")
          return true
        else
          ATT::KeyLog.debug("匹配到nil的Mail From")
          reply("225 Error From:<#{@thread_data_hash[Thread.current][:smtp_from_addr]}>")
          return false
        end
      end

      def do_smtp_RCPT(request_str)
        #param = (request_str.split(/\s+/)+['', '', ''])[1]
        #ATT::KeyLog.debug("拆分出来的 do_smtp_RCPT 参数是:#{param}")
        request_str =~ /\<(.*)\>/
        ATT::KeyLog.debug("匹配到的 RCPT TO 字符串是:#{Regexp.last_match[1]}")
        @thread_data_hash[Thread.current][:smtp_rcpt_addrs] << Regexp.last_match[1] if Regexp.last_match[1] != nil
        if Regexp.last_match[1] != nil
          reply("250 OK To :<#{Regexp.last_match[1]}>")
          return true
        else
          ATT::KeyLog.debug("匹配到nil的Mail To")
          reply("225 Error To :<#{Regexp.last_match[1]}>")
          return false
        end

      end

      def do_smtp_DATA(request_str)
        if @thread_data_hash[Thread.current][:smtp_rcpt_addrs].size == 0
          reply("550 No one RCPT addr")
        else
          reply("354 Start mail input; end with <CRLF>.<CRLF>")
          mail_str = ''
          loop do
            data_request = get_request
            break if data_request == nil
            ATT::KeyLog.debug(data_request)
            if (data_request.chomp() == "")
              request_end_str = get_request
              if request_end_str.chomp() == '.'
                break
              else
                mail_str << data_request.chomp()
              end
            elsif (data_request.chomp() == ".")
              break
            elsif (/^QUIT/i =~ data_request.chomp() )
              do_smtp_QUIT()
            end
            mail_str << data_request
          end
          ATT::KeyLog.debug("收到的邮件全文是::")
          ATT::KeyLog.debug("\n" + mail_str)
          if mail_str
            reply("250 OK")
            @thread_data_hash[Thread.current][:mail_str] = mail_str
            return true
          else
            reply("550 end with no data")
          end
        end
      end

      def do_smtp_QUIT()
        reply("250 OK")
        
        if @thread_data_hash[Thread.current][:smtp_rcpt_addrs].size == 0
          reply("221 Server is closing transmission socket")
          @thread_data_hash[Thread.current][:socket].close rescue nil
          @thread_data_hash[Thread.current].clear
        else
          ATT::KeyLog.debug("测试服务器,收到邮件没必要保存,以下是需要发送的邮箱:")
          @thread_data_hash[Thread.current][:smtp_rcpt_addrs].each { |item|
            ATT::KeyLog.debug(item)
          }
          reply("221 Server is closing transmission socket") rescue nil
          @thread_data_hash[Thread.current][:socket].close rescue nil
          @thread_data_hash[Thread.current].clear
        end
        ensure
          Thread.current.kill
      end

      def do_smtp_RSET()
        # => 没打算真的收邮件，所以reset就肯定OK了
        reply("250 ok")
        return true
      end

      def do_smtp_unknow_request()
        reply("502 not such command")
        return true
      end

      def do_smtp_SEND(request_str)
        reply("225 not such command")
        return true
      end

      def do_smtp_SOML(request_str)
        reply("225 not such command")
        # => To do
        return true
      end

      def do_smtp_SAML(request_str)
        reply("225 not such command")
        # => To do
        return true
      end

      def do_smtp_VRFY(request_str)
        reply("250 Sangfor Test Server There is no any user here #{@welcome_word}")
        # => To do
        return true
      end

      def do_smtp_HELP(request_str)
        reply("250 You don't need to help when you use this server")
        # => To do
        return true
      end

      def do_smtp_NOOP(request_str)
        reply("250 ok")
        return true
      end
      
      def do_smtp_TURN(request_str)
        reply("225 not such command")
        # => To do
        return true
      end

      def do_smtp_STARTTLS()
        reply("225 not such command")
        return true
      end
    end
  end
end