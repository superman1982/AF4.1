# coding: utf8
=begin rdoc
作用: WAF页面配置
维护记录:
维护人      时间                  行为
[王沃伦]     2012-08-22                     创建
=end
require 'keywords/keyword/device_console'
module DeviceConsole

  module ServerProtection


=begin rdoc
类名: WEB应用防护
描述: 操作WAF的页面
=end
    class Waf < ATT::Base

=begin rdoc
关键字名: 新增WEB应用防护
描述: 添加一个WEB应用防护规则
维护人: 王沃伦
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"WAF策略名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此WAF规则"
id=>description,name=>描述,type=>s,must=>false,default=>"woolenTest",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"lan",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>dest_zone,name=>目的区域,type=>s,must=>true,default=>"wan",value=>"{text}",descrip=>"目的区域,多个时使用&分割"
id=>dest_ipgs,name=>目的IP组,type=>s,must=>true,default=>"全部",value=>"{text}",descrip=>"目的IP组,多个时使用&分割"
id=>web_app_port,name=>WEB应用端口,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"Web应用的端口,多个时用'&'分割(最多四个不能重复)"
id=>ftp_port,name=>FTP端口,type=>s,must=>false,default=>"21",value=>"{text}",descrip=>"FTP端口,多个时用'&'分割(最多四个不能重复)"
id=>mysql_port,name=>MYSQL端口,type=>s,must=>false,default=>"3306",value=>"{text}",descrip=>"MYSQL端口,多个时用'&'分割(最多四个不能重复)"
id=>telnet_port,name=>TELNET端口,type=>s,must=>false,default=>"23",value=>"{text}",descrip=>"TELNET端口,多个时用'&'分割(最多四个不能重复)"
id=>ssh_port,name=>SSH端口,type=>s,must=>false,default=>"22",value=>"{text}",descrip=>"SSH端口,多个时用'&'分割(最多四个不能重复)"
id=>web_app_protect,name=>网站攻击防护,type=>s,must=>false,default=>"1&2&3&4&5&6&7&8&9&10",value=>"{text}",descrip=>"网站攻击防护类型,可选的漏洞类型含: 1 系统命令注入,2 SQL 注入,3 XSS 攻击,4 跨站请求伪造,5 目录遍历攻击,6 文件包含攻击,7 信息泄漏攻击,8 WEBSHELL,9 网页木马,10 网站扫描,多个时使用&分割"
id=>is_csrf_protect,name=>启动CSRF功能,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'CSRF'"
id=>csrf_protect_data,name=>CSRF配置数据列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"CSRF配置数据列表,格式为:: '防护域名@;@(域名)启用与否(是|否)@;@防护页面(target)@;@来源页面(refer)@;@(target)启用与否(是|否)...',每个防护域名可以有多个target-refer对,与域名一起用'@;@'号隔开,例 : www.baidu.com:是@;@/target1@;@/refer1@;@是@;@/target2@;@/refer2@;@否 ,多个域名时用&;&隔开"
id=>is_initiative_recovery,name=>启动主动防御功能,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'主动防御功能'"
id=>initiative_recovery_data,name=>主动防御配置数据列表,type=>s,must=>false,default=>"100:76:是:是",value=>"{text}",descrip=>"主动防御配置数据列表,格式为:: '停止学习阀值:重学习阀值:检测攻击后拒绝(是|否):检测攻击后记录日志(是|否)',对应着点开主动防御配置的相应项,例 : 100:90:是:是 ,表示匹配次数是100次停止学习,达到匹配率90开始重学习,检测到攻击后拒绝,并且记录日志"
id=>initiative_recovery_excld_url,name=>主动防御排除URL列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"主动防御排除URL列表,格式为:: 'URL1;URL2;URL3',每个url用分号隔开"
id=>is_restricted_url,name=>启动受限URL防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'受限URL防护'"
id=>restricted_url_data,name=>受限URL防护配置数据列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"受限URL防护配置数据列表,格式为:: '域名@;@启用(是|否)@;@允许访问起始页(页面1$;$页面2$;$页面3)',域名与启用和允许访问起始页是用'@;@'隔开,其中允许访问起始页是用 '$;$' 隔开,例 : www.baidu.com@;@是@;@/admin$;$/admin2 ,表示保护域名www.baidu.com,启用对应规则,允许访问的来源页面是/admin和/admin2, 多个规则之间用&;&号隔开"
id=>is_cookie_protect,name=>启动cookie防篡改,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'cookie防篡改'"
id=>cookie_protect_select,name=>选择cookie防护选项,type=>s,must=>false,default=>"全部",value=>"全部|白名单|黑名单",descrip=>"选择的cookie防护的对象"
id=>cookie_protect_data,name=>cookie防篡改配置参数名,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"cookie防篡改配置参数名,格式为:: '参数名1;参数名2;参数名3',例 : abc;def ,根据前一个选项来确定是白名单还是黑名单的参数名"
id=>is_aet_protect,name=>启动AET防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"勾选启动AET防护"
id=>is_urlparams_protect,name=>启动URL参数防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'URL参数防护'"
id=>urlparams_protect_data,name=>URL参数防护配置数据列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"URL参数防护配置数据列表,格式为:: 'URL:;:启用(是|否):,;:大小写敏感(是|否):;:参数与正则(参数名@;@等于(是|否)@;@参数正则)',例 : '/test.asp:;:是:;:是:;:param@;@是@;@\d+' ,表示保护URL:/test.asp,启用对应规则,匹配的参数名是param,启用对应参数匹配,匹配方式是等于,正则表达式是d+,规则之间用两个&加分号隔开~!!!'&;&',为了避免复杂正则带来的影响"
id=>streng_url,name=>加强防护的URL,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"按加强URL后弹出的添加URL路径列表,格式为: 'URL:Descript',也就是用':'号把URL和描述隔开,多个时用&分割"
id=>hide_ftp,name=>FTP应用隐藏,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'FTP应用隐藏'"
id=>hide_http,name=>HTTP应用隐藏,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'HTTP应用隐藏'"
id=>is_hide_http_head,name=>过滤HTTP响应报文头,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'过滤HTTP响应报文头'"
id=>hide_http_head,name=>报文头类型,type=>s,must=>false,default=>"Server&X-Powered-By",value=>"{text}",descrip=>"过滤的报文头类型,多个时使用&分割"
id=>is_replace_http_error,name=>替换HTTP出错页面,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'替换HTTP出错页面'"
id=>is_ftp_weakpasswd_protect,name=>FTP弱口令防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'FTP弱口令防护'"
id=>ftp_weakpasswd_protect_set,name=>FTP弱口令设置,type=>s,must=>false,default=>"numchar&same&empty",value=>"{text}",descrip=>"FTP弱口令设置类型(empty 空口令, same 用户名密码相同, less 少于8位字典序, num 少于8位纯数字, char 少于8位纯字母, numchar 少于6位仅数字字母 ),多个时使用&分割"
id=>ftp_weakpasswd_protect_list,name=>FTP弱口令列表,type=>s,must=>false,default=>"a&b&c&123",value=>"{text}",descrip=>"FTP弱口令列表,就是界面输入的定义什么密码是弱密码的,多个时使用&分割"
id=>is_passwdburst_protect,name=>口令暴力破解防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'口令暴力破解防护'"
id=>is_ftp_passwdburst_protect,name=>启用FTP暴破防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'启用口令爆破的FTP保护'"
id=>ftp_passwdburst_protect_count,name=>FTP爆破次数,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"所输入的触发FTP爆破防护的次数"
id=>ftp_passwdburst_protect_unit,name=>FTP爆破时间单位,type=>s,must=>false,default=>"分",value=>"分|秒",descrip=>"所选择的FTP爆破时间单位,有'分'或'秒'"
id=>is_pwdweb_weak,name=>启动WEB弱口令防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'WEB弱口令防护'"
id=>is_pwdweb_tran,name=>启动WEB明文传输,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'WEB明文传输'"
id=>is_web_passwdburst_protect,name=>启用WEB登录,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'启用WEB登录'"
id=>web_passwdburst_protect_path,name=>页面路径列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"所输入的web应用防护爆破的路径,多个时以&隔开"
id=>web_passwdburst_protect_count,name=>WEB爆破次数,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"所输入的触发WEB爆破防护的次数"
id=>web_passwdburst_protect_unit,name=>WEB爆破时间单位,type=>s,must=>false,default=>"分",value=>"分|秒",descrip=>"所选择的WEB爆破时间单位,有'分'或'秒'"
id=>is_file_upload_filter,name=>文件上传过滤,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'文件上传过滤'"
id=>file_upload_filter_list,name=>上传文件黑名单列表,type=>s,must=>false,default=>"jsp&asp&exe",value=>"{text}",descrip=>"上传文件黑名单列表,多个时使用&分割"
id=>is_url_protect,name=>URL防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'文件上传过滤'"
id=>url_protect_list,name=>URL防护列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"URL防护列表,每个URL为:'URL:拒绝|允许:记录|不记',来表示此url记录的允许还是拒绝,日志的记录与否,每个含义用:号隔开,例如:'/abc/def:允许:记录'表示/abc/def这个url是允许的并且记录日志,多个URL时使用&分割"
id=>is_proto_unusual,name=>协议异常,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'协议异常'"
id=>is_method_filter,name=>方法过滤,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'方法过滤'"
id=>method_filter_list,name=>允许HTTP方法列表,type=>s,must=>false,default=>"get&post",value=>"{text}",descrip=>"允许HTTP方法列表,多个时使用&分割"
id=>is_url_overflow,name=>启用URL溢出检测,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'启用URL溢出检测'"
id=>url_overflow_maxlenth,name=>URL溢出最大长度,type=>s,must=>false,default=>"1024",value=>"{text}",descrip=>"URL溢出最大长度,数字"
id=>is_post_overflow,name=>启用Post溢出检测,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'启用Post溢出检测'"
id=>post_overflow_maxlenth,name=>Post溢出最大长度,type=>s,must=>false,default=>"2048",value=>"{text}",descrip=>"Post溢出最大长度,数字"
id=>is_http_head_check,name=>启用HTTP头部溢出检测,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'启用HTTP头部溢出检测'"
id=>http_head_check_list,name=>HTTP头部检测字段列表,type=>s,must=>false,default=>"abc:22",value=>"{text}",descrip=>"HTTP头部检测字段列表,'字段:长度' (例子: abc:11),多个用&隔开"
id=>is_susceptive,name=>敏感信息防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'敏感信息防护'"
id=>susceptive_way,name=>命中次数统计方式,type=>s,must=>false,default=>"IP",value=>"IP|连接",descrip=>"命中次数统计方式下拉选择框的内容"
id=>susceptive_list,name=>敏感信息列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"敏感信息的列表,格式为:: '组合策略名:最低命中次数:敏感信息名字...',敏感信息名字可以多个,用:号隔开,例 : abc:11:身份证:MD5,多个时用&隔开"
id=>is_file_download_filter,name=>文件下载过滤,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'文件下载过滤'"
id=>file_download_filter_list,name=>防护文件类型列表,type=>s,must=>false,default=>"dat&conf&mdb",value=>"{text}",descrip=>"防护文件类型列表,多个用&隔开[自定义的文件类型必须先在对象定义里定义]"
id=>operation,name=>动作,type=>s,must=>false,default=>"拒绝",value=>"允许|拒绝",descrip=>"拒绝还是允许"
id=>islockip,name=>封锁IP,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'封锁IP'"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用勾选'记录日志'"
id=>state_enable,name=>记录响应状态码,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用记录响应状态码"
id=>state_num,name=>状态码,type=>s,must=>false,default=>"200-599",value=>"{text}",descrip=>"状态码"
id=>issmsalarm,name=>短信告警,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'发送短信'"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>""
=end
      def new_waf_policy(hash={})
        ATT::KeyLog.debug("新增WAF策略......")
        post_hash = get_add_waf_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(WAFCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("新增WAF策略......错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除WEB应用防护
描述: 删除一个WAF策略
维护人: 王沃伦
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的IPS策略,还是删除目前所有的IPS策略"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的IPS策略名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def del_waf_policy(hash={})
        ATT::KeyLog.debug("删除WAF策略......")
        if hash[:delete_type] == "全部删除"
          all_waf_policy_names = DeviceConsole::get_all_object_names(WAFCGI, "WAF策略") # 获取所有IPS策略的名称,数组类型
        else
          all_waf_policy_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_waf_policy_names.size == 0
        post_hash = {"opr" => "delete", "name" => all_waf_policy_names }
        result_hash = AF::Login.get_session().post(WAFCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("删除WAF策略......错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑WEB应用防护
描述: 编辑一个WAF策略
维护人: 王沃伦
参数:
id=>oldname,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"需要编辑的WAF策略名称"
id=>name,name=>新名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"WAF策略名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此WAF规则"
id=>description,name=>描述,type=>s,must=>false,default=>"woolenTest",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"lan",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>dest_zone,name=>目的区域,type=>s,must=>true,default=>"wan",value=>"{text}",descrip=>"目的区域,多个时使用&分割"
id=>dest_ipgs,name=>目的IP组,type=>s,must=>true,default=>"全部",value=>"{text}",descrip=>"目的IP组,多个时使用&分割"
id=>web_app_port,name=>WEB应用端口,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"Web应用的端口,多个时用'&'分割(最多四个不能重复)"
id=>ftp_port,name=>FTP端口,type=>s,must=>false,default=>"21",value=>"{text}",descrip=>"FTP端口,多个时用'&'分割(最多四个不能重复)"
id=>mysql_port,name=>MYSQL端口,type=>s,must=>false,default=>"3306",value=>"{text}",descrip=>"MYSQL端口,多个时用'&'分割(最多四个不能重复)"
id=>telnet_port,name=>TELNET端口,type=>s,must=>false,default=>"23",value=>"{text}",descrip=>"TELNET端口,多个时用'&'分割(最多四个不能重复)"
id=>ssh_port,name=>SSH端口,type=>s,must=>false,default=>"22",value=>"{text}",descrip=>"SSH端口,多个时用'&'分割(最多四个不能重复)"
id=>web_app_protect,name=>网站攻击防护,type=>s,must=>false,default=>"1&2&3&4&5&6&7&8&9&10",value=>"{text}",descrip=>"网站攻击防护类型,可选的漏洞类型含: 1 系统命令注入,2 SQL 注入,3 XSS 攻击,4 跨站请求伪造,5 目录遍历攻击,6 文件包含攻击,7 信息泄漏攻击,8 WEBSHELL,9 网页木马,10 网站扫描,多个时使用&分割"
id=>is_csrf_protect,name=>启动CSRF功能,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'CSRF'"
id=>csrf_protect_data,name=>CSRF配置数据列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"CSRF配置数据列表,格式为:: '防护域名@;@(域名)启用与否(是|否)@;@防护页面(target)@;@来源页面(refer)@;@(target)启用与否(是|否)...',每个防护域名可以有多个target-refer对,与域名一起用'@;@'号隔开,例 : www.baidu.com:是@;@/target1@;@/refer1@;@是@;@/target2@;@/refer2@;@否 ,多个域名时用&;&隔开"
id=>is_initiative_recovery,name=>启动主动防御功能,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'主动防御功能'"
id=>initiative_recovery_data,name=>主动防御配置数据列表,type=>s,must=>false,default=>"100:76:是:是",value=>"{text}",descrip=>"主动防御配置数据列表,格式为:: '停止学习阀值:重学习阀值:检测攻击后拒绝(是|否):检测攻击后记录日志(是|否)',对应着点开主动防御配置的相应项,例 : 100:90:是:是 ,表示匹配次数是100次停止学习,达到匹配率90开始重学习,检测到攻击后拒绝,并且记录日志"
id=>initiative_recovery_excld_url,name=>主动防御排除URL列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"主动防御排除URL列表,格式为:: 'URL1;URL2;URL3',每个url用分号隔开"
id=>is_restricted_url,name=>启动受限URL防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'受限URL防护'"
id=>restricted_url_data,name=>受限URL防护配置数据列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"受限URL防护配置数据列表,格式为:: '域名@;@启用(是|否)@;@允许访问起始页(页面1$;$页面2$;$页面3)',域名与启用和允许访问起始页是用'@;@'隔开,其中允许访问起始页是用 '$;$' 隔开,例 : www.baidu.com@;@是@;@/admin$;$/admin2 ,表示保护域名www.baidu.com,启用对应规则,允许访问的来源页面是/admin和/admin2, 多个规则之间用&;&号隔开"
id=>is_cookie_protect,name=>启动cookie防篡改,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'cookie防篡改'"
id=>cookie_protect_select,name=>选择cookie防护选项,type=>s,must=>false,default=>"全部",value=>"全部|白名单|黑名单",descrip=>"选择的cookie防护的对象"
id=>cookie_protect_data,name=>cookie防篡改配置参数名,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"cookie防篡改配置参数名,格式为:: '参数名1;参数名2;参数名3',例 : abc;def ,根据前一个选项来确定是白名单还是黑名单的参数名"
id=>is_aet_protect,name=>启动AET防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"勾选启动AET防护"
id=>is_urlparams_protect,name=>启动URL参数防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'URL参数防护'"
id=>urlparams_protect_data,name=>URL参数防护配置数据列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"URL参数防护配置数据列表,格式为:: 'URL:;:启用(是|否):,;:大小写敏感(是|否):;:参数与正则(参数名@;@等于(是|否)@;@参数正则)',例 : '/test.asp:;:是:;:是:;:param@;@是@;@\d+' ,表示保护URL:/test.asp,启用对应规则,匹配的参数名是param,启用对应参数匹配,匹配方式是等于,正则表达式是d+,规则之间用两个&加分号隔开~!!!'&;&',为了避免复杂正则带来的影响"
id=>streng_url,name=>加强防护的URL,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"按加强URL后弹出的添加URL路径列表,格式为: 'URL:Descript',也就是用':'号把URL和描述隔开,多个时用&分割"
id=>hide_ftp,name=>FTP应用隐藏,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'FTP应用隐藏'"
id=>hide_http,name=>HTTP应用隐藏,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'HTTP应用隐藏'"
id=>is_hide_http_head,name=>过滤HTTP响应报文头,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'过滤HTTP响应报文头'"
id=>hide_http_head,name=>报文头类型,type=>s,must=>false,default=>"Server&X-Powered-By",value=>"{text}",descrip=>"过滤的报文头类型,多个时使用&分割"
id=>is_replace_http_error,name=>替换HTTP出错页面,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'替换HTTP出错页面'"
id=>is_ftp_weakpasswd_protect,name=>FTP弱口令防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'FTP弱口令防护'"
id=>ftp_weakpasswd_protect_set,name=>FTP弱口令设置,type=>s,must=>false,default=>"numchar&same&empty",value=>"{text}",descrip=>"FTP弱口令设置类型(empty 空口令, same 用户名密码相同, less 少于8位字典序, num 少于8位纯数字, char 少于8位纯字母, numchar 少于6位仅数字字母 ),多个时使用&分割"
id=>ftp_weakpasswd_protect_list,name=>FTP弱口令列表,type=>s,must=>false,default=>"a&b&c&123",value=>"{text}",descrip=>"FTP弱口令列表,就是界面输入的定义什么密码是弱密码的,多个时使用&分割"
id=>is_passwdburst_protect,name=>口令暴力破解防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'口令暴力破解防护'"
id=>is_ftp_passwdburst_protect,name=>启用FTP暴破防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'启用口令爆破的FTP保护'"
id=>ftp_passwdburst_protect_count,name=>FTP爆破次数,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"所输入的触发FTP爆破防护的次数"
id=>ftp_passwdburst_protect_unit,name=>FTP爆破时间单位,type=>s,must=>false,default=>"分",value=>"分|秒",descrip=>"所选择的FTP爆破时间单位,有'分'或'秒'"
id=>is_pwdweb_weak,name=>启动WEB弱口令防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'WEB弱口令防护'"
id=>is_pwdweb_tran,name=>启动WEB明文传输,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'WEB明文传输'"
id=>is_web_passwdburst_protect,name=>启用WEB登录,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'启用WEB登录'"
id=>web_passwdburst_protect_path,name=>页面路径列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"所输入的web应用防护爆破的路径,多个时以&隔开"
id=>web_passwdburst_protect_count,name=>WEB爆破次数,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"所输入的触发WEB爆破防护的次数"
id=>web_passwdburst_protect_unit,name=>WEB爆破时间单位,type=>s,must=>false,default=>"分",value=>"分|秒",descrip=>"所选择的WEB爆破时间单位,有'分'或'秒'"
id=>is_file_upload_filter,name=>文件上传过滤,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'文件上传过滤'"
id=>file_upload_filter_list,name=>上传文件黑名单列表,type=>s,must=>false,default=>"jsp&asp&exe",value=>"{text}",descrip=>"上传文件黑名单列表,多个时使用&分割"
id=>is_url_protect,name=>URL防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'文件上传过滤'"
id=>url_protect_list,name=>URL防护列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"URL防护列表,每个URL为:'URL:拒绝|允许:记录|不记',来表示此url记录的允许还是拒绝,日志的记录与否,每个含义用:号隔开,例如:'/abc/def:允许:记录'表示/abc/def这个url是允许的并且记录日志,多个URL时使用&分割"
id=>is_proto_unusual,name=>协议异常,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'协议异常'"
id=>is_method_filter,name=>方法过滤,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'方法过滤'"
id=>method_filter_list,name=>允许HTTP方法列表,type=>s,must=>false,default=>"get&post",value=>"{text}",descrip=>"允许HTTP方法列表,多个时使用&分割"
id=>is_url_overflow,name=>启用URL溢出检测,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'启用URL溢出检测'"
id=>url_overflow_maxlenth,name=>URL溢出最大长度,type=>s,must=>false,default=>"1024",value=>"{text}",descrip=>"URL溢出最大长度,数字"
id=>is_post_overflow,name=>启用Post溢出检测,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'启用Post溢出检测'"
id=>post_overflow_maxlenth,name=>Post溢出最大长度,type=>s,must=>false,default=>"2048",value=>"{text}",descrip=>"Post溢出最大长度,数字"
id=>is_http_head_check,name=>启用HTTP头部溢出检测,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'启用HTTP头部溢出检测'"
id=>http_head_check_list,name=>HTTP头部检测字段列表,type=>s,must=>false,default=>"abc:22",value=>"{text}",descrip=>"HTTP头部检测字段列表,'字段:长度' (例子: abc:11),多个用&隔开"
id=>is_susceptive,name=>敏感信息防护,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'敏感信息防护'"
id=>susceptive_way,name=>命中次数统计方式,type=>s,must=>false,default=>"IP",value=>"IP|连接",descrip=>"命中次数统计方式下拉选择框的内容"
id=>susceptive_list,name=>敏感信息列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"敏感信息的列表,格式为:: '组合策略名:最低命中次数:敏感信息名字...',敏感信息名字可以多个,用:号隔开,例 : abc:11:身份证:MD5,多个时用&隔开"
id=>is_file_download_filter,name=>文件下载过滤,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'文件下载过滤'"
id=>file_download_filter_list,name=>防护文件类型列表,type=>s,must=>false,default=>"dat&conf&mdb",value=>"{text}",descrip=>"防护文件类型列表,多个用&隔开[自定义的文件类型必须先在对象定义里定义]"
id=>operation,name=>动作,type=>s,must=>false,default=>"拒绝",value=>"允许|拒绝",descrip=>"拒绝还是允许"
id=>islockip,name=>封锁IP,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'封锁IP'"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用勾选'记录日志'"
id=>issmsalarm,name=>短信告警,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否勾选'发送短信'"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|参数错误",descrip=>""
=end
      def edit_waf_policy(hash={})
        ATT::KeyLog.debug("编辑WAF策略......")
        post_hash = get_edit_waf_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(WAFCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("编辑WAF策略..错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 启禁WEB应用防护
描述: 启禁WEB应用防护
维护人: 王沃伦
参数:
id=>enable_count,name=>操作个数,type=>s,must=>true,default=>"部分操作",value=>"部分操作|全部操作",descrip=>"操作指定名称的WAF策略,还是操作目前所有的WAF策略"
id=>enable_type,name=>操作类型,type=>s,must=>true,default=>"启用",value=>"启用|禁用",descrip=>"指定操作,是启用还是禁用"
id=>names,name=>策略名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当操作类型选择部分操作时,指定要操作的WAF策略名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_waf(hash={})
        ATT::KeyLog.debug("启用或禁用WAF策略......")
        if hash[:enable_count] == "全部操作"
          all_ips_policy_names = DeviceConsole::get_all_object_names(WAFCGI, "WAF策略") # 获取所有IPS策略的名称,数组类型
        else
          all_ips_policy_names = hash[:names].to_s.split("&") # 数组类型
        end
        post_hash = {"opr" => ( hash[:enable_type] == "启用" ? "enable" : "disable"), "name" => all_ips_policy_names }
        result_hash = AF::Login.get_session().post(WAFCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("启用或禁用WAF策略..错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 增加DLP文件类型
描述: 增加DLP文件类型
维护人: 王沃伦
参数:
id=>file_type,name=>文件类型,type=>s,must=>true,default=>"rar",value=>"{text}",descrip=>"自定义的DLP文件下载的文件类型"
id=>discript,name=>描述,type=>s,must=>true,default=>"woolenTest",value=>"{text}",descrip=>"文件类型的描述"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_dlp_filetype(hash={})
        ATT::KeyLog.debug("增加DLP文件类型......")
        post_hash = {"opr" => "add_filetype", "data" =>{"ext" => hash[:file_type], "deps" => hash[:discript]} }
        result_hash = AF::Login.get_session().post(WAFCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("增加DLP文件类型..错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除DLP文件类型
描述: 删除DLP文件类型
维护人: 王沃伦
参数:
id=>file_type,name=>文件类型,type=>s,must=>true,default=>"rar",value=>"{text}",descrip=>"自定义的DLP文件下载的文件类型,多个用&隔开"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def del_dlp_filetype(hash={})
        ATT::KeyLog.debug("删除DLP文件类型......")
        names = hash[:file_type].split("&")
        post_hash = {"opr" => "delete_filetype", "name" =>names }
        result_hash = AF::Login.get_session().post(WAFCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("删除DLP文件类型..错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      
      #end of class Waf
    end
    #don't add any code after here.

  end

end
