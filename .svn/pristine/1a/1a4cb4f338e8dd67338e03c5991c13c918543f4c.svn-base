# coding: utf8
=begin rdoc
作用: 登录数据中心
维护记录:
维护人      时间                  行为
gsj     2012-01-06              创建
=end
require 'watir'

module DeviceDataCenter


=begin rdoc
类名: 登录数据中心
描述: UI方式登录数据中心
=end
  class LoginDc < ATT::Base

=begin rdoc
关键字名: 登录数据中心
描述: UI方式登录数据中心
参数:
id=>gw_ip,name=>网关IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"当前要操作的设备的IP,如200.200.85.126"
id=>port,name=>端口,type=>s,must=>false,default=>"85",value=>"{text}",descrip=>"数据中心的端口,默认是85"
id=>user,name=>用户名,type=>s,must=>false,default=>"admin",value=>"{text}",descrip=>"登录数据中心的用户名,默认是admin"
id=>passwd,name=>密码,type=>s,must=>false,default=>"sangfor",value=>"{text}",descrip=>"登录数据中心的密码,默认是sangfor"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def login_dc(hash)
      AF::MyBrowser.close_browsers # 关闭所有的浏览器窗口
      login_url = "http://#{hash[:gw_ip].strip}:#{hash[:port].strip}"
      ATT::KeyLog.info("数据中心的地址: #{login_url}")
      $dc_browser = Watir::IE.my_new
      $dc_browser.goto(login_url)
      $topframe = $dc_browser.frame(:name, "topFrame")
      $leftframe = $dc_browser.frame(:name, "leftFrame")
      $mainframe = $dc_browser.frame(:name, "mainFrame")
      if $mainframe.exist? # 已经登录了
        $dc_browser.maximize
        $main_sub_frame = $mainframe.frames[1]
        ATT::KeyLog.info("数据中心已经登录过了,直接返回")
        return_ok
      else
        input_user_and_click(hash[:user], hash[:passwd]) # 输入用户名密码并点击登录
        if $mainframe.exist?
          $main_sub_frame = $mainframe.frames[1]
          return_ok
        else
          ATT::KeyLog.debug("登录失败,当前页面的文本:#{$dc_browser.html}")
          return_fail
        end
      end
    end
    


  end
end
