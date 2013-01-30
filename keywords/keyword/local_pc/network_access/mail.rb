=begin rdoc
作用: 封装执行主机上MAIL网络访问的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-09              创建
=end
require 'tmail'
require 'tlsmail'

module LocalPc

  module NetworkAccess


=begin rdoc
类名: MAIL
描述: MAIL
=end
    class Mail < ATT::Base

=begin rdoc
关键字名: 发送邮件
描述: 当邮件服务器,端口,域名,用户名,密码,发件人为空时,使用net.yml中的配置
参数:
id=>title,name=>邮件标题,type=>s,must=>false,default=>"邮件标题",value=>"{text}",descrip=>"邮件标题"
id=>content,name=>邮件内容,type=>s,must=>false,default=>"邮件内容",value=>"{text}",descrip=>"邮件内容"
id=>attachment,name=>附件,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"附件,位于项目temp目录下的文件,多个时使用&分割"
id=>mail_server,name=>邮件服务器,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"邮件服务器的地址"
id=>port,name=>端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"smtp端口"
id=>domain,name=>域名,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"域名"
id=>user,name=>用户名,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"用户名"
id=>passwd,name=>密码,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"密码"
id=>sender,name=>发件人,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"发件人"
id=>receiver,name=>收件人,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"收件人,多个用&隔开"
id=>copy_receiver,name=>抄送,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"抄送,多个用&隔开"
id=>passwd_receiver,name=>密送,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"密送,多个用&隔开"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果"
=end
      def send_mail_attachment(hash)
        host,smtp_port,domain,user,passwd,sender,receiver,copy_receiver,passwd_receiver = get_send_mail_parameters( hash )
        attach_files = []
        hash[:attachment].split("&").each do |item|
          path = File.join(ATT::ConfigureManager.root,"temp", "#{item}")
          attach_files.push(path)
        end
        send_result = false
        2.times do
          begin
            send_result = ATT::Mail.send_mail(hash[:content],hash[:title], attach_files, host, smtp_port, domain, \
                user, passwd, sender, receiver, copy_receiver, passwd_receiver)
          rescue Exception
            ATT::KeyLog.info("发生异常:#{$!.class},#{$!.message},重试...")
            sleep 5
          end
          return_ok if send_result == true
        end
        return_fail("失败") # 2次都未发送成功
      end

