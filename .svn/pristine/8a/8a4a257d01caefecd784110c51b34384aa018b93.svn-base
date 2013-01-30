# coding: utf8
=begin rdoc
作用: 封装执行主机上FTP网络访问的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-09              创建
=end
require "net/telnet"
module LocalPc

  module NetworkAccess


=begin rdoc
类名: FTP
描述: FTP操作
=end
    class Ftp < ATT::Base

=begin rdoc
关键字名: FTP下载
描述: FTP下载,支持主被动模式,使用ruby的netftp库主被动模式下载文件,因为涉及到多个ftp服务器,所以不使用net.yml中的配置
参数:
id=>mode,name=>模式,type=>s,must=>false,default=>"主动",value=>"主动|被动",descrip=>"主动模式还是被动模式下载"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"FTP服务器IP"
id=>user,name=>用户名,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"FTP服务器用户名"
id=>passwd,name=>密码,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"FTP服务器用户的密码"
id=>port,name=>端口,type=>s,must=>false,default=>"21",value=>"{text}",descrip=>"FTP服务器的端口号"
id=>remote_file,name=>远端文件,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"远端的目的文件,带有相对根目录的路径,如/result/csc.txt"
id=>saveas,name=>保存为,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"下载后的文件的本地保存文件名,默认是项目的temp目录"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|下载失败",descrip=>""
=end
      def ftp_download(hash)
        localfile = get_real_path( hash[:saveas])
        remotefile = hash[:remote_file].to_s =~ /^\// ? hash[:remote_file].to_s : "/#{hash[:remote_file]}"
        ATT::KeyLog.info("要从#{hash[:ip]}/#{hash[:user]}/#{hash[:passwd]}上#{hash[:mode]}下载文件#{remotefile}")
        begin
          if hash[:mode] == "主动"
            ATT::Ftp.positive_download(localfile, remotefile, hash[:ip], hash[:user], hash[:passwd], hash[:port].to_i) # 下载文件
          else
            ATT::Ftp.passive_download(localfile, remotefile, hash[:ip], hash[:user], hash[:passwd], hash[:port].to_i) # 下载文件
          end
        rescue Exception
          ATT::KeyLog.error("发生异常#{$!.class},#{$!.message}")
          ATT::KeyLog.error($!.backtrace.join("\n"))
          return_fail("下载失败")
        end
        return_ok
      end

=begin rdoc
关键字名: FTP上传
描述: FTP上传,支持主被动模式
参数:
id=>mode,name=>模式,type=>s,must=>false,default=>"主动",value=>"主动|被动",descrip=>"主动模式还是被动模式上传"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"FTP服务器IP"
id=>user,name=>用户名,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"FTP服务器用户名"
id=>passwd,name=>密码,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"FTP服务器用户的密码"
id=>port,name=>端口,type=>s,must=>false,default=>"21",value=>"{text}",descrip=>"FTP服务器的端口号"
id=>localfile,name=>本地文件,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"位于本地项目的temp目录下,要上传的文件的名称"
id=>remote_dir,name=>目的目录,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"上传文件后要保存在的远端目录,默认是根目录/"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|上传失败",descrip=>""
=end
      def ftp_upload(hash)
        localfile = get_real_path( hash[:localfile])
        remotedir = hash[:remotedir].to_s
        ATT::KeyLog.info("要将文件#{localfile.to_utf8}#{hash[:mode]}上传到#{hash[:ip]}的#{remotedir}上...")
        begin
          if hash[:mode] == "主动"
            ATT::Ftp.positive_upload(localfile, remotedir, hash[:ip], hash[:user], hash[:passwd], hash[:port].to_i ) # 上传文件
          else
            ATT::Ftp.passive_upload(localfile, remotedir, hash[:ip], hash[:user], hash[:passwd], hash[:port].to_i ) # 上传文件
          end
        rescue Exception
          ATT::KeyLog.error("发生异常#{$!.class},#{$!.message}")
          return_fail("上传失败")
        end
        return_ok
      end
      
