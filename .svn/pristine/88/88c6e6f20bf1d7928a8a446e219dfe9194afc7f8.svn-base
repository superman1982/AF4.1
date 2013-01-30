# To change this template, choose Tools | Templates
# and open the template in the editor.
module AF
  module Servers
    class Mail_Server
      @@instance_server_array = []

      attr_accessor :connect_thread, :server_thread, :observe_thread, :session_hash


      # => 设定所有需要的变量
      def initialize(hash={:smtp_port => 25, :pop_port => 110, :server_runtime => true, :timeout => 120, :cadence => 10,
            :root_dir => "./", :welcome_word => "Welcome Sangfor Ruby Test Mail Server", :users => "user", :passwds => "passwd" })
        # => 初始化参数值放到实例变量里
        @smtp_port = hash[:smtp_port]
        @pop_port = hash[:pop_port]
        @timeout = hash[:timeout]
        @cadence = hash[:cadence]
        @root_dir = hash[:root_dir]
        @welcome_word = hash[:welcome_word]
        @server_runtime = hash[:server_runtime]
        # => 这是关键线程hash表,以线程为key,每个线程对应的变量都往里面放,线程自身管理其值的逻辑
        @thread_data_hash = {}
        # => 用户名密码哈希
        @server_user_and_pass_hash = {}
        # => 用户名密码初始化
        user_array = hash[:users].split("&") # => 支持多个用户
        passwd_array = hash[:passwds].split("&") # => 密码对应,如果密码比用户少的话,就用最后的密码扩展,就是说可以设定多个用户一个密码
        user_array.each_with_index { |user,index|
          @server_user_and_pass_hash[user.to_s] = index < passwd_array.size ? passwd_array[index] : passwd_array[-1]
        }
        # => 启动服务器侦听端口
        ATT::KeyLog.info("server smtp_port #{@smtp_port} ...")
        ATT::KeyLog.info("server pop_port #{@pop_port} ...")
        @smtp_server_socket = TCPServer.new('0.0.0.0', @smtp_port)
        @pop_server_socket = TCPServer.new('0.0.0.0', @pop_port)
        ATT::KeyLog.info("server MailServer smtp:#{@smtp_port} pop:#{@pop_port} ready!")
        @@instance_server_array << self
      end

      def init_thread_data_hash(hash)
        @thread_data_hash[Thread.current] = hash
      end

      def destory_thread_data_hash()
        @thread_data_hash[Thread.current].each { |key, item|
          item.close rescue nil
          item.kill rescue nil
          @thread_data_hash[Thread.current][key] = nil
        }
      end

      # => 启动服务,根据设定的主线程运行时间决定服务器运行时间
      def running_service()
        Dir.chdir(@root_dir)
        start_smtp_server()
        start_pop_server()
        # => 观察时间超过120的连接,就直接KILL掉,达成超时120,检测节奏为每 cadence 检测一次
        observe_session(@cadence, @timeout)
        # => 根据设定的时间退出主线程,这个线程要记得在退出的时候杀掉
        observe_main()
      end

      def reply(content,str_end="\r\n")
        ATT::KeyLog.debug("我要回个:#{content}")
        @thread_data_hash[Thread.current][:socket].write(content + str_end)
        @thread_data_hash[Thread.current][:socket].flush
      end

      def get_request
        #ATT::KeyLog.debug("进来取内容了")
        return @thread_data_hash[Thread.current][:socket].gets
      end

      # => 观察时间超过 delta 的连接,就直接KILL掉,达成超时 delta ,检测节奏为每 cadence_time 检测一次
      def observe_session(cadence_time, delta)
        @observe_thread = Thread.new do
          loop do
            sleep(cadence_time)
            nowDelta=Time.now-delta
            smtp_client_thread = @smtp_connect_thread_hash.select { |th, time| (time<nowDelta) }
            smtp_client_thread.each { |thread, tm|
              if @is_transport_hash[thread] != true
                ATT::KeyLog.info("killing thread")
                @session_hash[thread].close rescue nil
                @data_socket_hash[thread].close rescue nil
                thread.kill rescue nil
                @connect_thread.delete(th)
              end
            }
            pop_client_thread = @pop_connect_thread_hash.select { |th, time| (time<nowDelta) }
            pop_client_thread.each { |thread, tm|
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

      def observe_main()
        @observe_main_thread = Thread.new { loop do
            sleep @cadence
            if @server_runtime == true
              next
            end
            if @server_runtime == 0
              stop_server
            end
            @server_runtime -= 1
          end }
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
        @observe_main_thread.kill rescue nil # => stop_server函数有可能被主观察线程调用,最后才能杀掉自己
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
require 'lib/servers/mail_server_smtp'
require 'lib/servers/mail_server_pop3'