=begin rdoc
关键字名: 接收并检查邮件
描述: 接收邮件并检查邮件的内容,pop3服务器,pop3端口,用户名,密码为空时,使用net.yml中的配置
参数: 
id=>delete,name=>删除邮件,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否删除接收的邮件,默认是,即删除"
id=>server,name=>pop3服务器,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"pop3服务器"
id=>port,name=>pop3端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"pop3端口"
id=>user,name=>用户名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"用户名"
id=>passwd,name=>密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"密码"
id=>subject,name=>邮件标题,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望包含的邮件标题"
id=>content,name=>邮件内容,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望包含的邮件内容,多个时使用&分割"
id=>sender,name=>发件人,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望包含的发件人"
id=>receiver,name=>收件人,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"期望包含的收件人"
id=>path,name=>本地路径,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"保存路径邮件,为空不保存,路径为相对项目根目录,如temp"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|无邮件|收取邮件失败",descrip=>"期望结果"
=end
      def receive_and_check_mail(hash)
        success = true # 收到的邮件是否包含指定条件对应的邮件的标识
        begin
          Net::POP3.start(hash[:server], hash[:port].to_i, hash[:user], hash[:passwd]) do |pop|
            if pop.mails.empty?
              ATT::KeyLog.info("没有收到任何邮件")
              return_fail("无邮件")
            else
              pop.each_mail do |message|
                mail_string = message.pop
                mail_string.strip!
                mail_string = mail_string.split("\r\n")[1..-1].join("\r\n") if mail_string.split("\r\n")[0].strip == "+OK"
                begin
                  mail = TMail::Mail.parse( mail_string )
                rescue => e # 邮件格式有问题?
                  ATT::KeyLog.info(e)
                  message.delete if hash[:delete].to_logic
                  next # 继续下一封邮件
                end
                subject_of_current_mail = mail.subject
                from_of_current_mail = mail.from
                to_of_current_mail = mail.to
                body_of_current_mail = mail.body
                message.delete if hash[:delete].to_logic # 删除
                ATT::KeyLog.info("The mail subject is : #{subject_of_current_mail}")
                ATT::KeyLog.info("The mail sender is : #{from_of_current_mail}")
                ATT::KeyLog.info("The mail reciever is : #{to_of_current_mail}")
                ATT::KeyLog.info("The mail content is: #{body_of_current_mail}")
                if !hash[:subject].empty? && !subject_of_current_mail.include?(hash[:subject])
                  ATT::KeyLog.info("实际邮件标题#{subject_of_current_mail}与期望标题#{hash[:subject]}不一致")
                  success = false
                end
                if success && !hash[:content].empty?
                  hash[:content].split("&").each do |item|
                    if !body_of_current_mail.include?(item)
                      ATT::KeyLog.info("实际邮件内容#{body_of_current_mail}不包含期望内容#{hash[:content]}")
                      success = false; break
                    end
                  end
                end
                if success && !hash[:sender].empty? && !from_of_current_mail.include?(hash[:sender])
                  ATT::KeyLog.info("邮件发件人#{from_of_current_mail}不包含期望发件人#{hash[:sender]}")
                  success = false
                end
                if success && !hash[:receiver].empty? && !to_of_current_mail.include?(hash[:receiver])
                  ATT::KeyLog.info("邮件收件人#{to_of_current_mail}不包含期望收件人#{hash[:receiver]}")
                  success = false
                end
                if success # 当前的邮件是指定条件对应的邮件
                  return_ok
                else  # 当前的邮件不是指定条件对应的邮件
                  next # 继续下一封邮件
                end
              end
            end
          end
        rescue Errno::ECONNREFUSED
          ATT::KeyLog.info("连接邮件服务器失败,请检查参数...")
          return_fail "收取邮件失败"
        rescue Net::SMTPAuthenticationError
          ATT::KeyLog.info("邮件服务器授权错误,请检查配置或参数")
          return_fail "收取邮件失败"
        rescue Timeout::Error
          ATT::KeyLog.info("连接超时")
          return_fail "收取邮件失败" # 收取失败
        rescue Errno::ETIMEDOUT
          ATT::KeyLog.info("连接邮件服务器失败")
          return_fail "收取邮件失败" # 收取失败
        rescue Errno::ECONNRESET
          ATT::KeyLog.info("连接被拒")
          return_fail "收取邮件失败" # 收取失败
        end
      end

=begin rdoc
关键字名: 删除服务器端所有邮件
描述: 删除服务器端所有邮件
参数:
id=>server,name=>pop3服务器,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"pop3服务器IP"
id=>port,name=>pop3端口,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"pop3端口"
id=>user,name=>用户名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"用户名"
id=>passwd,name=>密码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"密码"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"删除成功",value=>"删除成功|删除失败",descrip=>"期望结果"
=end
      def delete_all_mails_in_mailserver( hash )
        retry_times = 0
        mail_size = nil
        begin
          Net::POP3.start(hash[:server], hash[:port].to_i, hash[:user], hash[:passwd]) do |pop|
            mails = pop.mails
            ATT::KeyLog.info("邮件个数#{mails.size}")
            pop.each_mail do |message|
              ATT::KeyLog.info("deleted...")
              message.delete
            end
          end
          Net::POP3.start(hash[:server], hash[:port].to_i, hash[:user], hash[:passwd]) do |pop|
            mail_size = pop.mails.size
            ATT::KeyLog.info("邮件个数#{mail_size}")
          end
        rescue => e
          ATT::KeyLog.info("发生异常:#{$!.class},#{$!.message},现重试")
          retry_times += 1
          sleep 5
          retry if retry_times < 3
        end
        return_ok("删除成功") if mail_size == 0
        return_fail("删除失败")
      end

    end
  end
end
