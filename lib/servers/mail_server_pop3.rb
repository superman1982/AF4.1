require 'md5'
module AF
  module Servers
    class Mail_Server
      # => 在新线程运行Pop的服务器
      def start_pop_server()
        Thread.new {
          init_thread_data_hash({:type => "pop_server_listen"})
          begin
            while (session = @pop_server_socket.accept)
              Thread.new(session) do |accept_session|
                init_thread_data_hash({:type => "pop_server_session", :start_time => Time.now, :socket => accept_session})
                accept_session.write("+OK " + @welcome_word + "\r\n")
                pop_request()
                destory_thread_data_hash()
              end
            end
          rescue
            ATT::KeyLog.error("pop客户连接线程出错了,跑出了以下异常")
            ATT::KeyLog.error($!.to_s)
            return_error
          ensure
            @server_socket.close
          end
          return_ok
        }
      end

      # => 每个回话连接处理函数
      def pop_request()
        state = "connected"
        is_begin = true
        loop do
          return true if @thread_data_hash[Thread.current][:socket].closed?
          request_str = get_request
          if request_str == nil
            sleep 1 # => 稍微睡一下,避免过度占用CPU
            next
          end
          request_str = request_str.chomp()
          ATT::KeyLog.debug("获得的 request 是:::#{request_str}")

          case(request_str)
          when /^USER/i
            ATT::KeyLog.debug("进入 do_pop_USER request 是:::#{request_str}")
            do_pop_USER(request_str)
          when /^PASS/i
            ATT::KeyLog.debug("进入 do_pop_PASS request 是:::#{request_str}")
            is_begin = ! do_pop_PASS(request_str)
          when /^STAT/i
            ATT::KeyLog.debug("进入 do_pop_STAT request 是:::#{request_str}")
            do_pop_STAT(request_str)
          when /^LIST/i
            ATT::KeyLog.debug("进入 do_pop_LIST request 是:::#{request_str}")
            do_pop_LIST(request_str)
          when /^UIDL/i
            ATT::KeyLog.debug("进入 do_pop_UIDL request 是:::#{request_str}")
            do_pop_UIDL(request_str)
          when /^RETR/i
            ATT::KeyLog.debug("进入 do_pop_RETR request 是:::#{request_str}")
            do_pop_RETR(request_str)
          when /^DELE/i
            ATT::KeyLog.debug("进入 do_pop_DELE request 是:::#{request_str}")
            do_pop_DELE(request_str)
          when /^RSET/i
            ATT::KeyLog.debug("进入 do_pop_RSET request 是:::#{request_str}")
            do_pop_RSET()
          when /^NOOP/i
            ATT::KeyLog.debug("进入 do_pop_NOOP request 是:::#{request_str}")
            do_pop_NOOP(request_str)
          when /^QUIT/i
            ATT::KeyLog.debug("进入 QUIT request 是:::#{request_str}")
            return true if is_begin
            is_begin = do_pop_QUIT()
          else
            ATT::KeyLog.debug("进入 do_pop_unknow_request request 是:::#{request_str}")
            do_pop_unknow_request()
          end
        end
      rescue
        ATT::KeyLog.error("Error we get on : \n #{$!.to_s} \n #{$!.backtrace.join("\n     ")}") rescue nil
      ensure
        @thread_data_hash[Thread.current][:socket].close rescue nil
      end

      def do_pop_USER(request_str)
        reply("+OK every one can come")
        return true
      end

      def do_pop_PASS(request_str)
        reply("+OK every one can come")
        return true
      end

      def do_pop_STAT(request_str)
        reply("+OK 1 #{Mail_str.size}")
        return true
      end

      def do_pop_LIST(request_str)
        number = (request_str.split(/\s+/)+['', '', ''])[1]
        number = number == "" ? 1 : number if number != nil
        number = 1 if number == nil
        ATT::KeyLog.debug("得到的 POP List 参数是:#{number}")
        reply("+OK #{number} #{Mail_str.size}")
        reply("#{number} #{Mail_str.size}")
        reply(".")
        return true
      end

      def do_pop_UIDL(request_str)
        md5 = MD5.new(Mail_str+Time.new.to_f.to_s)
        number = (request_str.split(/\s+/)+['', '', ''])[1]
        if number == nil or number == "" or number.to_i == 1
          reply("+OK only one core mail")
          reply("1 #{md5}")
          reply(".")
        elsif number.to_i >= 1
          reply("-ERR only one core mail in this server")
        end
        return true
      end

      def do_pop_RETR(request_str)
        reply("+OK #{Mail_str.size} octets")
        reply(Mail_str,"")
        reply(".")
      end

      def do_pop_QUIT()
        reply("+OK QUIT")
        return true
      end

      def do_pop_unknow_request()
        reply("-ERR not such command")
        return true
      end

      def do_pop_DELE(request_str)
        reply("+OK delete")
        return true
      end

      def do_pop_RSET()
        reply("+OK reset")
        return true
      end

      Mail_str =<<here_is_the_mail
Date: Mon, 24 Sep 2012 00:26:46 +0800
From: test <test@ab.c>
To: test <test@system.mail>
Reply-To: test <test@ab.c>
Subject: Just_a_test_mail
X-Priority: 3
X-Has-Attach: no
X-Mailer: Foxmail 7.0.1.91[cn]
Mime-Version: 1.0
Message-ID: <201209240026460740647@ab.c>
Content-Type: multipart/alternative;
.boundary="----=_001_NextPart451085306636_=----"

This is a multi-part message in MIME format.

------=_001_NextPart451085306636_=----
Content-Type: text/plain;
.charset="gb2312"
Content-Transfer-Encoding: base64

VGVzdF9tYWlsX2NvbnRlbnQNCg0KDQoNCg0KdGVzdA==

------=_001_NextPart451085306636_=----
Content-Type: text/html;
.charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META content=3D"text/html; charset=3Dgb2312" http-equiv=3DContent-Type>
<STYLE>
BLOCKQUOTE {
.MARGIN-TOP: 0px; MARGIN-BOTTOM: 0px; MARGIN-LEFT: 2em
}
OL {
.MARGIN-TOP: 0px; MARGIN-BOTTOM: 0px
}
UL {
.MARGIN-TOP: 0px; MARGIN-BOTTOM: 0px
}
P {
.MARGIN-TOP: 0px; MARGIN-BOTTOM: 0px
}
BODY {
.LINE-HEIGHT: 1.5; FONT-FAMILY: =CE=A2=C8=ED=D1=C5=BA=DA; COLOR: #000000; =
FONT-SIZE: 10.5pt
}
</STYLE>

<META name=3DGENERATOR content=3D"MSHTML 9.00.8112.16434"></HEAD>
<BODY style=3D"MARGIN: 10px">
<DIV>Test_mail_content</DIV>
<DIV>&nbsp;</DIV>
<HR style=3D"WIDTH: 210px; HEIGHT: 1px" align=3Dleft color=3D#b5c4df SIZE=
=3D1>

<DIV><SPAN>test</SPAN></DIV></BODY></HTML>

------=_001_NextPart451085306636_=------

here_is_the_mail

      def get_mail(from,to,subject,body,attach)
        mail = MailFactory.new
        mail.from = from
        mail.subject = subject
        mail.text = body
        mail.to = to
        if attach.kind_of?(Array)
          attach.each { |i|  mail.add_attachment(i);}
        else
          mail.add_attachment(attach);
        end
        return mail
      end
    end
  end
end