# coding: utf8
=begin rdoc
作用: 封装执行主机上HTTP网络访问的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-09              创建
=end
require 'watir'
require 'socket'
require 'net/http'

module LocalPc

  module NetworkAccess


=begin rdoc
类名: HTTP
描述: HTTP访问
=end
    class Http < ATT::Base

=begin rdoc
关键字名: 访问HTTP服务
描述: 访问HTTP网站
参数:
id=>address,name=>地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要访问的http地址,如'www.baidu.com'"
id=>checkpoint,name=>检查点,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"是否成功访问的检查点,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def access_http_web_site(hash)
        AF::MyBrowser.close_browsers # 关闭所有的浏览器窗口
        url = (hash[:address] =~ /http:\/\// ? hash[:address] : "http://#{hash[:address]}")
        ATT::KeyLog.info("要访问的地址: #{url}")
        begin
          rc_browser = Watir::IE.new # 创建浏览器可能会失败
        rescue Exception
          ATT::KeyLog.debug("发生异常:#{$!.class},稍后重新打开浏览器...")
          sleep 5
          retry
        end
        rc_browser.goto(url)
        checkpoint_array = hash[:checkpoint].split("&")
        checkpoint_array.each do |checkpoint|
          if rc_browser.contains_text("#{checkpoint}") || rc_browser.html.match("#{checkpoint}")
            ATT::KeyLog.error("检查点#{checkpoint}存在...")
          else
            0.times do
              ATT::KeyLog.debug("检查点不存在,刷新后重新检查...")
              sleep 2
              rc_browser.goto(url) # rc_browser.send_keys("{F5}")
              sleep 2
              all_text = rc_browser.html
              ATT::KeyLog.debug("资源页面上的文本:#{all_text}")
              if all_text.include?("#{hash[:checkpoint]}")
                ATT::KeyLog.error("检查点#{checkpoint}存在...")
              end
            end
            ATT::KeyLog.error("检查点#{checkpoint}不存在...")# 刷新2次后,仍错误
            return_fail
          end
        end
        return_ok
      end

=begin rdoc
关键字名: 登录天涯社区
描述: 登录天涯社区网站
参数:
id=>address,name=>地址,type=>s,must=>false,default=>"http://www.tianya.cn",value=>"{text}",descrip=>"天涯社区地址"
id=>user,name=>用户名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"登录用户名"
id=>passwd,name=>密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"登录用户的密码"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|访问失败",descrip=>""
=end
      def login_tianya_web_site(hash)
        AF::MyBrowser.close_browsers # 关闭所有的浏览器窗口
        url = (hash[:address] =~ /http:\/\// ? hash[:address] : "http://#{hash[:address]}")
        browser = Watir::IE.my_new
        begin
          browser.goto(url)
          browser.refresh
          browser.wait
          browser.maximize
        rescue Exception
          ATT::KeyLog.error("发生异常:#{$!.class},#{$!.message}")
          retry
        end
        unless browser.form(:id, TIANYA_LOGIN_FORM).exists?
          ATT::KeyLog.info("访问地址#{url}失败,页面上的文本:#{browser.html}")
          return_fail("访问失败")
        end
        browser.form(:id, TIANYA_LOGIN_FORM).text_field(:id, TIANYA_USER_ID).set(hash[:user]) # 输入用户名
        browser.form(:id, TIANYA_LOGIN_FORM).text_field(:id, TIANYA_PASSWD_ID).set(hash[:passwd]) # 输入密码
        browser.form(:id, TIANYA_LOGIN_FORM).checkbox(:id, TIANYA_RMFLAN_ID).clear # 不自动登录
        browser.form(:id, TIANYA_LOGIN_FORM).button(:id, TIANYA_BUTTON_ID).click # 登录
        if browser.div(:id, TIANYA_TOP_DIV_ID).link(:id, TIANYA_LOGOUT_LINK).exists?
          ATT::KeyLog.info("已登录天涯社区成功")
          return_ok
        else
          ATT::KeyLog.info("登录天涯社区失败,当前页面的文本是:\n#{browser.html}")
          return_fail
        end
      end
     
=begin rdoc
关键字名: HTTP方法请求
描述: HTTP发送GET、POST、HEAD等方法请求
参数:
id=>address,name=>服务器IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"服务器的IP地址"
id=>port,name=>端口号,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器IP端口号"
id=>method,name=>方法,type=>s,must=>false,default=>"GET",value=>"{text}",descrip=>"请求方法（GET、POST、HEAD....）"
id=>request,name=>请求头部,type=>s,must=>false,default=>"/ HTTP/1.1CRLF",value=>"{text}",descrip=>"请求头部,CR代表\r，LF代表\n"
id=>accept,name=>头部Accept,type=>s,must=>false,default=>"text/html, application/xhtml+xml, */*",value=>"{text}",descrip=>"请求头部Accept"
id=>accept_encoding,name=>头部Accept_Encoding,type=>s,must=>false,default=>"gzip, deflate",value=>"{text}",descrip=>"请求头部Accept_Encoding"
id=>accept_language,name=>头部Accept_Language,type=>s,must=>false,default=>"zh-CN",value=>"{text}",descrip=>"头部Accept_Language"
id=>connection,name=>头部Connetcion,type=>s,must=>false,default=>"Keep-Alive",value=>"{text}",descrip=>"请求头部Connetcion"
id=>agent,name=>头部User-Agent,type=>s,must=>false,default=>"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)",value=>"{text}",descrip=>"请求头部User-Agent"
id=>cookie,name=>头部Cookie,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"请求头部cookie"
id=>other,name=>其他字段,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"其他自定义头部字段"
id=>content,name=>正文内容,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"请求的正文内容"
id=>checkpoint,name=>响应信息检查点,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"响应信息检查点"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|访问失败",descrip=>""
=end    
      def http_request(hash)
        headers=""
        request=hash[:request].sub(/CR/,"\r")
        request=request.sub(/LF/,"\n")
        if(hash[:other]=="")
          request = "#{hash[:method]} #{request}Accept: #{hash[:accept]}\r\nAccept-Language: #{hash[:accept_language]}\r\nUser-Agent: #{hash[:agent]}\r\nAccept-Encoding:#{hash[:accept_encoding]}\r\nHost: #{hash[:address]}\r\nConnection: #{hash[:connection]}\r\nCookie: #{hash[:cookie]}\r\n\r\n#{hash[:content]}"
        else
          request = "#{hash[:method]} #{request}Accept: #{hash[:accept]}\r\nAccept-Language: #{hash[:accept_language]}\r\nUser-Agent: #{hash[:agent]}\r\nAccept-Encoding:#{hash[:accept_encoding]}\r\nHost: #{hash[:address]}\r\nConnection: #{hash[:connection]}\r\nCookie: #{hash[:cookie]}\r\n#{hash[:other]}\r\n\r\n#{hash[:content]}"
        end
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
            headers=socket.gets("\r\n\r\n")
          rescue Exception => e
            ATT::KeyLog.info("error: #{$!}"+"\n堆栈：\n#{e.backtrace}")
            return_fail
          end
          socket.close
        end
        if(hash[:checkpoint]=="")
          if headers.include?("200")
            ATT::KeyLog.info("\n====================\n成功的响应头部内容：\n#{headers}\n ==============================\n")
            return_ok
          else
            ATT::KeyLog.info("\n====================\n失败的响应头部内容：\n#{headers}\n ==============================\n")
            return_fail
          end
        else
          ATT::KeyLog.info("正在执行响应信息检查点：#{hash[:checkpoint]}")
          ATT::KeyLog.info("\n=========\n隐藏的响应头部内容:\n#{headers}\n====================")
          if headers.include?(hash[:checkpoint])&&headers.include?("200")
            ATT::KeyLog.info("响应信息检查点成功")
            return_ok
          else
            ATT::KeyLog.info("响应信息检查点失败")
            return_fail
          end
        end
      end

=begin rdoc
关键字名: 协议异常请求
描述: 以HTTP的方式Get请求以获取协议异常
参数:
id=>address,name=>服务器IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"服务器的IP地址"
id=>port,name=>端口号,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器IP端口号"
id=>dest_url,name=>根目录路径,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"相对网址根目录的路径"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|访问失败",descrip=>""
=end
      def protocol_exception(hash)
        header_hash = {"Host" => "#{hash[:address]}","Accept" => "*/*","Accept-Language" => "en","Content-Length" => "1",
          "Cookie" => "id=xxxxxxxxxxxxx","User-Agent" => "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)",
          "Connection" => "close"}
        response = nil
        begin
          http = Net::HTTP.new("#{hash[:address]}","#{hash[:port]}")
        rescue Exception
          ATT::KeyLog.info("错误："+$!.to_s.to_utf8)
          return_fail("访问失败")
        end
        begin
          http = Net::HTTP.new("#{hash[:address]}","#{hash[:port]}")
          get = Net::HTTP::Get.new("#{hash[:dest_url]}?id=1", header_hash)
          response = http.request(get,"aaaa")
        rescue Exception => e
          ATT::KeyLog.info("error: #{$!}"+"\n堆栈：\n#{e.backtrace}")
          return_fail
        end
        ATT::KeyLog.info("===================请求头部==============")
        header_hash.each do |i,j|
          ATT::KeyLog.info("#{i} => #{j}")
        end
        puts "响应返回信息"
        ATT::KeyLog.info("==================响应头部===============")
        ATT::KeyLog.info("#{response.code}")
        response.each do |k, v|
          ATT::KeyLog.info("#{k} => #{v}")
        end
        ATT::KeyLog.info("==========================================")
        if(response.code.to_s=="200")
          return_ok
        else
          return_fail
        end
      end
=begin rdoc
关键字名: URL请求
描述: 非网页版的url请求
参数:
id=>host,name=>服务器IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"服务器的IP地址"
id=>dest_url,name=>根目录路径,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"相对网址根目录的路径"
id=>port,name=>端口号,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器端口号"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|访问失败",descrip=>""
=end
      def url_request(hash)
        host="#{hash[:host]}"
        port="#{hash[:port]}"
        dest_url="#{hash[:dest_url]}"
        dest_whole_url = "http://#{host}:#{port}#{dest_url}"
        ATT::KeyLog.info("要访问的网页url = #{dest_whole_url}")
        response = nil
        begin
          Net::HTTP.start(host, port)
        rescue Exceptin
          ATT::KeyLog.info("错误："+$!.to_s.to_utf8)
          return_fail("访问失败")
        end
        begin
          Net::HTTP.start(host, port) do |http|
            response = http.get(dest_url)
          end
        rescue Exception => e
          ATT::KeyLog.info("错误："+$!.to_s.to_utf8 + "\n堆栈：\n#{e.backtrace}")
          return_fail
        end
        ATT::KeyLog.info("http服务器的响应码是#{response.code}")
        ATT::KeyLog.info("http服务器的响应消息是#{response.message}")
        case response.code.to_s
        when "200"
          ATT::KeyLog.info("访问网页#{dest_whole_url}成功!")
          return_ok
        else
          ATT::KeyLog.info("访问网页#{dest_whole_url}失败!")
          return_fail
        end
      end
=begin rdoc
关键字名: POST数据
描述: 没有自定义头部的POST
参数:
id=>host,name=>服务器IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"请求访问的服务器IP"
id=>dest_url,name=>根目录路径,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"相对网址根目录的路径"
id=>port,name=>端口号,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器端口号"
id=>form,name=>POST数据,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"POST数据"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|访问失败",descrip=>""
=end
      def http_post_date(hash)
        host="#{hash[:host]}"
        port="#{hash[:port]}"
        dest_url="#{hash[:dest_url]}"
        form="#{hash[:form]}"
        dest_whole_url = "http://#{host}:#{port}#{dest_url}"
        ATT::KeyLog.info("要POST的url = #{dest_whole_url}")
        response = nil
        begin
          Net::HTTP.start(host, port)
        rescue Exception => e
          ATT::KeyLog.info("错误："+$!.to_s.to_utf8+ + "\n堆栈：\n#{e.backtrace}")
          return_fail("访问失败")
        end
        begin
          Net::HTTP.start(host, port) do |http|
            response = http.post(dest_url, form)
          end
        rescue Exception => e
          ATT::KeyLog.info("错误："+$!.to_s.to_utf8 + "\n堆栈：\n#{e.backtrace}")
          return_fail
        end
        ATT::KeyLog.info("http服务器的响应码是#{response.code}")
        ATT::KeyLog.info("http服务器的响应消息是#{response.message}")
        case response.code.to_s
        when "200"
          return_ok
        else
          return_fail
        end
      end
=begin rdoc
关键字名: HTTP爆破登录
描述: HTTP爆破登录
参数:
id=>host,name=>服务器IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"请求访问的服务器IP"
id=>dest_url,name=>根目录路径,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"相对网址根目录的路径"
id=>port,name=>端口号,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器端口号"
id=>form,name=>POST数据,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"POST数据"
id=>times,name=>循环次数,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"暴力破解次数"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|访问失败",descrip=>""
=end
      def http_force_login(hash)
        host="#{hash[:host]}"
        port="#{hash[:port]}"
        dest_url="#{hash[:dest_url]}"
        form="#{hash[:form]}"
        times="#{hash[:times]}.".to_i
        dest_whole_url = "http://#{host}:#{port}#{dest_url}"
        ATT::KeyLog.info("要HTTP爆破登录网页url = #{dest_whole_url},次数为：#{times}")
        response = nil
        success = 0
        begin
          Net::HTTP.start(host, port)
        rescue Exception
          ATT::KeyLog.info("错误："+$!.to_s.to_utf8)
          return_fail("访问失败")
        end
        while times !=0
          begin
            Net::HTTP.start(host, port) do |http|
              ATT::KeyLog.info("当前正在进行第#{hash[:times].to_i-times+1}次爆破登录")
              response = http.post(dest_url, form)
            end
          rescue Exception
            ATT::KeyLog.info("错误："+$!.to_s.to_utf8)
            return_fail
          end
          ATT::KeyLog.info("http服务器的响应码是#{response.code}")
          ATT::KeyLog.info("http服务器的响应消息是#{response.message}")
          case response.code.to_s
          when "200"
            success += 1
          else
            return_fail
          end
          times -= 1
        end
        if (success == hash[:times].to_i)
          return_ok
        end
      end

=begin rdoc
关键字名: HTTP下载文件
描述: 通过HTTP下载文件
参数:
id=>host,name=>服务器IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"服务器的IP地址"
id=>port,name=>端口号,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器端口号"
id=>dest_file,name=>服务器下载路径,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"要从http服务器上下载的文件,是相对网址根目录的路径,如要下载'http://ip:port/path/file.rar',其值是'/path/file.rar',可以有中文"
id=>local_path,name=>本地保存目录,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"本地保存目录,如'D:\\' 或 'D:/'"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|访问失败",descrip=>"服务器完全不可访问则会返回访问失败,访问被拦截则会失败"
=end
      def http_download(hash)
        return_fail("访问失败") if not ATT::Http.available?(hash[:host], hash[:port].to_i)
        ( FileUtils.mkdir_p(hash[:local_path]) rescue nil ) if not File.directory?(hash[:local_path])
        begin
          ATT::Http.download(hash[:dest_file], hash[:local_path], hash[:host], hash[:port])
        rescue Exception => e
          ATT::KeyLog.error("出错了,出错的堆栈是::#{e.backtrace}")
          return_fail
        end
        return_ok
      end

=begin rdoc
关键字名: HTTP上传文件
描述: 通过HTTP上传文件(文件上传不能过大,在10M内的文本文件就好)
参数:
id=>host,name=>服务器IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"服务器的IP地址"
id=>port,name=>端口号,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器端口号"
id=>dest_file,name=>服务器上传路径,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"要从http服务器上传的路径,是相对网址根目录的路径,如要'http://ip:port/path/file.rar',其值是'/path/file.rar',可以有中文"
id=>local_path,name=>本地文件路径,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"本地文件路径,如'D:\\File' 或 'D:/file'"
id=>checkpoint,name=>返回数据检查点,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"对于服务器返回的页面内容进行检查,不对HTTP头检查"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|访问失败",descrip=>"如果服务器完全不能通,则会返回访问失败,能访问通,并且上传被拦截则返回失败"
=end
      def http_upload(hash)
        return_fail("访问失败") if not ATT::Http.available?(hash[:host], hash[:port].to_i)
        upload_to_server(hash[:dest_file], hash[:local_path], hash[:host], hash[:port], hash[:checkpoint])
      end
      
=begin rdoc
关键字名: pipeline请求
描述: http的pipeline方式请求
参数:
id=>host,name=>服务器IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"服务器的IP地址"
id=>port,name=>端口号,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"服务器端口号"
id=>url_1,name=>请求1,type=>s,must=>false,default=>"GET / HTTP/1.1",value=>"{text}",descrip=>"pipeline的第一个从http服务器访问的请求,就是请求的第一行,格式为: GET / HTTP/1.1首行会自动添加一个回车换行符"
id=>head_1,name=>请求头1,type=>s,must=>false,default=>"HOST: test.comCRLF",value=>"{text}",descrip=>"pipeline的第一个请求头,第二行起的头部内容,CR自动替换\r,LF自动替换\N,最后会自动补充一个CRLF(\r\n)"
id=>url_2,name=>请求2,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第二个从http服务器访问的请求,就是请求的第一行,格式为: GET / HTTP/1.1"
id=>head_2,name=>请求头2,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第二个请求头,第二行起的头部内容,CR自动替换\r,LF自动替换\N,最后会自动补充一个CRLF(\r\n)"
id=>url_3,name=>请求3,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第三个从http服务器访问的请求,就是请求的第一行,格式为: GET / HTTP/1.1"
id=>head_3,name=>请求头3,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第三个请求头,第二行起的头部内容,CR自动替换\r,LF自动替换\N,最后会自动补充一个CRLF(\r\n)"
id=>url_4,name=>请求4,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第四个从http服务器访问的请求,就是请求的第一行,格式为: GET / HTTP/1.1"
id=>head_4,name=>请求头4,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第四个请求头,第二行起的头部内容,CR自动替换\r,LF自动替换\N,最后会自动补充一个CRLF(\r\n)"
id=>url_5,name=>请求5,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第五个从http服务器访问的请求,就是请求的第一行,格式为: GET / HTTP/1.1"
id=>head_5,name=>请求头5,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第五个请求头,第二行起的头部内容,CR自动替换\r,LF自动替换\N,最后会自动补充一个CRLF(\r\n)"
id=>url_6,name=>请求6,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第六个从http服务器访问的请求,就是请求的第一行,格式为: GET / HTTP/1.1"
id=>head_6,name=>请求头6,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第六个请求头,第二行起的头部内容,CR自动替换\r,LF自动替换\N,最后会自动补充一个CRLF(\r\n)"
id=>url_7,name=>请求7,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第七个从http服务器访问的请求,就是请求的第一行,格式为: GET / HTTP/1.1"
id=>head_7,name=>请求头7,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第七个请求头,第二行起的头部内容,CR自动替换\r,LF自动替换\N,最后会自动补充一个CRLF(\r\n)"
id=>url_8,name=>请求8,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第八个从http服务器访问的请求,就是请求的第一行,格式为: GET / HTTP/1.1"
id=>head_8,name=>请求头8,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"pipeline的第八个请求头,第二行起的头部内容,CR自动替换\r,LF自动替换\N,最后会自动补充一个CRLF(\r\n)"
id=>add_all,name=>最后补充请求的数据,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"最后补充的头部,CR自动替换\r,LF自动替换\N,最后会自动补充一个CRLF(\r\n)"
id=>checkpoint,name=>返回数据检查点,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"对于所有回包数据的检查,每个检查点用&;&号隔开,其中检查出现次数"
id=>get_times,name=>获取数据次数,type=>s,must=>false,default=>"2",value=>"{text}",descrip=>"需要获取数据的次数(一般根据请求的pipeline次数)"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|访问失败",descrip=>"如果服务器完全不能通,则会返回访问失败,能访问通,并且上传被拦截则返回失败"
=end
      def http_pepeline(hash)
        return_fail("访问失败") if not ATT::Http.available?(hash[:host], hash[:port].to_i)
        pipeline_request(hash)
      end
    end
  end
end
