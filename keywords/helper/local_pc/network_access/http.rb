# coding: utf8
module LocalPc
  module NetworkAccess
    module HttpHelper
      # => 上传的连接建立和数据发送的类
      class Multipart
        def initialize( file_names )
          @file_names = file_names
        end
        # => post方法上传文件
        # => user,password是设置的连接用户名和密码
        def post( to_url,user,password)
          boundary = '----RubyMultipartClient' + rand(1000000).to_s + 'ZZZZZ' # => 用来分割数据部分的boundary
          parts = []
          streams = []
          @file_names.each do |param_name, filepath|
            pos = filepath.rindex('/')
            filename = filepath[pos + 1, filepath.length - pos]
            # => 文件上传的formdata部分数据
            parts << StringPart.new( "--" + boundary + "\r\n" +
                "Content-Disposition: form-data; name=\"" + param_name.to_s + "\"; filename=\"" + filename + "\"\r\n" +
                "Content-Type: #{mime(filename)}\r\n\r\n")
            begin
              stream = File.open(filepath, "rb")
              streams << stream
            rescue IOError => e
              ATT::KeyLog.error("这里出现打开文件错误", e)
            end
            parts << StreamPart.new(stream, File.size(filepath))
          end
          parts << StringPart.new( "\r\n--" + boundary + "--\r\n" )
          post_stream = MultipartStream.new( parts )
          url = URI.parse( to_url )
          req = Net::HTTP::Post.new(url.path)
          req.basic_auth user,password
          req.content_length = post_stream.size
          req.content_type = 'multipart/form-data; boundary=' + boundary
          req.body_stream = post_stream
          ATT::KeyLog.debug("数据准备完毕,开始发送数据")
          res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
          streams.each do |stream|
            stream.close() rescue nil
          end
          ATT::KeyLog.debug("发送完数据了,返回的数据是:")
          ATT::KeyLog.debug(res.body)
          return res
        end
        
        MIME = {"png" => "image/png", "gif" => "image/gif", "html" => "text/html", "htm" => "text/html",
          "js" => "text/javascript", "css" => "text/css", "jpeg" => "image/jpeg", "jpg" => "image/jpeg",
          "pdf" => "application/pdf", "svg" => "image/svg+xml", "svgz" => "image/svg+xml",
          "xml" => "text/xml", "xsl" => "text/xml", "bmp" => "image/bmp", "txt" => "text/plain",
          "rb" => "text/plain", "pas" => "text/plain", "tcl" => "text/plain", "java" => "text/plain",
          "c" => "text/plain", "h" => "text/plain", "cpp" => "text/plain", "xul" => "application/vnd.mozilla.xul+xml",
          "php" => "text/html", "asp" => "text/html","avi" => "video/x-msvideo", "rmvb" => "video/x-msvideo"
        }
        def mime(string)
          MIME[string.split(/\./).last] || "data-octet-stream"
        end
      end
      class StreamPart
        def initialize( stream, size )
          @stream, @size = stream, size
        end
        def size
          @size
        end
        def read ( offset, how_much )
          @stream.read( how_much )
        end
      end
      # => http发送数据的一个部分,主要用read方法来读取其内容发送
      class StringPart
        def initialize ( str )
          @str = str
        end
        def size
          @str.length
        end
        def read ( offset, how_much )
          @str[offset, how_much]
        end
      end
      class MultipartStream
        def initialize( parts )
          @parts = parts
          @part_no = 0;
          @part_offset = 0;
        end
        def size
          total = 0
          @parts.each do |part|
            total += part.size
          end
          total
        end
        def read ( how_much )
          if @part_no >= @parts.size
            return nil;
          end
          how_much_current_part = @parts[@part_no].size - @part_offset
          how_much_current_part = if how_much_current_part > how_much
            how_much
          else
            how_much_current_part
          end
          how_much_next_part = how_much - how_much_current_part
          current_part = @parts[@part_no].read(@part_offset, how_much_current_part )
          if how_much_next_part > 0
            @part_no += 1
            @part_offset = 0
            next_part = read( how_much_next_part  )
            current_part + if next_part
              next_part
            else
              ''
            end
          else
            @part_offset += how_much_current_part
            current_part
          end
        end
      end
      # => 上传文件到服务器上,用了http类
      def upload_to_server(dest_file,local_file,host,port,checkpoint)
        url = "http://#{host}:#{port}#{dest_file}"
        client=Multipart.new(:photo=>local_file)
        begin
          ret = client.post(url,'username','password')
        rescue Exception => err
          ATT::KeyLog.error("这里出现了发送数据的时候的错误,有可能是发送的时候被拦截了", err)
          return_fail
        end
        if(checkpoint != "" and not ret.body.include?(checkpoint))
          ATT::KeyLog.error("这返BODY内容不包含检查点::#{checkpoint}")
          return_fail
        end
        return_ok
      end
      
      
      def pipeline_request(hash)
        
        hash.each() do |key, value|
          value.gsub!("CR", "\r")
          value.gsub!("LF", "\n")
        end
        
        begin
          socket = TCPSocket.new(hash[:host],hash[:port])
          pipe_request = ""
          pipe_request << hash[:url_1] + CRLF
          pipe_request << hash[:head_1] + CRLF
          pipe_request << hash[:url_2] + CRLF   if hash[:url_2] != nil and hash[:url_2] != ""
          pipe_request << hash[:head_2] + CRLF  if hash[:head_2] != nil and hash[:head_2] != ""
          pipe_request << hash[:url_3] + CRLF   if hash[:url_3] != nil and hash[:url_3] != ""
          pipe_request << hash[:head_3] + CRLF  if hash[:head_3] != nil and hash[:head_3] != ""
          pipe_request << hash[:url_4] + CRLF   if hash[:url_4] != nil and hash[:url_4] != ""
          pipe_request << hash[:head_4] + CRLF  if hash[:head_4] != nil and hash[:head_4] != ""
          pipe_request << hash[:url_5] + CRLF   if hash[:url_5] != nil and hash[:url_5] != ""
          pipe_request << hash[:head_5] + CRLF  if hash[:head_5] != nil and hash[:head_5] != ""
          pipe_request << hash[:url_6] + CRLF   if hash[:url_6] != nil and hash[:url_6] != ""
          pipe_request << hash[:head_6] + CRLF  if hash[:head_6] != nil and hash[:head_6] != ""
          pipe_request << hash[:url_7] + CRLF   if hash[:url_7] != nil and hash[:url_7] != ""
          pipe_request << hash[:head_7] + CRLF  if hash[:head_7] != nil and hash[:head_7] != ""
          pipe_request << hash[:url_8] + CRLF   if hash[:url_8] != nil and hash[:url_8] != ""
          pipe_request << hash[:head_8] + CRLF  if hash[:head_8] != nil and hash[:head_8] != ""
          pipe_request << hash[:add_all] + CRLF  if hash[:add_all] != nil and hash[:add_all] != ""
          socket.send(pipe_request,0)
          socket.flush
        end
      rescue => err
        puts err.to_s
        ATT::KeyLog.error("这里出现了发送数据的时候的错误,有可能是发送的时候被拦截了", err)
      else
        str_ret = ""
        hash[:get_times].to_i.times { str_ret << socket.readpartial(1024000) rescue nil  }
        ATT::KeyLog.info("获得的服务器返回数据1是::==================\n#{str_ret}")
        if (hash[:checkpoint] != nil and hash[:checkpoint] != "")
          hash[:checkpoint].each("&;&") do |check_point_str|
            check_point_str_arr = check_point_str.split("@;@")
            if check_point_str_arr.size == 2
              count = 0 
              str_ret.each_line("\n") { |substr|
                count += 1 if substr.include?(check_point_str_arr[1])
              }
              return_fail if count < check_point_str_arr[0].to_i
            else
              return_fail if not str_ret.include?(check_point_str)
            end
            return_ok
          end
        end
        return_ok
      ensure
        socket.flush
        socket.close if socket != nil and socket.closed? != true
      end
    end
  end
end
