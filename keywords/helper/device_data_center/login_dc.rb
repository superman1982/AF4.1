# coding: utf8
module DeviceDataCenter
  module LoginDcHelper

    # 登录数据中心时,输入用户名密码并点击登录
    def input_user_and_click(user, passwd )
      $dc_browser.text_field(:id, LOGIN_USER_ID).set( user )
      $dc_browser.text_field(:id, LOGIN_PASSWD_ID).set( passwd )
      $dc_browser.button(:id, LOGIN_BUTTON_ID ).click
      $dc_browser.wait
      $dc_browser.refresh
      $dc_browser.maximize
    end

    
  end
end
