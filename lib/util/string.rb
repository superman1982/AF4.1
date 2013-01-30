# coding: utf8
class String

=begin
将字符串转换成数字
=end
  def to_int()
    if self == "是" || self == "允许" || self == "启用"
      return 1
    elsif self == "否" || self == "拒绝" || self == "禁用"
      return 0
    elsif self == "无效"
      return 2
    end
  end

=begin
将字符串转换成true,false
=end
  def to_logic()
    raise ATT::Exceptions::RightExecuteError,"参数错误" unless self.match(/是|否|成功|失败|启用|禁用|允许|拒绝/)
    return true if self.match(/是|成功|启用|允许/)
    return false
  end

  # 时间字符串转换成Time类型
  def to_time
    begin
      time_array = ParseDate::parsedate(self, "F")
    rescue
      ATT::KeyLog.soft($!.class, $!.message)
    end
    time_array[0] = Time.now.strftime("%Y").to_i if time_array[0].nil?
    time_array[-3] = 0 if time_array[-3].nil?
    second_array = time_array[0..-3]
    begin
      time = Time.local(*second_array)
    rescue
      raise ATT::Exceptions::RightExecuteError,"参数错误"
    end
    return time
  end
  
  # 将IP地址字符串转换成十进制的某个值,与APM后台的ipaddr功能一致
  def to_dec
    string = self
    temp_array = string.split(".")
    unless temp_array.size == 4 # 不是IP地址格式'xx.xx.xx.xx'
      ATT::KeyLog.error("#{string}不是IP地址格式")
      raise ATT::Exceptions::RightExecuteError,"参数错误"
    end

    all_hex_text = ""
    temp_array.each do |temp|
      raise ATT::Exceptions::RightExecuteError,"参数错误" if temp.to_i >= 256 # 范围错误
      for index in 0..temp.length-1
        raise ATT::Exceptions::RightExecuteError,"参数错误" unless temp[index..index] =~ /[0-9]/
      end
      hex_text = temp.to_i.to_s(16) # 每个转换成十六进制字符串
      hex_text = "0#{hex_text}" if hex_text.length < 2
      all_hex_text += hex_text
    end

    result_value = all_hex_text.hex
    #ATT::KeyLog.debug("IP地址:#{string}的十进制值是:#{result_value}")
    return result_value
  end

  # 将危险等级转换成数字
  def to_level_num
    level_text = self
    raise ATT::Exceptions::RightExecuteError,"参数错误" unless self.match(/高|中|低/)
    level_map = {"高" => 1, "中" => 2, "低" => 3}
    if level_map.has_key?("#{level_text}")
      return level_map["#{level_text}"]
    else
      ATT::KeyLog.error("未知的严重等级:#{level_text}")
      raise ATT::Exceptions::RightExecuteError,"参数错误"
    end
  end
  
  # 漏洞类型名称转换成漏洞类型ID,select * from CfgIPSHoleType
  def to_hole_type_id
    hole_type_name = self
    hole_type_name_and_id_map = {
      "worm" => 5, "network_device" => 107, "database" => 100, "file" => 202, "backdoor" => 2,
      "trojan" => 4, "spyware" => 3, "web" => 102, "application" => 203, "web_browse" => 201,
      "media" => 109, "dns" => 105, "ftp" => 103, "mail" => 101, "tftp" => 104, "system" => 1,
      "telnet" => 106, "shellcode" => 6, "web_activex" => 200
    }
    if hole_type_name_and_id_map.has_key?("#{hole_type_name}")
      return hole_type_name_and_id_map["#{hole_type_name}"]
    else
      ATT::KeyLog.error("未知的漏洞类型名称:#{hole_type_name}")
      raise ATT::Exceptions::RightExecuteError,"参数错误"
    end
    
  end
  
  # => 根据ID获得网站防护的可选的漏洞类型含: 1 系统命令注入,2 SQL 注入,3 XSS 攻击,4 跨站请求伪造,5 目录遍历攻击,6 文件包含攻击,7 信息泄漏攻击,8 WEBSHELL,9 网页木马,10 网站扫描,
  # => 王沃伦添加,为了WAF的方便
  def to_web_app_protect_name()
    app_type_id = self
    web_app_type_id_and_name_map = { "1" => "系统命令注入", "2" => "SQL 注入", "3" => "XSS 攻击", "4" => "跨站请求伪造", "5" => "目录遍历攻击", "6" => "文件包含攻击", "7" => "信息泄漏攻击", "8" => "WEBSHELL", 
        "9" => "网页木马", "10" => "网站扫描" }
    if web_app_type_id_and_name_map.has_key?("#{app_type_id}")
      return web_app_type_id_and_name_map["#{app_type_id}"]
    else
      ATT::KeyLog.error("未知的网站防护ID:#{app_type_id}")
      raise ATT::Exceptions::RightExecuteError,"参数错误"
    end
    
  end
  
  # 动作转换成对应的数字
  def to_action_num
    action_text = self
    raise ATT::Exceptions::RightExecuteError,"参数错误" unless self.match(/允许|拒绝|发现病毒/)
    action_map = {"允许" => 1, "拒绝" => 2, "发现病毒" => 3}
    if action_map.has_key?("#{action_text}")
      return action_map["#{action_text}"]
    else
      ATT::KeyLog.error("未知的动作:#{action_text}")
      raise ATT::Exceptions::RightExecuteError,"参数错误"
    end
  end
  
end