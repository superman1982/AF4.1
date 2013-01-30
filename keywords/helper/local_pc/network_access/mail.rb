# coding: utf8
module LocalPc
  module NetworkAccess
    module MailHelper

      def get_send_mail_parameters( hash )
        host = smtp_port = domain = user = passwd = sender = nil
        receiver = copy_receiver = passwd_receiver = []
        host = hash[:mail_server] unless hash[:mail_server].empty?
        smtp_port = hash[:port].to_i unless hash[:port].empty?
        domain = hash[:domain] unless hash[:domain].empty?
        user = hash[:user] unless hash[:user].empty?
        passwd = hash[:passwd] unless hash[:passwd].empty?
        sender = hash[:sender] unless hash[:sender].empty?
        receiver = hash[:receiver].split("&") unless hash[:receiver].empty?
        copy_receiver = hash[:copy_receiver].split("&") unless hash[:copy_receiver].empty?
        passwd_receiver = hash[:passwd_receiver].split("&") unless hash[:passwd_receiver].empty?
        ATT::KeyLog.info("#{host}/#{smtp_port}/#{domain}/#{user}/#{passwd}/#{sender}")
        ATT::KeyLog.info("#{receiver.join('&')}/#{copy_receiver.join('&')}/#{passwd_receiver.join('&')}")
        return [host,smtp_port,domain,user,passwd,sender,receiver,copy_receiver,passwd_receiver]
      end

    end
  end
end