=begin rdoc
关键字名: FTP爆破登录
描述: 其实就是FTP登陆的一个循环,最终服务器得到密码尝试次数将等于 连接个数 乘以 循环次数
参数:
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"FTP服务器IP"
id=>port,name=>端口,type=>s,must=>false,default=>"21",value=>"{text}",descrip=>"FTP服务器的端口号"
id=>connects,name=>建立连接个数,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"建立的连接次数"
id=>times,name=>循环次数,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"执行登陆的循环次数,最终服务器得到密码尝试次数将等于连接个数乘以循环次数"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"没有失败的,只是发起这爆破,然后等待到操作完毕罢了"
=end
      def ftp_blast(hash)
        fail_time = 0
        running_threads = []
        hash[:connects].to_i.times { |i|
          running_threads << Thread.new(i){|count|
            connect = Net::Telnet.new("Host" => "#{hash[:ip]}","Port" => "#{hash[:port]}","Timeout" => 0)
            if connect == nil
              fail_time += 1
              ATT::KeyLog.info("这里连接失败了 : 尝试5次还失败就退出了 尝试次数 #{fail_time}")
              return_fail if fail_time == 5
              retry
            end
            begin
              1.upto(hash[:times].to_i){ |j|
                ATT::KeyLog.debug("输入的数据::\tUSER user_woolen_test\n")
                connect.cmd("String" => "USER user_woolen_test", "Match" => /^[0-9]*.*/) do |recvdata| 
                  ATT::KeyLog.debug("这里登陆输入 =用户名= 回复的数据(回复数据可能有延时不如预期) : \n#{recvdata}")
                end
                sleep 1; # => FTP服务器不接受太快的登陆数据输入
                STDOUT.flush
                ATT::KeyLog.debug("输入的数据::\tPASS pass_woolen_test_#{count}_#{j}\n")
                connect.cmd("String" => "PASS pass_woolen_test_#{count}_#{j}", "Match" => /^[0-9]*.*/) do |recvdata| 
                  ATT::KeyLog.debug("这里登陆输入 ==密码== 回复的数据(回复数据可能有延时不如预期) : \n#{recvdata}")
                end
                sleep 1;
                STDOUT.flush
              }
            rescue Exception => e
              ATT::KeyLog.warn("这里等待数据出错了,可能被阻断了或者是服务器超时了,以下是堆栈:")
              ATT::KeyLog.debug( e.backtrace )
            ensure
              connect.close
              running_threads.delete(Thread.current)
            end
          }
        }
        loop do
          return_ok if running_threads.size == 0
          sleep 2
        end
      end
      
=begin rdoc
关键字名: FTP返回信息检查
描述: 就是一个只连接一下,检查是否达成FTP信息隐藏的
参数:
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"FTP服务器IP"
id=>port,name=>端口,type=>s,must=>false,default=>"21",value=>"{text}",descrip=>"FTP服务器的端口号"
id=>checkpoint,name=>检查点,type=>s,must=>false,default=>"^[0-9]{3} FTP Service",value=>"{text}",descrip=>"预期检查的数据,正则表达式表达,不要两端的斜杠,默认是隐藏后的正则'^[0-9]{3} FTP Service'"
id=>time_out,name=>连接等待时间,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"想要等待的时间,默认是10"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|下载失败",descrip=>""
=end
      def ftp_check_respone(hash)
        fail_time = 0
        is_ok = false
        5.times {   # => 这里五次循环,正常逻辑只有一次,因为每次循环如果连接能建立,下面的逻辑都确保能return跳出循环
          connect = Net::Telnet.new("Host" => "#{hash[:ip]}","Port" => "#{hash[:port]}","Timeout" => hash[:time_out].to_i)
          if connect == nil
            fail_time += 1
            ATT::KeyLog.info("这里连接失败了 : 尝试5次还失败就退出了 尝试次数 #{fail_time}")
            return_fail if fail_time == 5
            next
          end
          begin
            ATT::KeyLog.debug( "直接查看返回的数据~~" )
            connect.waitfor({"Match" => /.*/}) { |recvdata| 
              is_ok = true if recvdata =~ Regexp.new(hash[:checkpoint]) 
              ATT::KeyLog.info( "收到数据~~数据为:: #{recvdata} , 匹配的正则表达式是 : #{Regexp.new(hash[:checkpoint])}" )
            }
          rescue Exception => e
            ATT::KeyLog.warn("这里等待数据出错了,可能被阻断了或者是服务器超时了,以下是堆栈:")
            ATT::KeyLog.debug( e.backtrace )
          ensure
            connect.close
            return_ok if is_ok
          end
        }
        return_fail
      end

    end
  end
end
