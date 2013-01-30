# coding: utf8
=begin rdoc
作用: 测试http请求
维护记录:
维护人       时间                  行为
[包亮]     2012-10-22                     创建
=end

module LocalPc

  module NetworkAccess


=begin rdoc
类名: All_HTTP
描述: http请求测试
=end
    class HttpQuest < ATT::Base

=begin rdoc
关键字名: HTTP协议请求
描述: 发送http协议
参数:
id=>address,name=>服务器IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"服务器的IP地址"
id=>port,name=>端口号,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器IP端口号"
id=>method,name=>方法,type=>s,must=>false,default=>"GET",value=>"{text}",descrip=>"请求方法（GET、POST、HEAD....）"
id=>host,name=>主机host,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"请求主机头host"
id=>type,name=>content_type内容,type=>s,must=>false,default=>"text/html",value=>"{text}",descrip=>"content_type"
id=>request,name=>请求url,type=>s,must=>true,default=>"/",value=>"{text}",descrip=>"请求的url "
id=>http_version,name=>http版本,type=>s.must=>false,default=>"HTTP/1.1",value=>"{text}",descrip=>"http请求的版本 "
id=>accept,name=>头部Accept,type=>s,must=>false,default=>"text/html, application/html+xml, */*",value=>"{text}",descrip=>"请求头部Accept"
id=>accept_encoding,name=>头部Accept_Encoding,type=>s,must=>false,default=>"gzip, deflate",value=>"{text}",descrip=>"请求头部Accept_Encoding"
id=>accept_language,name=>头部Accept_Language,type=>s,must=>false,default=>"zh-CN",value=>"{text}",descrip=>"头部Accept_Language"
id=>cookie,name=>cookie,type=>s,must=>false,default=>"cookie",value=>"{text}",descrip=>"cookie头"
id=>cookie_value,name=>cookie值,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"cookie内容"
id=>referer,name=>referer头部,type=>s,must=>false,default=>"Referer",value=>"{text}",descrip=>"referer头"
id=>referer_value,name=>referer值,type=>s,must=>false,default=>"http://www.test.com",value=>"{text}",descrip=>"referer内容"
id=>connection,name=>头部Connetcion,type=>s,must=>false,default=>"Keep-Alive",value=>"{text}",descrip=>"请求头部Connetcion"
id=>agent,name=>头部User-Agent,type=>s,must=>false,default=>"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)",value=>"{text}",descrip=>"请求头部User-Agent"
id=>other,name=>其他字段,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"其他自定义头部字段ex cookie:test"
id=>content,name=>正文body内容,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"请求的正文body内容"
id=>speciall_crlf,name=>头部换行方式,type=>s,must=>false,default=>"CRLF",value=>"{text}",descrip=>"头部的换行方式,默认是CRLF,也就是回车换行符,CR=\r LF=\n"
id=>check_header,name=>头部包含内容检查点,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"头部包含内容检查点,就是返回的头部中是否包含对应字符串"
id=>check_body,name=>body包含内容检查点,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"body包含内容检查点,就是返回的头部中是否包含对应字符串"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|访问失败",descrip=>""
=end    
      def http_request(hash)
        headers=""
        url = hash[:request].sub("CR","\r")
        url = url.sub("LF","\n")
        the_speciall_crlf = (hash[:speciall_crlf].gsub(/CR/,"\r")).gsub(/LF/,"\n") 
        the_speciall_crlf = "\r\n" if the_speciall_crlf == nil || the_speciall_crlf == "" 
        request =""
        request += "#{hash[:method]} #{url} #{hash[:http_version]}" + the_speciall_crlf
        request += "Accept: #{hash[:accept]}" + the_speciall_crlf if hash[:accept] != ""
        request += "Host: #{hash[:host]}" + the_speciall_crlf if hash[:host] != ""
        request += "Content-type:#{hash[:type]}" + the_speciall_crlf if hash[:type] != ""
        request += "Accept-Language: #{hash[:accept_language]}" + the_speciall_crlf if hash[:accept_language] != ""
        request += "User-Agent: #{hash[:agent]}" + the_speciall_crlf if hash[:agent] != ""
        request += "Accept-Encoding:#{hash[:accept_encoding]}" + the_speciall_crlf if hash[:accept_encoding] != ""
        request += "#{hash[:referer]}: #{hash[:referer_value]}" + the_speciall_crlf if hash[:referer_value] != ""
        request += "Connection: #{hash[:connection]}" + the_speciall_crlf if hash[:referer_value] != ""
        request += "#{hash[:cookie]}: #{hash[:cookie_value]}" + the_speciall_crlf if hash[:cookie].gsub(/\s/, "") != "" && hash[:cookie_value].gsub(/\s/, "") != ""
        request += "Content-Length:#{hash[:content].length}" + the_speciall_crlf if hash[:content] != ""
        if(hash[:other]!="")
          other = hash[:other].gsub(/CR/,"\r")
          other = other.gsub(/LF/,"\n")
          request += "#{other}\r\n"
        end
        request += "\r\n"
        request += "#{hash[:content]}" if hash[:content] != ""
        ATT::KeyLog.info("\n====================\n请求头部内容：\n#{request}\n==============================")
        # puts request.dump
        begin
          socket = TCPSocket.open(hash[:address],hash[:port])
        rescue
          ATT::KeyLog.info("error: #{$!}")
          return_fail("访问失败")
        else
          begin
            socket.print(request)
            socket.flush
            headers=socket.gets("\r\n\r\n")
          rescue => err
            error = err.to_s
            ATT::KeyLog.info("error message is #{error}")
            return_fail
          end
          ATT::KeyLog.info("\n====================\n响应头部内容：\n#{headers}\n==============================")
          if (hash[:check_header] != "" )
            if headers.include?(hash[:check_header])
              return_ok
            else
              return_fail
            end
          end
          if (hash[:check_body] != "" )
            begin
              bodys = socket.readpartial(102400)
            rescue => err
              error = err.to_s
              ATT::KeyLog.error("获得不到body部分")
              ATT::KeyLog.error("error message is #{error}")
              return_fail
            end
            ATT::KeyLog.info("\n====================\n响应 body 内容：\n#{bodys}\n==============================")
            if bodys.include?(hash[:check_body])
              return_ok
            else
              return_fail
            end
          end
          return_ok        
          socket.close
        end
      end
