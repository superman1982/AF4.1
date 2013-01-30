# encoding: utf-8
=begin rdoc
作用: 请输入作用
维护记录:
维护人      时间                  行为
[王沃伦]     2012-12-29                     创建
=end

module LocalPc

  module NetworkServer


=begin rdoc
类名: AutoIT启动服务器
描述: AutoIT启动服务器
=end
    class AutoitxStartServer < ATT::Base

=begin rdoc
关键字名: 启动TCP服务器
描述: 启动TCP服务器
维护人: 王沃伦
参数:
id=>port,name=>端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"发包目的端口"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def start_tcp_server(hash={})
        tcp_server_run(hash)
      end

=begin rdoc
关键字名: 关闭TCP服务器
描述: 关闭TCP服务器
维护人: 王沃伦
参数:
id=>port,name=>端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"发包目的端口"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def stop_tcp_server(hash={})
        tcp_server_stop(hash)
      end

      #end of class AutoitxStartServer
    end
    #don't add any code after here.

  end

end
