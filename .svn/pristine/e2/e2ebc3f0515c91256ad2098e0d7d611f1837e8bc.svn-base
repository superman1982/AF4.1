# coding: utf8
module AF
  module Servers
    class FTP_Server
      @@instance_server_hash = {}
      def unescape(string)
        ; string.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2}))/n) { [$1.delete('%')].pack('H*') }
      end

      attr_accessor :connect_thread, :server_thread, :observe_thread, :session_hash
      # => 设定所有需要的变量
      def initialize(hash={"port" => 21, "server_runtime" => true, "timeout" => 120, "cadence" => 10,
            "root_dir" => "./", "hello_word" => "Sangfor Ruby Test FTP Server", "users" => "user", "passwds" => "passwd" })
        @last_mtime = File.mtime(__FILE__)
        @port = hash["port"]
        @timeout = hash["timeout"]
        @cadence = hash["cadence"]
        @root_dir = hash["root_dir"]
        @connect_thread = {} # => 子连接的线程hash表
        @hello_word = "220 " + hash["hello_word"]
        @server_thread = nil
        @observe_thread = nil
        @server_runtime = hash["server_runtime"]
        @data_socket_hash = {}
        @type_hash = {}
        @current_dir_hash = {}
        @session_hash = {}
        @server_user_and_pass_hash = {}
        user_array = hash["users"].split("&") # => 支持多个用户
        passwd_array = hash["passwds"].split("&") # => 密码对应,如果密码比用户少的话,就用最后的密码扩展,就是说可以设定多个用户一个密码
        user_array.each_with_index { |user,index|
          @server_user_and_pass_hash[user.to_s] = index < passwd_array.size ? passwd_array[index] : passwd_array[-1]
        }
        ATT::KeyLog.info("server http #{@port} ...")
        @server_socket = TCPServer.new('0.0.0.0', @port)
        ATT::KeyLog.info("server ftp #{@port} ready!")
        @@instance_server_hash[Thread.current] = self
        #IPSocket.getaddress
      end

      # => 运行http服务,根据设定的主线程运行时间决定服务器运行时间
      def running_service()
        @server_thread = Thread.new {
          begin
            while (session = @server_socket.accept)
              Thread.new(session) do |accept_session|
                @connect_thread[Thread.current]=Time.now
                accept_session.puts(@hello_word)
                request(accept_session)
                @connect_thread.delete(Thread.current)
              end
            end
          rescue
            ATT::KeyLog.error($!.to_s)
            return_error
          ensure
            @server_socket.close
          end
          return_ok
        }
        # => 观察时间超过120的连接,就直接KILL掉,达成超时120,检测节奏为每 cadence 检测一次
        observe(@cadence, @timeout)
        Dir.chdir(@root_dir)
        # => 根据设定的时间退出主线程
        Thread.new { loop do
            sleep @cadence
            if @server_runtime == true
              next
            end
            if @server_runtime == 0
              @server_socket.close
              @connect_thread.keys.each { |item| item.kill } rescue nil
              Thread.kill(@socket_thread) rescue nil
              Thread.kill(@observe_thread) rescue nil
              Trhead.current.kill rescue nil
            end
            @server_runtime -= 1
          end }
      end


      # => 观察时间超过 delta 的连接,就直接KILL掉,达成超时 delta ,检测节奏为每 cadence_time 检测一次
      def observe(cadence_time, delta)
        @observe_thread = Thread.new do
          loop do
            sleep(cadence_time)
            nowDelta=Time.now-delta
            l=@connect_thread.select { |th, time| (time<nowDelta) }
            l.each { |thread, tm|
              if @is_transport_hash[thread] != true
                ATT::KeyLog.info("killing thread")
                @session_hash[thread].close rescue nil
                @data_socket_hash[thread].close rescue nil
                thread.kill rescue nil
                @connect_thread.delete(th)
              end
            }
          end;
        end
      end

      # => 每个回话连接处理函数
      def request(session)
        ATT::KeyLog.debug("进入 总体!!! request ")
        is_login = false
        is_done = false
        @session_hash[Thread.current] = session
        @current_dir_hash[Thread.current] = "."
        @data_socket_hash[Thread.current] = nil
        @type_hash[Thread.current] = "A"
        loop do
          if not is_login
            ATT::KeyLog.debug("还没登陆,需要登陆!!!")
            is_login = do_login()
          end
          return if is_done
          request_str = session.gets
          ATT::KeyLog.debug("获得的 request 是:::#{request_str}")
          if request_str == nil
            sleep 1 # => 稍微睡一下,避免过度占用CPU
            next
          end
          case(request_str)
          when /^PWD/i
            ATT::KeyLog.debug("进入 PWD request 是:::#{request_str}")
            do_pwd(request_str)
          when /^CWD/i
            ATT::KeyLog.debug("进入 CWD request 是:::#{request_str}")
            do_cwd(request_str)
          when /^CDUP/i
            ATT::KeyLog.debug("进入 CDUP request 是:::#{request_str}")
            do_cdup(request_str)
          when /^RMD/i
            ATT::KeyLog.debug("进入 RMD request 是:::#{request_str}")
            do_rmd(request_str)
          when /^MKD/i
            ATT::KeyLog.debug("进入 MKD request 是:::#{request_str}")
            do_mkd(request_str)
          when /^QUIT/i
            ATT::KeyLog.debug("进入 QUIT request 是:::#{request_str}")
            is_done = do_quit()
          when /^PORT/i
            ATT::KeyLog.debug("进入 PORT request 是:::#{request_str}")
            do_port(request_str)
          when /^PASV/i
            ATT::KeyLog.debug("进入 PASV request 是:::#{request_str}")
            do_pasv(request_str)
          when /^TYPE/i
            ATT::KeyLog.debug("进入 TYPE request 是:::#{request_str}")
            do_type(request_str)
          when /^RETR/i
            ATT::KeyLog.debug("进入 RETR request 是:::#{request_str}")
            do_retr(request_str)
          when /^STORE/i
            ATT::KeyLog.debug("进入 STORE request 是:::#{request_str}")
            do_store(request_str)
          when /^DELE/i
            ATT::KeyLog.debug("进入 DELE request 是:::#{request_str}")
            do_dele(request_str)
          when /^LIST/i
            ATT::KeyLog.debug("进入 LIST request 是:::#{request_str}")
            do_list(request_str)
          when /^NOOP/i
            ATT::KeyLog.debug("进入 NOP request 是:::#{request_str}")
            do_noop()
          when /^SYST/i
            ATT::KeyLog.debug("进入 SYST request 是:::#{request_str}")
            do_syst()
          else
            ATT::KeyLog.debug("进入 do_unknow_request request 是:::#{request_str}")
            do_unknow_request()
          end
        end
      rescue
        ATT::KeyLog.error("Error Web get on #{request}: \n #{$!.to_s} \n #{$!.backtrace.join("\n     ")}") rescue nil
        session.write "#{get_error_head(500)}<html><head><title>WS</title></head><body>Error : #{$!}" rescue nil
      ensure
        session.close rescue nil
      end

      def do_login()
        loop do
          ATT::KeyLog.debug("进入了用户登陆函数")
          user_str = @session_hash[Thread.current].gets.chomp
          ATT::KeyLog.debug("在用户登陆的时候输入了神马?::#{user_str}")
          if user_str =~ /^USER.*/i # => 用户登陆部分
            user = (user_str.split(/\s+/)+['', '', ''])[1].chomp
            ATT::KeyLog.debug("获得的 user 是:::#{user}")
            ATT::KeyLog.debug("这个USER的密码是:::#{@server_user_and_pass_hash[user]}")
            @session_hash[Thread.current].puts("331 Password for #{user}")
            passwd_str = @session_hash[Thread.current].gets.chomp
            passwd = (passwd_str.split(/\s+/)+['', '', ''])[1]
            ATT::KeyLog.debug("获得的 passwd 是:::#{passwd}")
            if passwd_str !~ /^PASS.*/i
              @session_hash[Thread.current].puts("530 Please login with USER and PASS.")
              next 
            end
            if @server_user_and_pass_hash[user] != passwd
              @session_hash[Thread.current].puts("530 Not logged in, user or password incorrect!")
              next
            end
            @session_hash[Thread.current].puts("230 User "+user+" logged in.\n")
            return true
          else
            next
          end
        end
        return false
      end

      def do_pwd(request_str)
        @session_hash[Thread.current].puts("257 \"" + @current_dir_hash[Thread.current] +"\" is current directory.")
        return true
      end
      def do_cwd(request_str)
        cwd_dir = (request_str.split(/\s+/)+['', '', ''])[1]
        if(cwd_dir =~ /^\.\//)
          tmp_dir = @current_dir_hash[Thread.current] + "/" + cwd_dir[1..-1]
        elsif cwd_dir =~ /^\//
          tmp_dir = "."  + cwd_dir
        else
          tmp_dir = @current_dir_hash[Thread.current] + "/" + cwd_dir
        end
        @session_hash[Thread.current].puts("553 the path is not a directory");return false if not File.directory?(tmp_dir)
        @session_hash[Thread.current].puts("250 CWD command succesful")
        @current_dir_hash[Thread.current] = tmp_dir
        return true
      end

      def do_cdup(request_str)
        @session_hash[Thread.current].puts("250 CWD command succesful")
        num = @current_dir_hash[Thread.current].rindex('/')
        @current_dir_hash[Thread.current] = @current_dir_hash[Thread.current][0..num]
        return true
      end

      def do_mkd(request_str)
        mkd_dir = (request_str.split(/\s+/)+['', '', ''])[1]
        if(mkd_dir =~ /^\.\//)
          tmp_dir = @current_dir_hash[Thread.current] + "/" + mkd_dir[1..-1]
        elsif mkd_dir =~ /^\//
          tmp_dir = "."  + mkd_dir
        else
          tmp_dir = @current_dir_hash[Thread.current] + "/" + mkd_dir
        end
        @session_hash[Thread.current].puts("553 the path is alread exist");return false if File.exist?(tmp_dir)
        @session_hash[Thread.current].puts("257 MKD command succesful")
        FileUtils.mkdir_p(tmp_dir)
        return true
      end

      def do_rmd(request_str)
        rmd_dir = (request_str.split(/\s+/)+['', '', ''])[1]
        if(rmd_dir =~ /^\.\//)
          tmp_dir = @current_dir_hash[Thread.current] + "/" + rmd_dir[1..-1]
        elsif rmd_dir =~ /^\//
          tmp_dir = "."  + rmd_dir
        else
          tmp_dir = @current_dir_hash[Thread.current] + "/" + rmd_dir
        end
        @session_hash[Thread.current].puts("553 the path is not a directory");return false if not File.directory?(tmp_dir)
        @session_hash[Thread.current].puts("250 RMD command succesful")
        FileUtils.rm_rf(tmp_dir)
        return true
      end

      def do_quit()
        @session_hash[Thread.current].puts("GOOD BYE")
        @data_socket_hash[Thread.current].close if @data_socket_hash[Thread.current] != nil and not @data_socket_hash[Thread.current].closed? rescue nil
        @session_hash[Thread.current].close
        return true
      end

      def do_port(request_str)
        begin
          clean_request = (request_str.split(/\s+/)+['', '', ''])[1]
          #clean_request = url.gsub(/\s/, "") { |match| puts match }
          ATT::KeyLog.debug("PORT出现的请求是 :")
          ATT::KeyLog.debug( clean_request )
          param_array = clean_request.split(",")
          @session_hash[Thread.current].puts("200 PORT command successful")
          data_ip_addr = (param_array[0] + "." + param_array[1] + "." + param_array[2] + "." + param_array[3])
          data_port = param_array[4].to_i * 256 + param_array[5].to_i
          ATT::KeyLog.debug("PORT模式的需要连接的地址是: #{data_ip_addr} 端口是: #{data_port.to_s}")
          @data_socket_hash[Thread.current].close if @data_socket_hash[Thread.current] != nil and not @data_socket_hash[Thread.current].closed? rescue nil
          @data_socket_hash[Thread.current] = TCPSocket.new(data_ip_addr, data_port)
        rescue Exception => e
          @session_hash[Thread.current].puts("500 PORT command wrong, unsupported")
          ATT::KeyLog.error("PORT命令出错了:")
          ATT::KeyLog.error(e.backtrace)
        end
      end

      def do_pasv(request_str)
        5.times { # => 尝试五次侦听端口,都失败就出错返回
          begin
            port = rand(65535-1024) + 1024
            @data_socket_hash[Thread.current].close if @data_socket_hash[Thread.current] != nil and not @data_socket_hash[Thread.current].closed? rescue nil
            ATT::KeyLog.debug("PASV模式的侦听端口是: #{port}")
            @data_socket_hash[Thread.current] = Thread.new(port) { |port| TCPServer.new("0.0.0.0", port).accept }
            prot_last = port % 265
            port_first = ((port - prot_last) / 265 ).to_i
            server_ip_array = local_ip.to_s.split(".")
            @session_hash[Thread.current].puts("227 Entering Passive Mode (#{server_ip_array[0]},#{server_ip_array[1]},#{server_ip_array[2]},#{server_ip_array[3]},"+
                "#{port_first},#{prot_last}).")
            return true
          rescue Exception => e
            ATT::KeyLog.error("PASV模式侦听端口出错了!从来!")
            next
          end
        }
        return false
      end

      def do_type(request)
        type = request.split(/\s/)[1]
        if type and type =~ /[IiAa]/
          @session_hash[Thread.current].puts("200 type #{type} set")
          @type = type
          return true
        else
          @session_hash[Thread.current].puts("500 type #{type} set false")
          return false
        end
      end

      def do_retr(request_str)
        file_name = request_str.split(/\s/)[1]
        retr_and_store("retr",file_name)
      end

      def do_store(request_str)
        file_name = request_str.split(/\s/)[1]
        retr_and_store("store",file_name)
      end

      def retr_and_store(type,file_name)
        if @data_socket_hash[Thread.current] == nil or @data_socket_hash[Thread.current].closed?
          @session_hash[Thread.current].puts("500 data socket not set,please PORT or PASV first")
          return false
        elsif type == "retr"
          if File.exist?(@current_dir_hash[Thread.current] + file_name)
            File.open(@current_dir_hash[Thread.current] + file_name, "rwb") { |file|
              @session_hash[Thread.current].puts("150 Opening ASCII mode data connection for directory list.")
              @data_socket_hash[Thread.current].write( file.read )
            }
          else
            @session_hash[Thread.current].puts("553 the file requested not exist")
            return false
          end
        elsif type == "store"
          @session_hash[Thread.current].puts("553 the file requested is a directory");return false if File.directory?(@current_dir_hash[Thread.current] + "/" + file_name)
          if File.exist?(@current_dir_hash[Thread.current] + file_name)
            FileUtils.rm_f(@current_dir_hash[Thread.current] + file_name)
          else
            FileUtils.mkdir_p(File.dirname(@current_dir_hash[Thread.current] + file_name))
          end
          File.new(@current_dir_hash[Thread.current] + file_name, "rwb"){ |file|
            @session_hash[Thread.current].puts("150 Opening ASCII mode data connection for directory list.")
            file.write( @data_socket_hash[Thread.current].read )
          }
          @session_hash[Thread.current].puts("226 transfer complete")
          return true
        end
      end

      def do_dele(request_str)
        file_name = request_str.split(/\s/)[1]
        @session_hash[Thread.current].puts("553 the file requested is a directory");return false if File.directory?(@current_dir_hash[Thread.current] + "/" + file_name)
        if File.exist?(@current_dir_hash[Thread.current] + "/" + file_name)
          FileUtils.rm_f(@current_dir_hash[Thread.current] + "/" + file_name)
          @session_hash[Thread.current].puts("250 delete command successful")
          return true
        else
          @session_hash[Thread.current].puts("553 file didn't exist")
          return false
        end
      end

      def do_list(request_str)
        path = request_str.split(/\s/)[1]
        if @data_socket_hash[Thread.current] == nil or @data_socket_hash[Thread.current].closed?
          @session_hash[Thread.current].puts("500 data socket not set,please PORT or PASV first")
          return false
        elsif path == nil or path == ""
          dir = @current_dir_hash[Thread.current]
        elsif File.directory?(@current_dir_hash[Thread.current] + "/" + path)
          dir = @current_dir_hash[Thread.current] + "/" + path
        end
        dirs, files = Dir.glob(dir=="./" ? "*" :dir+"/*").sort.partition { |f| File.directory?(f) }
        ATT::KeyLog.debug("LIST命令获得的目录是:" + dirs.to_s )
        ATT::KeyLog.debug("LIST命令获得的文件是:" + files.to_s )
        dirs.map { |dir_item|  @data_socket_hash[Thread.current].puts("d" + dir_item)}
        files.map { |file_item|  @data_socket_hash[Thread.current].puts("-" + file_item)}
        @data_socket_hash[Thread.current].close
        @session_hash[Thread.current].puts("226 transfer complete")
      end

      def do_noop()
        @connect_thread[Thread.current]=Time.now # => 刷新一下连接线程死亡时间
        @session_hash[Thread.current].puts("200 noop success")
        return true
      end

      def do_syst()
        @session_hash[Thread.current].puts("215 This is Sangfor test ftp_server")
        return true
      end
      
      def do_unknow_request()
        @session_hash[Thread.current].puts("502 Command not implemented.")
        return true
      end


      # => 停掉ftp服务器
      def stop_server
        ATT::KeyLog.info "exit on call stop_server !"
        @data_socket_hash.each { |thread,data_socket| data_socket.close rescue nil }
        @session_hash.each { |thread,session|
          session.close rescue nil
          thread.kill rescue nil
        }
        @server_socket.close rescue nil
        @server_thread.kill rescue nil
      end

      # => 获得本地对外IP地址
      def local_ip
        orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
        UDPSocket.open do |s|
          s.connect '8.8.8.8', 1
          return s.addr.last
        end
      ensure
        Socket.do_not_reverse_lookup = orig
      end


    end
  end
end