=begin rdoc
关键字名: 明文登录
描述: 明文方式发送用户名和密码
参数:
id=>address,name=>服务器IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"服务器的IP地址"
id=>port,name=>端口号,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器IP端口号"
id=>plain_host,name=>HOST主机,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"主机的HOST"
id=>method,name=>方法,type=>s,must=>false,default=>"GET",value=>"{text}",descrip=>"请求方法（GET、POST、HEAD....）"
id=>url,name=>请求的url,type=>s,must=>true,default=>"/",value=>"{text}",descrip=>"请求的url，在这个url输入要登录的用户名和密码字段"
id=>content_type,name=>请求方法,type=>s,must=>false,default=>"application/x-www-form-urlencoded",value=>"{text}",descrip=>"请求的content-type内容"
id=>post_content,name=>请求内容,type=>s,must=>false,default=>"username=baoliang&password=baoliang",value=>"{text}",descrip=>"请求的content"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end  

      def plain_login(hash)
        begin
          if(hash[:method]=="POST" or hash[:method]=="post")
            request = "POST #{hash[:url]} HTTP/1.1\r\nHost:#{hash[:plain_host]}\r\nConetnt-type:#{hash[:content_type]}\r\n\r\n#{hash[:post_content]}\r\n"
            socket = TCPSocket.open(hash[:address],hash[:port])
            socket.print(request)
            socket.flush
            headers=socket.gets("\r\n\r\n")
            socket.close
          else
            request = "#{hash[:method]} #{hash[:url]} HTTP/1.1\r\nHost:#{hash[:plain_host]}\r\n\r\n"
            socket = TCPSocket.open(hash[:address],hash[:port])
            socket.print(request)
            socket.flush
            headers=socket.gets("\r\n\r\n")
            socket.close
          end
        rescue Exception => e
          ATT::KeyLog.error("出错了,出错的堆栈是::#{e.backtrace}")
          return_fail
        else
          return_ok
        end
      end

=begin rdoc
关键字名: 主动学习学习次数
描述: 构造主动学习的学习素材。
维护人: baoliang
参数:
# id=>英文名,name=>中文名,type=>s(tring)|a(array)|i(nt),h(ash),must=>true|false,default=>"",value=>"{text}",descrip=>"这是一个例子"
id=>number,name=>学习次数,type=>i,must=>true,default=>"1",value=>"{text}",descrip=>"学习次数"
id=>url,name=>请求的url,type=>s,must=>true,default=>"/index.asp?",value=>"{text}",descrip=>"请求的url,该url必须可以访问"
id=>para_name,name=>参数名称,type=>s,must=>true,default=>"para_1",value=>"{text}",descrip=>"参数名称"
id=>para_value,name=>参数值,type=>s,must=>true,default=>"012345679",value=>"{text}",descrip=>"参数值"
id=>host,name=>请求主机,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"主机Ip"
id=>port,name=>请求端口,type=>s,must=>true,default=>"80",value=>"{text}",descrip=>"主机端口"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def learn(hash)
        begin
          hash[:number].times do 
            Net::HTTP.start(hash[:host]) do |http|
              url_string="#{hash[:url]}#{hash[:para_name]}=#{hash[:para_value]}"
              url=URI.encode(url_string)
              response = http.get(url)
            end
          end
        rescue => err
          ATT::KeyLog.info(err.to_s)
          return_fail
        end
        ATT::KeyLog.info("okkkkkk")
        return_ok
      end

      #end of class HttpQuest
    end
    #don't add any code after here.

  end

end
