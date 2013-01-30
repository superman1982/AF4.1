# coding: utf8
require "att"
require 'lib/session'

=begin
Login类的主要作用: 使用创建的session连接,post数据给设备后台,实现登录控制台的功能
=end

module AF
  class Login
    
    @@ac_client = nil

    # 获取可以正常使用的有效的session,并实现控制台的登录,登录的地址是https://ip
    def self.get_session()
      ATT::KeyLog.info "begin get session or login..."
      login() if @@ac_client.nil?
      try_times = 3
      try_times.times do # 检查登录是否真的正确
        result_hash = @@ac_client.post("/cgi-bin/statusmsg.cgi", {'opr' => 'list'}, false)
        if result_hash["success"] != true
          begin
            login
          rescue ATT::Exceptions::ArgumentError
            sleep 30
            login
          end
          next
        end
        return @@ac_client
      end
      raise ATT::Exceptions::ArgumentError,"获取Session对象失败"
    end

    # 登录设备控制台
    def self.login(gw_ip = nil, port = 443)
      console_url, user, passwd = get_login_info(gw_ip, port)
      ATT::KeyLog.info "login console...."
      login_hash = {"opr" => "login", "data" => { "user" => user, "pwd" => passwd }}
      @@ac_client = AF::Session.get(console_url)
      result_hash = @@ac_client.post("/cgi-bin/login.cgi", login_hash, false) # 在次尝试5次post
      raise ATT::Exceptions::ArgumentError,"登录失败" unless result_hash["success"]
      return @@ac_client
    end

    # 获取登录控制台需要的信息,包含url,用户名,密码
    def self.get_login_info(gw_ip, port)
      raise ATT::Exceptions::ArgumentError, "尚未指定设备" if(gw_ip.nil? && $gw_ip.nil?)
      raise ATT::Exceptions::ArgumentError, "尚未指定设备" if($user.nil? && $passwd.nil?)
      if gw_ip.nil? && port == 443
        console_url = "https://#{$gw_ip}/"
      elsif gw_ip.nil? && port != 443
        console_url = "https://#{$gw_ip}:#{port}/"
      elsif !gw_ip.nil? && port != 443
        console_url = "https://#{gw_ip}:#{port}/"
      else !gw_ip.nil? && port == 443
        console_url = "https://#{gw_ip}/"
      end
      return [ console_url, $user, $passwd ]
    end

    # 注销控制台登录
    def self.logout()
      ATT::KeyLog.info "logout console...."
      logoff_hash = {"opr" => "logoff"}
      begin
        @@ac_client.post("/cgi-bin/login.cgi", logoff_hash , false) unless @@ac_client.nil?
        @@ac_client = nil
      rescue => e
        @@ac_client = nil
      end
    end

  end
end
