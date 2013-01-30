# coding: utf8
module DeviceBack
  module DataBaseOperationConst

    # 期望记录中,记录间的分隔符
    RECORD_DEMILTER = "&"
    # 期望记录中,每条记录内各个字段间的分隔符
    ATTRIBUTE_DELIMITER = "#"
    # 期望记录中,忽略检查的字段替代符合
    IGNORE_ATTR_REPLACEMENT = "-"
    # IPS日志查询,每条期望记录中应包含的字段个数
    ATTR_COUNT_OF_IPS_LOG_HOPED = 13
    # DOS攻击日志查询,每条期望记录中应包含的字段个数
    ATTR_COUNT_OF_DOS_LOG_HOPED = 8
    # WAF攻击日志查询,每条期望记录中应包含的字段个数
    ATTR_COUNT_OF_WAF_LOG_HOPED = 7
    
    WAF_ATTACK_NAME_AND_ID_MAP = 
        {"SQL注入" => 1,"XSS攻击" => 2,"网页木马" => 3,"网站扫描" => 4,"WEBSHELL" => 5,"跨站请求伪造" => 6,"系统命令注入" => 7,"文件包含攻击" => 8,
        "目录遍历攻击" => 9,"信息泄漏攻击" => 10,"WEB整站系统漏洞" => 11,"受限URL访问" => 12,"主动防御" => 13,"自定义参数防护" => 14,"FTP服务信息隐藏" => 15, "过滤HTTP响应报文头" => 16, "过滤HTTP出错页面" => 17,
         "FTP弱口令" => 18, "弱口令类型-空口令" => 19, "口令类型-用户名和密码相同" => 20, "弱口令类型-长度小于等于8位字典序" => 21, "弱口令类型-长度小于等于8位纯数字" => 22,
        "弱口令类型-长度小于等于8位纯字母" => 23, "弱口令类型-长度小于等于6位仅数字和字母" => 24, "弱口令类型-弱口令列表" => 25,"网页篡改" => 26, "弱密码登陆识别" => 27,
        "明文登陆识别" => 28,"暴力破解FTP口令" => 29,
        "暴力破解网站登录口令" => 30, "文件上传过滤" => 31, "URL防护" => 32, "用户登录权限防护" => 33,
        "协议异常" => 34, "方法过滤" => 35,"缓冲区溢出检测" => 36, "敏感信息防护" => 37, "文件下载过滤" => 38}
  end
end
