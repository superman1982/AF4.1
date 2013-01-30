# coding: utf8
=begin rdoc
作用: 启动一个HTTP服务器
维护记录:
维护人      时间                  行为
[王沃伦]     2012-08-30                     创建
=end
require 'lib/servers/http_server'
module LocalPc

  module NetworkServer


=begin rdoc
类名: HTTP服务器
描述: 一个简单的支持文件上传下载的HTTP服务器
=end
    class HttpServer < ATT::Base

=begin rdoc
关键字名: 启动HTTP服务器
描述: 启动这个HTTP服务器
维护人: 王沃伦
参数:
id=>root_dir,name=>服务器根目录,type=>s,must=>false,default=>"./",value=>"{text}",descrip=>"这个HTTP服务器的访问文件的根目录,需要全路径或相对路径都可以,要用linux的路径分隔符'/',路径需要在关键字执行前准备好,建议用新建文件关键字建立对应路径"
id=>port,name=>端口,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"这个HTTP服务器监听的端口"
id=>http_edition,name=>HTTP版本.type=>s,must=>false,default=>"1.1",value=>"1.1|1.0",descrip=>"服务器的HTTP版本"
id=>respone_code,name=>状态码.type=>s,must=>false,default=>"200",value=>"{text}",descrip=>"回包时的http状态码,想要获得头部回包的一些特殊字段,需要在访问的时候URL里带着一个'special_head_respone'字段才能获得特殊头部,不管这个字段放在URL的那里,但是必须是在访问的URL"
id=>respone_head_cookie,name=>头部cookie.type=>s,must=>false,default=>"",value=>"{text}",descrip=>"回包时关注的set-cookie，输入格式以个数加值：‘11:abcdefg"
id=>respone_head,name=>头部字段.type=>s,must=>false,default=>"",value=>"{text}",descrip=>"回包时关注的头部字段（自定义字段名和字段值）,用'&;&'号分隔每个头部字段,每个字段格式如:'cookie:test=1'"
id=>user_define_head,name=>特殊头部字段.type=>s,must=>false,default=>"",value=>"{text}",descrip=>"特殊回包头部字段,用CR代表\r用LF代表\n,直接贴到头部回复字段的最后"
id=>user_define_respone,name=>回包内容.type=>s,must=>false,default=>"",value=>"{text}",descrip=>"回包时关注的回包内容,,用CR代表\r用LF代表\n"
id=>is_ssl,name=>是否启用ssl,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"服务器是否启用https"
id=>root_cert_1,name=>根证书数据内容,type=>s,must=>false,default=>"1024$:$3$:$RSA$:$Sangfor_root_ca",value=>"{text}",descrip=>"根证书的数据,格式为: 秘钥长度 $:$ 证书版本 $:$ 加密算法(可接受DSA,RSA,DH,EC,Pkey) $:$ 签证名称"
id=>root_cert_2,name=>签证证书数据内容,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"签证证书的数据,此证书是根证书签证的用来给实际证书签证的,留空则用根证书直接签证网站证书,格式为: 秘钥长度 $:$ 证书版本 $:$ 加密算法(可接受DSA,RSA,DH,EC,Pkey) $:$ 签证名称"
id=>child_cert,name=>网站证书数据内容,type=>s,must=>false,default=>"1024$:$3$:$RSA$:$Sangfor_child_ca",value=>"{text}",descrip=>"网站证书的数据,格式为: 秘钥长度 $:$ 证书版本 $:$ 加密算法(可接受DSA,RSA,DH,EC,Pkey) $:$ 签证名称"
id=>run_time,name=>服务器运行时间,type=>s,must=>false,default=>"永远",value=>"{text}",descrip=>"想要运行服务器的时间,默认是'永远',可输入对应的数字,单位为10秒,比如输入10,则是100秒,在同一个ruby虚拟机内只有一个此服务器运行,后运行的会主动把前面运行的全部服务器干掉"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|下载失败",descrip=>"端口被占用会引发失败"
=end
      def startup_service(hash={})
        GC.start # => 尽量避免内存泄露使ruby虚拟机崩溃
        start_server_hash = {}
        if hash[:run_time] == "永远"
          start_server_hash[:server_runtime] = true
        else
          start_server_hash[:server_runtime] = hash[:run_time].to_i
        end
        start_server_hash[:port] = hash[:port].to_i
        start_server_hash[:timeout] = SERVER_TIMEOUT
        start_server_hash[:cadence] = SERVER_CADENCE
        start_server_hash[:root_dir] = hash[:root_dir]
        start_server_hash[:http_edition] = hash[:http_edition]
        start_server_hash[:respone_code] = hash[:respone_code]
        start_server_hash[:respone_head] = {}
        start_server_hash[:respone_head]["set-cookie"] = hash[:respone_head_cookie].split(":") if hash[:respone_head_cookie].gsub(/\s/,"") != ""
        get_http_respone_head(start_server_hash[:respone_head], hash[:respone_head])
        start_server_hash[:user_define_head] = (hash[:user_define_head].gsub("CR", "\r")).gsub!("LF", "\n") if (hash[:user_define_head] != "")
        start_server_hash[:user_define_respone] = (hash[:user_define_respone].gsub("CR", "\r")).gsub!("LF", "\n") if (hash[:user_define_respone] != "")
        
        start_server_hash[:is_ssl] = hash[:is_ssl]
        start_server_hash[:root_cert_1] = hash[:root_cert_1]
        start_server_hash[:root_cert_2] = hash[:root_cert_2]
        start_server_hash[:child_cert] = hash[:child_cert]
        begin
          AF::Servers::Http_Server.stop_all_service
          running_server = AF::Servers::Http_Server.new(start_server_hash)
          return running_server.running_service
        rescue Exception =>e
          ATT::KeyLog.error("启动服务器失败,端口绑定失败的概率比较高,以下是堆栈:")
          ATT::KeyLog.error("\n#{e.backtrace.join("\n")}\n")
          ATT::KeyLog.error("#{$!.to_s}\n")
          return_fail
        end
      end
    end
  end
end
