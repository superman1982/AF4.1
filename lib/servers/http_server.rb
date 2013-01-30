# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'att'
require "openssl"
module AF
  module Servers
  
    class Http_Server
      @@runing_server = []
      def unescape(string)
        ; string.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2}))/n) { [$1.delete('%')].pack('H*') }
      end

      attr_accessor :connect_thread, :socket_thread, :observe_thread, :server
      
      def self.stop_all_service
        @@runing_server.each { |server|  
          Thread.kill(server.socket_thread) rescue nil
          server.server.close rescue nil
          server.connect_thread.each_key { |key| Thread.kill(key) } rescue nil
          server.observe_thread.kill rescue nil
          @@runing_server.delete(server)
        }
      end
      # => 设定所有需要的变量
      def initialize(init_hash={:port =>80, :server_runtime => true,:timeout =>120,:cadence => 10,:root_dir => "./"})
        @port = init_hash[:port] || 80
        @timeout = init_hash[:timeout] || 120
        @cadence =init_hash[:cadence] || 10
        @root_dir = init_hash[:root_dir] || "./"
        @respone_head = init_hash[:respone_head]
        @respone_code = init_hash[:respone_code]
        @http_edition = init_hash[:http_edition]
        @user_define_head = init_hash[:user_define_head]
        @user_define_respone = init_hash[:user_define_respone]
        @is_ssl = init_hash[:is_ssl]
        @connect_thread = {} # => 子连接的线程hash表
        @cb = {}
        @redirect = {}
        @socket_thread = nil # => 主等待SOCKET的线程
        @observe_thread = nil # => 观察accetp后的socket的线程
        @server_runtime = init_hash[:server_runtime] # => 服务器运行的时间
        ATT::KeyLog.info("是不是https服务器??>>> #{@is_ssl} ...\n")
        if @is_ssl == "是"
          ATT::KeyLog.info("SSL server http #{@port} ...\n")
          @root_cert_file = @root_dir+'./'+ 'root_cert.pem'
          @root_key_file = @root_dir+'./'+ 'root_key.pem'
          @root_cert_file2 = @root_dir+'./'+ 'root_cert.2pem'
          @root_key_file2 = @root_dir+'./'+ 'root_key2.pem'
          @child_cert_file = @root_dir+'./'+ 'child_cert.pem'
          @child_key_file = @root_dir+'./'+ 'child_key.pem'
          ATT::KeyLog.info "下面是入参数值"
          ATT::KeyLog.info init_hash[:root_cert_1]
          ATT::KeyLog.info init_hash[:root_cert_2]
          ATT::KeyLog.info init_hash[:child_cert]
          root_ca_hash = make_root_cert_hash(init_hash[:root_cert_1].split("$:$"))
          root_ca_hash2 = make_root_cert_hash2(init_hash[:root_cert_2].split("$:$")) if init_hash[:root_cert_2] != nil and init_hash[:root_cert_2] != ""
          child_ca_hash = make_child_cert_hash(init_hash[:child_cert].split("$:$"))
          creat_root_cert(root_ca_hash)
          creat_root_cert2(root_ca_hash) if init_hash[:root_cert_2] != nil and init_hash[:root_cert_2] != ""
          creat_child_cert(child_ca_hash)
          creat_ssl_context()
          @server = OpenSSL::SSL::SSLServer.new(TCPServer.new('0.0.0.0', @port), @sslContext)
          set_close_on_exec(@server)
          set_non_blocking(@server)
          @server.start_immediately = true
          ATT::KeyLog.info("SSL server http #{@port} ready!")
        else
          ATT::KeyLog.info("server http #{@port} ...")
          @server = TCPServer.new('0.0.0.0', @port)
          ATT::KeyLog.info("server http #{@port} ready!\n")
        end
        @@runing_server << self
      end

      # => 运行http服务,根据设定的主线程运行时间决定服务器运行时间
      def running_service()
        @socket_thread = Thread.new {
          while (true)  # => 等待线程循环等待
            begin
              session = @server.accept
              set_close_on_exec(session) if @is_ssl == "是"
              set_non_blocking(session) if @is_ssl == "是"
              ATT::KeyLog.info("accept成功~!!!")
              Thread.new(session) do |accept_session|
                begin
                  @connect_thread[Thread.current]=Time.now
                  request(accept_session)
                  @connect_thread.delete(Thread.current)
                rescue Exception => ex
                  ATT::KeyLog.info("这里子线程socket出错")
                  ATT::KeyLog.info(ex.backtrace.join("\n")+"\n")
                  ATT::KeyLog.info($!.to_s)
                ensure
                  accept_session.close rescue nil
                end
              end
            rescue Exception => er
              ATT::KeyLog.info("这里主等待socket的线程出错了~!!出错的提示信息如下::\n")
              ATT::KeyLog.info(er.backtrace.join("\n")+"\n")
              ATT::KeyLog.info($!.to_s + "\n")
            end
          end
        }
        # => 观察时间超过120的连接,就直接KILL掉,达成超时120,检测节奏为每 cadence 检测一次
        observe(@cadence, @timeout)
        # => 这里切换到服务器根目录,这样切换了,后面的相对地址就可以有根据了
        # 关键字修改...因为不能chdir让工作目录变化导致对应的lib加载不上
        #Dir.chdir(@root_dir)
        # => 根据设定的时间退出主线程
        Thread.new { loop do
            sleep @cadence
            if @server_runtime == true
              next
            end
            if @server_runtime == 0
              @server.close rescue nil 
              @connect_thread.keys.each { |item| item.kill } rescue nil
              Thread.kill(@socket_thread) rescue nil
              Thread.kill(@observe_thread) rescue nil
              Trhead.current.kill rescue nil
            end
            @server_runtime -= 1
          end }
      end # => end of running_service

      def serve(uri, &blk)
        @cb[uri] = blk
      end

      # => 观察时间超过 delta 的连接,就直接KILL掉,达成超时 delta ,检测节奏为每 cadence_time 检测一次
      def observe(cadence_time, delta)
        @observe_thread = Thread.new do
          loop do
            sleep(cadence_time)
            nowDelta=Time.now-delta
            l=@connect_thread.select { |th, tm| (tm<nowDelta) }
            l.each { |th, tm| ATT::KeyLog.info("连接线程超时了,kill掉,killing thread"); th.kill; @connect_thread.delete(th) }
          end;
        end
      end

      # => 对每个请求的处理,session就是accept后获得socket
      def request(session)
        request = session.gets
        ATT::KeyLog.debug("这里的request是:::#{request}")
        if request == nil # => 这里发来一行空行我直接返回成功算了
          send_special_success(session)
          return
        end
        uri = (request.split(/\s+/)+['', '', ''])[1]
        ATT::KeyLog.debug "这里 URI获得的信息 :: #{uri}"
        if(uri =~ /^.*:\/\/.*/) # => 匹配请求的url内容是完整路径(http://xxxx)这样的,那我就把对应的HTTP://域名部分全部清除了
          ATT::KeyLog.debug("匹配上头带http的==============")
          uri = uri[uri.index(/\//,uri.index(/:\/\//)+4)..-1]
        end
        service, param=(uri+"?").split(/\?/)
        params = Hash[*(param.split(/#/)[0].split(/[=&]/))] rescue {}
        params.each { |k, v| params[k]=unescape(v) }
        uri = unescape(service)[1..-1].gsub(/\.\./, "")
        userpass=nil
        if (buffer_uri=uri.split(/@/)).size>1
          uri=buffer_uri[1..-1].join("@")
          userpass=buffer_uri[0].split(/:/)
        end
        ATT::KeyLog.debug "这里最终 全部的信息 :: \nuri:==#{uri}\nuserpass:==#{userpass}\nparams:==#{params}"
        do_service(session, request, uri, userpass, params)
      rescue
        ATT::KeyLog.error("Error Web get on #{request}: \n #{$!.to_s} \n #{$!.backtrace.join("\n     ")}") rescue nil
        session.write "#{get_error_head(500)}<html><head><title>Sangfor测试系统</title></head><body>Error : #{$!}" rescue nil
      ensure
        session.close rescue nil
      end

      # => 对每个请求的真正处理
      def do_service(session, request, service, user_passwd, params)
        redirect=@redirect["/"+service]
        service=redirect.gsub(/^\//, "") if @redirect[redirect]
        ATT::KeyLog.info("这里的service是 :: #{service}, request是: #{request}")
        if request =~ /^GET\s*\/special_sql_error.*/ 
          ATT::KeyLog.info("进入了get方法的特殊返回值需求,返回特殊错误码~!!=============")
          sendError(session,500,"Microsoft OLE DB Provider for SQL Server")
        elsif request =~ /^POST\s*.*\/case.*/ # => POST的显示普通页面
          ATT::KeyLog.info("剩下的Post内容::\n")
          1.times{
            sleep 0.5
            ATT::KeyLog.info(session.readpartial(102400)) rescue nil
          }
          if File.directory?(@root_dir + "./" + service)
            sendData(session, ".html", makeIndex("./"+service))
          elsif File.exists?(@root_dir + "./" + service)
            sendFile(session, @root_dir + "./" + service)
          else
            send_speciall_head(mime(".html"),session,"<html><head><title>WoolenTest</title></head><body>Success : #{SPECIAL_SUCCESS} </body></html>");
          end
        elsif request =~ /.*special_head_respone.*/ # => 特殊的头部返回
          ATT::KeyLog.info("剩下的Post内容::\n")
          1.times{
            sleep 0.5
            ATT::KeyLog.info(session.readpartial(102400)) rescue nil
          }
          if(@user_define_respone != nil and @user_define_respone != "") 
            send_speciall_head(mime(".html"),session,@user_define_respone);
          elsif File.exists?(@root_dir + "./" + service)
            content = ""
            File.open(@root_dir + "./" + service, "rb") { |f| content << f.read  }
            send_speciall_head(mime(@root_dir + "./" + service),session, content)
          else
            send_speciall_head(mime(".html"),session,"<html><head><title>WoolenTest</title></head><body>Success : #{SPECIAL_SUCCESS} </body></html>");
          end
          #send_speciall_head(mime(".html"),session,"<html><head><title>WoolenTest</title></head><body>Success : #{SPECIAL_SUCCESS} </body></html>");
        elsif request =~ /^POST.*/ # => post方法的都当一个上传文件做处理
          get_the_upload_file(session, service)
        elsif redirect && !@redirect[redirect]
          do_service(session, request, redirect.gsub(/^\//, ""), user_passwd, params)
        elsif @cb["/"+service]
          begin
            code, type, data= @cb["/"+service].call(params)
            if code==0 && data != '/'+service
              do_service(session, request, data[1..-1], user_passwd, params)
            else
              code==200 ? sendData(session, type, data) : sendError(session, code, data)
            end
          rescue
            puts "Error in get /#{service} : #{$!}"
            sendError(session, 501, $!.to_s)
          end
        elsif service =~ /^stop/
          sendData(session, ".html", "Stopping...");
          Thread.new() { sleep(0.1); stop_browser() }
        elsif File.directory?(@root_dir + "./" + service)
          sendData(session, ".html", makeIndex("./"+service))
        elsif File.exists?(@root_dir + "./" + service) # => 下载文件
          sendFile(session, @root_dir + "./" + service)
        else
          ATT::KeyLog.info("unknown request serv=#{service} params=#{params.inspect} #{File.exists?(service)}")
          sendError(session, 500);
        end
      end

      # => 特殊页面可以停掉web服务器 以stop结尾的页面
      def stop_browser
        ATT::KeyLog.info "exit on web demand !"
        @serveur.close rescue nil
        @observe_thread.kill rescue nil
        @socket_thread.kill rescue nil
      end

      # => 这里是回复目录信息的
      def makeIndex(dir)
        dirs, files=Dir.glob(dir== "./" ? @root_dir + "*" :@root_dir + dir+"/*").sort.partition { |f| File.directory?(f) }
        up_dir = dir.split(/\//)[0..-2].join("/")
        dirs=[up_dir]+dirs if up_dir.length>0
        "<html><body>#{SPECIAL_SUCCESS}<h3>Repertoire #{dir}</h3><form name=\"a\" method=\"post\" ENCTYPE=\"multipart/form-data\" action=\"#{dir}\"><input type=\"file\" name=\"File\"><input type=submit name=\"submit\" value=\"Submit_file\"></form><hr><br>#{to_table(dirs.map { |s| s.gsub!(@root_dir, "./"); "<a href='#{"/"+s}'>"+s+"/"+"</a>" })}\
          <hr>#{to_table_b(files) { |f| [ICON[rand(ICON.size)], "<a href='#{"/"+f.gsub(@root_dir, "./")}'>"+File.basename(f)+"</a>", File.size(f), File.mtime(f).strftime("%d/%m/%Y %H:%M:%S")] }}</body></html>"
      end

      # => 目录table
      def to_table(l)
        "<table><tr>#{l.map { |s| "<td>#{s}</td>" }.join("</tr><tr>")}</tr></table>"
      end

      # => 文件table
      def to_table_b(l, &bl)
        "<table><tr>#{l.map { |s| "<td>#{bl.call(s).join("</td><td>")}</td>" }.join("</tr><tr>")}</tr></table>"
      end

      # => 返回错误值
      def sendError(sock, no, txt=nil)
        error_info = "<html><body><pre></pre><p>Sangfor测试系统Error #{no} : #{txt}</p></body></html>"
        ATT::KeyLog.debug("错误值:\n"+error_info)
        sock.write(get_error_head(no,txt,error_info.size))
        sock.write(error_info)
        sock.flush
      end

      # => 返回数据,显示目录
      def sendData(sock, type, content)
        sock.write(get_ok_head(mime(type), content.size))
        sock.write(content)
      end

      # => 下载文件
      def sendFile(sock, filename)
        sock.write(get_ok_head(mime(filename), File.size(filename)))
        File.open(filename, "rb") { |f| sock.write(f.read) }
      end

      # 上传文件处理,只做上传一个文件的处理
      def get_the_upload_file(session_rw, file)
        ATT::KeyLog.debug("get_the_upload_file获得的file是:#{file}")
        is_file = false
        is_already_set_file = false
        boundary = ""
        not_file_count = 0
        begin
          if not File.directory?("./"+file) and file[-1,1] != "/" and file[-1,1] != "\\"
            FileUtils.mkdir_p(File.dirname("./"+file))
            created_file = File.new("./"+file, "w+")
          else
            FileUtils.mkdir_p(File.dirname("./"+file+"/tmp_upload_file.txt"))
            created_file = File.new("./"+file+"/tmp_upload_file.txt", "w+")
          end 
          ATT::KeyLog.info("这里开始获得行是::")
          # 这里逻辑还有问题,只是假应答了成功返回,暂时这样吧,gets函数出错,不知道为何,知识有限
          while (line = session_rw.gets("\n"))
            ATT::KeyLog.debug(line)
            if( line.to_s.include?("boundary=") )
              boundary = (line.to_s.split("boundary="))[1]
              boundary = boundary[0..-4]
              ATT::KeyLog.debug("这里获得的boundary是:: #{boundary}")
            end
            if(boundary != "" and line =~ Regexp.new("^--#{boundary}") )
              ATT::KeyLog.debug("匹配上boundary开头行了,boundary是#{boundary}")
              if is_file # => 如果已经开始读取文件然后还能再进这里,那就是直接退出好了
                send_special_success(session_rw)
                session_rw.flush
                session_rw.close
                return
              else
                is_file = true
              end
            end
            if( is_file )
              if(not_file_count == 4 and line !~ /^\s$/)
                ATT::KeyLog.debug("正在获得文件内容,文件内容是::#{line}")
                created_file.write(line)
              else
                not_file_count += 1
              end
            end
          end
        rescue Exception => e
          ATT::KeyLog.error("出错了,在写文件或读取客户端浏览器数据时,以下是堆栈:\n#{e.backtrace}")
        ensure
          (created_file.close rescue nil) if created_file != nil
          send_special_success(session_rw)
        end
      end

      def mime(string)
        MIME[string.split(/\./).last] || "data-octet-stream"
      end

      # => 特别测试用的返回成功
      def send_special_success(sock)
        html = "html"
        sock.write "#{get_ok_head(mime(html),100)}<html><head><title>WoolenTest</title></head><body>Success : #{SPECIAL_SUCCESS} </body></html>" rescue nil
      end

      SPECIAL_SUCCESS = "<p>woolen_af_test</p>"
      # 字符图标
      CRLF = "\r\n"
      ICON="&#9728;&#9731;&#9742;&#9745;&#9745;&#9760;&#9763;&#9774;&#9786;&#9730;".split(/;/).map { |c| c+";" }
      MIME={"png" => "image/png", "gif" => "image/gif", "html" => "text/html", "htm" => "text/html",
        "js" => "text/javascript", "css" => "text/css", "jpeg" => "image/jpeg", "jpg" => "image/jpeg",
        "pdf" => "application/pdf", "svg" => "image/svg+xml", "svgz" => "image/svg+xml",
        "xml" => "text/xml", "xsl" => "text/xml", "bmp" => "image/bmp", "txt" => "text/plain",
        "rb" => "text/plain", "pas" => "text/plain", "tcl" => "text/plain", "java" => "text/plain",
        "c" => "text/plain", "h" => "text/plain", "cpp" => "text/plain", "xul" => "application/vnd.mozilla.xul+xml",
        "php" => "text/html", "asp" => "text/html"
      }
      
      def send_speciall_head(type,session,content)
        speciall_head = get_speciall_head(type,content)
        session.write(speciall_head)
        session.write(content)
      end
      
      def get_speciall_head(type, content)
        speciall_head = <<JUST_SPECIALL_HEAD
HTTP/#{@http_edition} #{@respone_code} OK
Content-Length: #{content.length}
Content-Type: #{type}
JUST_SPECIALL_HEAD
      
        if @respone_head != nil && @respone_head.is_a?(Hash) && @respone_head.size > 0 
          @respone_head.each do |key,value| 
            ATT::KeyLog.debug("需要构造的头部key:#{key}，需要构造的头部value[0]:#{value[0]},value[1]:#{value[1]}")
            i = 0
            value_size = value[0].is_a?(String) ? value[0].to_i : value[0] 
            while( i < value_size )
              speciall_head << key + ": " + value[1] + CRLF
              i += 1
            end
          end
        end
        speciall_head << @user_define_head if @user_define_head != nil and @user_define_head != "" and @user_define_head[-1,1] == "\n"
        speciall_head << CRLF
        ATT::KeyLog.debug("完成特殊头部的构造，头部如下：：")
        ATT::KeyLog.debug(speciall_head)
        return speciall_head
      end
      def get_ok_head(type,content_length)
        head_ok = <<JUST_HEAD_OK
HTTP/#{@http_edition} 200 OK
Content-Length: #{content_length}
Content-Type: #{type}
Content-Location: http://0.0.0.0/index.html
Last-Modified: Tue, 04 Sep 2012 06:14:58 GMT
Accept-Ranges: bytes
ETag: "1ea2449c648acd1:3e8"
Server: Microsoft-IIS/6.0

JUST_HEAD_OK
        return head_ok
      end
        
      def get_error_head(error_no,mesg = "NOK",length = 150)
        head_no_ok = <<JUST_HEAD_OK
HTTP/#{@http_edition} #{error_no} #{mesg}
Content-Length: #{length}
Content-Type: text/html
Content-Location: http://0.0.0.0/index.html
Last-Modified: Tue, 04 Sep 2012 06:14:58 GMT
Accept-Ranges: bytes
ETag: "1ea2449c648acd1:3e8"
Server: Microsoft-IIS/6.0

JUST_HEAD_OK
        return head_no_ok
      end
      
      
      def make_root_cert_hash(data)
        root_ca_hash = {}
        root_ca_hash[:root_ca_key_length] = data[0].to_i
        root_ca_hash[:root_ca_version] = data[1].to_i
        root_ca_hash[:root_key_type] = data[2]
        root_ca_hash[:root_ca_name] = data[3]
        ATT::KeyLog.debug("生成的root_cert_hash::#{root_ca_hash.to_a}")
        return root_ca_hash
      end
      def make_root_cert_hash2(data)
        root_ca_hash2 = {}
        root_ca_hash2[:root_ca_key_length] = data[0].to_i
        root_ca_hash2[:root_ca_version] = data[1].to_i
        root_ca_hash2[:root_key_type] = data[2]
        root_ca_hash2[:root_ca_name] = data[3]
        ATT::KeyLog.debug("生成的 root_ca_hash2 ::#{root_ca_hash2.to_a}")
        return root_ca_hash2
      end
      def make_child_cert_hash(data)
        child_ca_hash = {}
        child_ca_hash[:child_ca_key_length] = data[0].to_i
        child_ca_hash[:child_ca_version] = data[1].to_i
        child_ca_hash[:child_key_type] = data[2]
        child_ca_hash[:child_ca_name] = data[3]
        ATT::KeyLog.debug("生成的 child_ca_hash ::#{child_ca_hash.to_a}")
        return child_ca_hash
      end
      def creat_root_cert(hash)
        printf("hash::\n#{hash.to_s}\n")
        if (hash[:root_key_type] == "DSA")
          @root_key = OpenSSL::PKey::DSA.new(hash[:root_ca_key_length])
        elsif (hash[:root_key_type] == "DH")
          @root_key = OpenSSL::PKey::DH.new(hash[:root_ca_key_length])
        elsif (hash[:root_key_type] == "EC")
          @root_key = OpenSSL::PKey::EC.new(hash[:root_ca_key_length])
        elsif (hash[:root_key_type] == "PKey")
          @root_key = OpenSSL::PKey::PKey.new(hash[:root_ca_key_length])
        else
          @root_key = OpenSSL::PKey::RSA.new(hash[:root_ca_key_length]) # the CA's public/private key
        end

        @root_cert = OpenSSL::X509::Certificate.new
        @root_cert.version = hash[:root_ca_version] - 1  # 2 cf. RFC 5280 - to make it a "v3" certificate
        @root_cert.serial = 1
        sub = OpenSSL::X509::Name.new()
        sub.add_entry('DC', 'Org')
        sub.add_entry('DC', 'Ruby_lanuage')
        sub.add_entry('ST', 'Shimane')
        sub.add_entry('O','Sangfor')
        sub.add_entry('OU','Sangfor_AFT')
        sub.add_entry('CN', hash[:root_ca_name])
        @root_cert.subject = sub
        @root_cert.issuer = @root_cert.subject # root CA's are "self-signed"
        @root_cert.public_key = @root_key.public_key
        @root_cert.not_before = Time.now  - 2 * 365 * 24 * 60 * 60 # => 2年前
        @root_cert.not_after = @root_cert.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = @root_cert
        ef.issuer_certificate = @root_cert   # => 根证书是自签证的
        @root_cert.extensions = []
        @root_cert.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
        @root_cert.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
        @root_cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",true))
        @root_cert.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",true))
        @root_cert.sign(@root_key, OpenSSL::Digest::SHA1.new) # => 签证
        open @root_cert_file, 'w' do |io|
          io.write @root_cert.to_pem
        end
        open @root_key_file, 'w' do |io|
          io.write @root_key.to_pem
        end
        printf("完成了root_cert的构建~~\n")
      end
      
      def creat_root_cert2(hash)
        printf("hash::\n#{hash.to_s}\n")
        if (hash[:root_key_type] == "DSA")
          @root_key2 = OpenSSL::PKey::DSA.new(hash[:root_ca_key_length])
        elsif (hash[:root_key_type] == "DH")
          @root_key2 = OpenSSL::PKey::DH.new(hash[:root_ca_key_length])
        elsif (hash[:root_key_type] == "EC")
          @root_key2 = OpenSSL::PKey::EC.new(hash[:root_ca_key_length])
        elsif (hash[:root_key_type] == "PKey")
          @root_key2 = OpenSSL::PKey::PKey.new(hash[:root_ca_key_length])
        else
          @root_key2 = OpenSSL::PKey::RSA.new(hash[:root_ca_key_length]) # the CA's public/private key
        end

        @root_cert2 = OpenSSL::X509::Certificate.new
        @root_cert2.version = hash[:root_ca_version] - 1  # 2 cf. RFC 5280 - to make it a "v3" certificate
        @root_cert2.serial = rand(65535)
        sub = OpenSSL::X509::Name.new()
        sub.add_entry('DC', 'Org')
        sub.add_entry('DC', 'Ruby_lanuage')
        sub.add_entry('ST', 'Shimane')
        sub.add_entry('O','Sangfor')
        sub.add_entry('OU','Sangfor_AFT')
        sub.add_entry('CN', hash[:root_ca_name])
        @root_cert2.subject = sub
        @root_cert2.issuer = @root_cert.subject # 签证证书是被跟证书签证的
        @root_cert2.public_key = @root_key2.public_key
        @root_cert2.not_before = Time.now  - 1 * 365 * 24 * 60 * 60 # => 一年前
        @root_cert2.not_after = @root_cert2.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = @root_cert2
        ef.issuer_certificate = @root_cert   # => 签证证书是被跟证书签证的
        @root_cert2.extensions = []
        @root_cert2.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
        @root_cert2.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
        @root_cert2.add_extension(ef.create_extension("subjectKeyIdentifier","hash",true))
        @root_cert2.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",true))
        @root_cert2.add_extension(ef.create_extension("nsComment", "Woolen_Comment"))
        @root_cert2.sign(@root_key, OpenSSL::Digest::SHA1.new) # => 签证
        open @root_cert_file2, 'w' do |io|
          io.write @root_cert2.to_pem
        end
        open @root_key_file2, 'w' do |io|
          io.write @root_key2.to_pem
        end
        printf("完成了root_cert2的构建~~\n")
      end

      def creat_child_cert(hash)
        if (hash[:child_key_type] == "DSA")
          @child_key = OpenSSL::PKey::DSA.new(hash[:child_ca_key_length])
        elsif (hash[:child_key_type] == "DH")
          @child_key = OpenSSL::PKey::DH.new(hash[:child_ca_key_length])
        elsif (hash[:child_key_type] == "EC")
          @child_key = OpenSSL::PKey::EC.new(hash[:child_ca_key_length])
        elsif (hash[:child_key_type] == "PKey")
          @child_key = OpenSSL::PKey::PKey.new(hash[:child_ca_key_length])
        else
          @child_key = OpenSSL::PKey::RSA.new(hash[:child_ca_key_length]) # the CA's public/private key
        end

        sub = OpenSSL::X509::Name.new()
        sub.add_entry('DC', 'Org')
        sub.add_entry('DC', 'Ruby_lanuage')
        sub.add_entry('ST', 'Shimane')
        sub.add_entry('O','Sangfor')
        sub.add_entry('OU','Sangfor_AFT')
        sub.add_entry('CN', hash[:child_ca_name])
        # => cipher = OpenSSL::Cipher::Cipher.new 'AES-128-CBC'
        # => key_secure = key.export(cipher, "sangfor")

        @child_cert = OpenSSL::X509::Certificate.new()
        @child_cert.not_before = Time.now - 1 * 365 * 24 * 60 * 60 # => 一年前
        @child_cert.not_after = Time.now + 1 * 365 * 24 * 60 * 60 # => 一年
        @child_cert.public_key = @child_key.public_key  # <= 接受签署的公匙
        @child_cert.serial = 0x7730a0121cfc9388b89d602ce958dd71
        @child_cert.version = hash[:child_ca_version] - 1
        @child_cert.issuer = @root_cert.subject  # => 颁发证书的是root_ca
        @child_cert.subject = sub

        # => 创建证书内容
        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = @child_cert
        ef.issuer_certificate = @root_cert
        @child_cert.add_extension(ef.create_extension("basicConstraints","CA:FALSE",true))
        @child_cert.add_extension(ef.create_extension("keyUsage","keyEncipherment,dataEncipherment,digitalSignature", true))
        @child_cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",true))
        if @root_key2 != nil and @root_key2.is_a? OpenSSL::PKey
          @child_cert.sign(@root_key2, OpenSSL::Digest::SHA1.new) 
        else 
          @child_cert.sign(@root_key, OpenSSL::Digest::SHA1.new) 
        end
        open @child_cert_file, 'w' do |io|
          io.write @child_cert.to_pem
        end
        open @child_key_file, 'w' do |io|
          io.write @child_key.to_pem
        end
        printf("完成了child_cert的构建~~\n")
      end

      def creat_ssl_context()
        @sslContext = OpenSSL::SSL::SSLContext.new("SSLv23_server") # "SSLv23_client"
        @sslContext.cert =  @child_cert # => OpenSSL::X509::Certificate.new(File.open(@certificate))
        @sslContext.key = @child_key
        @sslContext.verify_mode = OpenSSL::SSL::VERIFY_NONE
        @sslContext.client_ca = @root_cert
        @sslContext.extra_chain_cert = nil # => @root_cert
        @sslContext.ca_file = nil #@root_cert_file
        @sslContext.ca_path = nil # => @root_dir
        @sslContext.cert_store =  nil # => OpenSSL::X509::Store.new(@child_cert_file)
        @sslContext.verify_depth = 0
        @sslContext.verify_callback = nil
        @sslContext.timeout = 100
        @sslContext.options = nil
        #@sslContext.session_cache_mode = 3
        cipers = ""
        OpenSSL::Cipher.ciphers().each{|cipe|
          cipers << cipe + ":"
        }
        @sslContext.ciphers = cipers
        printf("完成了SSL_context的构建~~\n")
      end
      def set_close_on_exec(io)
        if defined?(Fcntl::FD_CLOEXEC)
          io.fcntl(Fcntl::FD_CLOEXEC, 1)
        end
      end

      def set_non_blocking(io)
        flag = File::NONBLOCK
        if defined?(Fcntl::F_GETFL)
          flag |= io.fcntl(Fcntl::F_GETFL)
        end
        io.fcntl(Fcntl::F_SETFL, flag)
      end


    end
  end
end
