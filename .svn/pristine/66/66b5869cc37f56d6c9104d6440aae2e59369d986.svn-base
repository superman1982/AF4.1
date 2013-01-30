# coding: utf8
require 'rubygems'
require 'patron'
require 'json'
require 'ostruct'

=begin
Session类的作用:创建session连接,post数据给设备后台,若需要重新登录设备控制台则重新登录
              关键字编码内部不调用该类的接口,其接口供AF::Login类调用
=end

module AF
  class Session < Patron::Session
    @@session = nil

    def initialize
      super
    end

    def self.get(url = nil, connect_timeout = 120000, insecure = true)
      if @@session && @@session.base_url == url
        return @@session
      end
#      if @@session.nil?
#        ATT::KeyLog.info("url=#{url}")
#      else
#        ATT::KeyLog.info("@@session.base_url=#{@@session.base_url},url=#{url}")
#      end
      @@session = Session.new
      @@session.connect_timeout = connect_timeout
      @@session.timeout = 60
      @@session.insecure = insecure
      @@session.base_url = url
      @@session.handle_cookies
      return @@session
    end

    # post数据给设备并获取返回的数据
    # uri => post数据给此uri
    # data_hash => 要post的hash类型的数据
    # update => 是否要立即下发配置并生效,af控制台上的操作都是立即生效的,所以不需要将此参数设为true
    # need_relogin => 是否需要重新登录控制台
    def post(uri, data_hash, update = false, need_relogin = true)
      data_hash["csrf"] = $cookie
      data_hash_json = data_hash.to_json
      ATT::KeyLog.info("post的数据是:\n#{data_hash_json}")
      headers = {}
      post_return = nil # 调用Patron::Session的post方法返回的值
      5.times do # 尝试5次
        begin
          post_return = super(uri, data_hash_json, headers)
        rescue Exception
          if $!.to_s.include?("transfer closed with outstanding read data remaining") # 修改登录端口会返回此错误,实际修改成功
            real_result = OpenStruct.new
            real_result.body = "{\"success\":true, \"msg\":[]}"
            return real_result
          end
          sleep(10)
          ATT::KeyLog.info("#{$!.to_s},ssl error,retrying...")
        end
        break unless post_return.nil?
      end
      raise ATT::Exceptions::NotFoundError,"POST失败" if post_return.nil? # 尝试5次仍然失败,则抛异常

      real_result = OpenStruct.new
      real_result.url = post_return.url
      real_result.status = post_return.status
      real_result.status_line = post_return.status_line
      real_result.redirect_count = post_return.redirect_count
      real_result.headers = post_return.headers
      if real_result.status.to_s[0,1] != "2"
        real_result.body = "{\"success\":false, \"msg\":\"response error, code: #{post_return.status}\", \"errorno\":-8}"
      else
        if post_return.body.index(":undefined")# 修正json返回不标准的情况
          post_return.body.gsub!(":undefined",":false")
        end
        return_hash = JSON.parse(post_return.body) # post后返回的hash数据
        return_hash["success"] = return_hash["result"]["success"] if !return_hash["result"].nil? && !return_hash["result"]["success"].nil?
        if return_hash["success"] == true
          return_hash.store("errorno", 0)
          return_hash.store("msg", "default success msg while original msg is null") if return_hash["msg"].nil?
        elsif return_hash["success"] == false
          if !return_hash["msg"].nil? && return_hash["msg"] == "unknow opration"
            return_hash.store("errorno", 4)
          else
            return_hash.store("errorno", 8)
          end
          return_hash.store("msg", "default error msg while original msg is null") if return_hash["msg"].nil?
        elsif !return_hash["inputError"].nil?
          msg = return_hash["inputError"]["data"].to_s
          return_hash.store("msg", msg)
          return_hash.store("errorno", 16)
          return_hash.store("success", false)
        elsif !return_hash["errWrap"].nil? || !return_hash["errorWrap"].nil?
          return_hash.store("errorno", 32)
          return_hash.store("success", false)
          return_hash.store("msg", return_hash["errWrap"].to_s) if return_hash["msg"].nil?
        else
          return_hash.store("errorno", -255)
          return_hash.store("success", false)
          return_hash.store("msg", "unknow error type")
        end
        real_result.body = return_hash.to_json
      end
      if real_result.body.include?("needRelogin")
        if JSON.parse(real_result.body)["needRelogin"] && need_relogin
          AF::Login.login() # 重新登录,AF::Login
          return post(uri, data_hash, update, false) #第二次就不再重试了
        end
      end
      
      #每次自动更新
      if update
        tmpret = nil
        4.times do
          begin
            tmpret = super("/cgi-bin/cfg-status.cgi",'{"opr":"status"}')
          rescue Exception
            sleep(10)
            ATT::KeyLog.info("#{$!.to_s},ssl error,retrying...")
          end
          break if tmpret != nil && JSON.parse(tmpret.body)["success"] == true
        end
        raise ATT::Exceptions::HttpNotConnectedError,"配置下发失败" if tmpret.nil?
        tmpres = JSON.parse(tmpret.body)
        if tmpres["success"] == true
          ATT::KeyLog.info(tmpres["msg"])
          ATT::KeyLog.info("配置下发成功")
        else
          ATT::KeyLog.info(tmpres["msg"])
          raise ATT::Exceptions::HttpNotConnectedError,"配置下发失败"
        end
      end
      if uri == "/cgi-bin/login.cgi" # 登录后,获取本次cookie
        result_header_hash = real_result.headers
        tmp_string = result_header_hash["Set-Cookie"]
        tmp_array = tmp_string.to_s.split(";")
        tmp_array.each do |k_and_v|
          if k_and_v.include?("sangfor_session_id")
            $cookie = k_and_v.split("=")[1].to_s
            ATT::KeyLog.info("登录成功,$cookie = #{$cookie}")
          end
        end
      end
      post_result = real_result.body # real_result.body 是json格式的数据
      ATT::KeyLog.info("after post #{uri}, result is: #{post_result}"  )
      return JSON.parse(post_result) # 返回hash格式的操作结果
    end
      
  end
end