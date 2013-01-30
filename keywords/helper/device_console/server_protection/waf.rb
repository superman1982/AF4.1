# coding: utf8
module DeviceConsole
  module ServerProtection
    module WafHelper
      # 新增WAF策略时要post的数据
      def get_add_waf_rule_post_hash( hash )
        data_hash = get_add_and_edit_waf_rule_common_post_hash( hash )

        post_hash = {"opr" => "add", "data" => data_hash}
        return post_hash
      end

      # 编辑WAF策略时要post的数据
      def get_edit_waf_rule_post_hash( hash )
        data_hash = get_add_and_edit_waf_rule_common_post_hash( hash )
        post_hash = {"opr" => "modify", "oldName" => hash[:oldname], "data" => data_hash}
        return post_hash
      end

      # 新增或编辑WAF策略时要post的公共数据,jason树的第一层
      def get_add_and_edit_waf_rule_common_post_hash( hash )
        if(hash[:name] == "")
          hash[:name] = hash[:oldname]
        end
        data_hash = {}
        data_hash["bypass_eths"] = ""
        data_hash["all_zone"] = hash[:source_zone].gsub(/&/, ",") + "," + hash[:dest_zone].gsub(/&/, ",")
        data_hash["name"] = hash[:name]
        data_hash["desc"] = hash[:description]
        data_hash["src"] = { "src_zone" => hash[:source_zone].gsub(/&/, ",") }
        data_hash["dst"] = { "dst_zone" => hash[:dest_zone].gsub(/&/, ","), "dst_ipg" => hash[:dest_ipgs].gsub(/&/, ","),
          "port" => { "web" => hash[:web_app_port].gsub(/&/,","),"ftp" => hash[:ftp_port].gsub(/&/,","), "mysql" => hash[:mysql_port].gsub(/&/,","), "telnet" => hash[:telnet_port].gsub(/&/,","), "ssh" => hash[:ssh_port].gsub(/&/,",") } }
		
        data_hash["option"] = get_option(hash)
        data_hash["dlp"] = get_dlp(hash)
        data_hash["opr"] = get_opr(hash)
        data_hash["enable"] = hash[:enable].to_logic

        return data_hash
      end

      # => 这里获得OPTION,也就是界面的安全配置相关的数据
      def get_option( hash )
        result_hash = {}
        result_hash["bug_list"] = {}
        result_hash["bug_list"]["value"] = get_web_attack_protect(hash[:web_app_protect])
        result_hash["bug_list"]["select"] = "0"
        # => 这里是4.0添加的内容，添加了csrf，initiative_recovery，cookie，url，aet
        
        # => CSRF
        result_hash["csrf"] = (hash[:is_csrf_protect] == "是")
        result_hash["csrf_set"] = {}
        result_hash["csrf_set"]["array"] = []
        ATT::KeyLog.info("CSRF begin array ~~")
        hash[:csrf_protect_data].split("&;&").each do |one_csrf_data|
          one_csrf_data_hash = {}
          one_csrf_data_array = one_csrf_data.split("@;@")
          if((one_csrf_data_array.length - 2) % 3 != 0)
            ATT::KeyLog.error("输入的CSRF参数个数不对~~")
            return_fail
          end
          # => 这里完成了对csrf相关数据部分的设置
          one_csrf_data_hash["name"] = one_csrf_data_array[0]
          one_csrf_data_hash["status"] = one_csrf_data_array[1] == "是" ? 1 : 0
          one_csrf_data_hash["target"] = []
          i = 0
          while ( i+4 < one_csrf_data_array.length )
            one_target_data_hash = {}
            one_target_data_hash["target"] = one_csrf_data_array[2+i]
            one_target_data_hash["referer"] = one_csrf_data_array[3+i]
            one_target_data_hash["status"] = one_csrf_data_array[4+i] == "是" ? 1 : 0
            i += 3
            ATT::KeyLog.info("csrf hash::")
            ATT::KeyLog.info(one_target_data_hash)
            one_csrf_data_hash["target"] << one_target_data_hash
          end
          result_hash["csrf_set"]["array"] << one_csrf_data_hash
        end
        ATT::KeyLog.debug("CSRF OK~~")
        
        # => 主动防御 initiative_recovery
        result_hash["website_attack"] = []
        result_hash["website_attack"] << "initiative_recovery"
        result_hash["initiative_recovery"] = hash[:is_initiative_recovery] == "是"
        result_hash["initiative_set"] = {}
        result_hash["initiative_set"]["tbar"] = {}
        result_hash["initiative_set"]["tbar"]["setting"] = {}
        result_hash["initiative_set"]["tbar"]["setting"]["stop"] = {}
        result_hash["initiative_set"]["tbar"]["setting"]["stop"]["url"] = hash[:initiative_recovery_data].split(":")[0].to_i
        result_hash["initiative_set"]["tbar"]["setting"]["restart"] = {}
        result_hash["initiative_set"]["tbar"]["setting"]["restart"]["var"] = hash[:initiative_recovery_data].split(":")[1].to_i
        result_hash["initiative_set"]["tbar"]["setting"]["option"] = {}
        result_hash["initiative_set"]["tbar"]["setting"]["option"]["checkboxgroup"] = []
        if hash[:initiative_recovery_data].split(":")[2] == "是"
          result_hash["initiative_set"]["tbar"]["setting"]["option"]["deny"] = true
          result_hash["initiative_set"]["tbar"]["setting"]["option"]["checkboxgroup"] << "deny"
        end
        if hash[:initiative_recovery_data].split(":")[3] == "是"
          result_hash["initiative_set"]["tbar"]["setting"]["option"]["log"] = true
          result_hash["initiative_set"]["tbar"]["setting"]["option"]["checkboxgroup"] << "log"
        end
        result_hash["initiative_set"]["tbar"]["excld"] = {}
        result_hash["initiative_set"]["tbar"]["excld"]["url"] = hash[:initiative_recovery_excld_url].gsub(";", "\n")
        ATT::KeyLog.debug("主动防御 OK~~")
        
        # => 启动受限URL防护
        result_hash["restricted"] = hash[:is_restricted_url] == "是"
        result_hash["restricted_set"] = {}
        result_hash["restricted_set"]["array"] = []
        hash[:restricted_url_data].split("&;&").each do |one_restricted_url|
          one_restricted_url_array = one_restricted_url.split("@;@")
          one_restricted_url_hash = {}
          one_restricted_url_hash["name"] = one_restricted_url_array[0]
          one_restricted_url_hash["status"] = one_restricted_url_array[1] == "是"
          one_restricted_url_hash["defaultpage"] = one_restricted_url_array[2].gsub("$;$", "\n")
          result_hash["restricted_set"]["array"] << one_restricted_url_hash
        end
        ATT::KeyLog.debug("启动受限URL防护 OK~~")
        
        # => cookie防篡改
        result_hash["cookie"] = hash[:is_cookie_protect] == "是"
        result_hash["cookie_set"] = {}
        result_hash["cookie_set"]["no"] = {"enable" => false} 
        result_hash["cookie_set"]["all"] = {"enable" => false}
        result_hash["cookie_set"]["yes"] = {"enable" => false}
        case hash[:cookie_protect_select]
        when "全部"
          result_hash["cookie_set"]["all"]["enable"] = true
        when "白名单"
          result_hash["cookie_set"]["no"]["enable"] = true
          result_hash["cookie_set"]["no"]["name"] = hash[:cookie_protect_data].gsub(";", "\n")
        when "黑名单"
          result_hash["cookie_set"]["yes"]["enable"] = true
          result_hash["cookie_set"]["yes"]["name"] = hash[:cookie_protect_data].gsub(";", "\n")
        else
          ATT::KeyLog.error("我靠,cookie防篡改部分参数输入错了~~")
        end
        ATT::KeyLog.debug("cookie防篡改 OK~~")
        
        # => AET功能
        result_hash["aet"] = hash[:is_aet_protect] == "是"
        
        # => 参数防护
        result_hash["urlparams"] = hash[:is_urlparams_protect] == "是"
        result_hash["urlparams_set"] = {}
        result_hash["urlparams_set"]["array"] = []
        hash[:urlparams_protect_data].split("&;&").each do |one_urlparams_protect_data|
          one_urlparams_protect_hash = {}
          one_urlparams_protect_array = one_urlparams_protect_data.split(":;:")
          one_urlparams_protect_hash["name"] = one_urlparams_protect_array[0]
          one_urlparams_protect_hash["status"] = one_urlparams_protect_array[1] == "是"
          one_urlparams_protect_hash["case"] = one_urlparams_protect_array[2] == "是"
          one_urlparams_protect_hash["params"] = []
          one_param_match_array = one_urlparams_protect_array[3].split("@;@")
          ATT::KeyLog.debug("参数部分内容::\n#{one_param_match_array}")
          if one_param_match_array.length % 3 != 0
            ATT::KeyLog.error("我靠,URL参数防护对应的部分错了~~")
          end
          count = 0
          while (count + 2 < one_param_match_array.length)
            param_match_hash = {}
            param_match_hash["name"] = one_param_match_array[0 + count]
            param_match_hash["match"] = one_param_match_array[1 + count] == "是"
            param_match_hash["regex"] = one_param_match_array[2 + count]
            count += 3
            one_urlparams_protect_hash["params"] << param_match_hash
          end
          result_hash["urlparams_set"]["array"] << one_urlparams_protect_hash
        end
        ATT::KeyLog.debug("参数防护 OK~~")
        
        # => 加强URL
        result_hash["streng_url"] = get_streng_url(hash[:streng_url])
        result_hash["hide"] = []
        
        # => 这里是"应用隐藏"相关数据
        if hash[:hide_ftp] == "是"
          result_hash["hide"] << "apphide"
          result_hash["apphide"] = true
        end
        if hash[:hide_http] == "是"
          result_hash["hide"] << "websitehide"
          result_hash["websitehide"] = true
        end
        result_hash["appset"] = { "ssh" => {"enable" => true}, "telnet" => {"enable" => true}, "ftp" => {"enable" => true} }
        web_head_type = get_web_type(hash[:hide_http_head],true)
        result_hash["webset"] = { "head" => { "type" => web_head_type, "enable" => (hash[:is_hide_http_head] == "是") }, "error" => (hash[:is_replace_http_error] == "是")}
        
        # => 这里是"口令防护"相关数据
        result_hash["password"] = []
        if hash[:is_ftp_weakpasswd_protect] == "是"
          result_hash["password"] << "lowpwd"
          result_hash["lowpwd"] = true
        end
        if hash[:is_passwdburst_protect] == "是"
          result_hash["password"] << "pwdcrack"
          result_hash["pwdcrack"] = true
        end
        if hash[:is_pwdweb_weak] == "是"
          result_hash["password"] << "pwdweb_weak"
          result_hash["pwdweb_weak"] = true
        end
        if hash[:is_pwdweb_tran] == "是"
          result_hash["password"] << "pwdweb_tran"
          result_hash["pwdweb_tran"] = true
        end
        setting = get_ftp_weakpasswd_protect_set(hash[:ftp_weakpasswd_protect_set])
        setting["list"] = hash[:ftp_weakpasswd_protect_list].gsub(/&/, "\n")
        result_hash["lpwdset"] = { "app" => { "telnet" => true, "ftp" => true, "mysql" => true}, "setting" => setting }
        time_unit = {"分" => 1, "秒" => 0}
        ftptimes = { "unit" => time_unit[hash[:ftp_passwdburst_protect_unit]] , "times" => hash[:ftp_passwdburst_protect_count].to_i }
        webtimes = { "unit" => time_unit[hash[:web_passwdburst_protect_unit]] , "times" => hash[:web_passwdburst_protect_count].to_i }
        result_hash["cpwdset"] = { "app" => { "telnet" => { "enable" => true }, "ftp" => { "enable" => (hash[:is_ftp_passwdburst_protect] == "是") }, "mysql" => { "enable" => true }, 
            "ftptimes" => ftptimes }, "setting" => {"settingtimes" => webtimes, "enable" =>(hash[:is_web_passwdburst_protect] == "是"), "list" => hash[:web_passwdburst_protect_path].gsub(/&/, "\n") } }
        
        # => 这里是"权限控制"相关数据
        result_hash["permission"] = []
        if hash[:is_file_upload_filter] == "是"
          result_hash["permission"] << "filefilter"
          result_hash["filefilter"] = true
        end
        if hash[:is_url_protect] == "是"
          result_hash["permission"] << "url"
          result_hash["url"] = true
        end
        types = get_web_type(hash[:file_upload_filter_list] , result_hash["filefilter"] )
        result_hash["ftypeset"] = { "type" => types}
        datas = []
        ( hash[:url_protect_list].split("&") ).each do |urls|
          url = urls.split(":")[0]
          action = urls.split(":")[1] == "允许"
          log = urls.split(":")[2] == "记录"
          datas << { "url" => url , "deps" => "woolenAuto", "action" => action, "log" => log}
        end
        urlarray = { "data" => datas, "default_url" => { "action" => 1, "log" => 1}, }
        result_hash["urlset"] = { "array" => urlarray}
        
        # => 这里是"http异常检测"相关数据
        result_hash["exception"] = []
        if hash[:is_proto_unusual] == "是"
          result_hash["exception"] << "protocol"
          result_hash["protocol"] = true
        end
        if hash[:is_method_filter] == "是"
          result_hash["exception"] << "method"
          result_hash["method"] = true
        end
        methods_filter = {}  #方法过滤
        ( hash[:method_filter_list].split("&") ).each do |method_filter_list|
          methods_filter[method_filter_list] = 1
        end      # => 这里有问题的,我没有填没有选择的数据(等于0的项)上去,不知道会怎么样
        result_hash["httpset"] = {"method" => methods_filter}
        
        # => 缓冲区溢出 相关数据
        http_overflow_list = []
        hash[:http_head_check_list].split("&").each do |http_head_check_list|
          http_head_check_array = http_head_check_list.split(":")
          http_overflow_list << { "name" => http_head_check_array[0], "header_length" => http_head_check_array[1].to_i }
        end
        result_hash["buf_overflow"] = { "http" => { "array" => http_overflow_list, "enable" => ( hash[:is_http_head_check] == "是" )}, 
          "url" => {"url_length" => hash[:url_overflow_maxlenth].to_i, "enable" => (hash[:is_url_overflow] == "是") }, 
          "entity" => { "entity_length" => hash[:post_overflow_maxlenth].to_i, "enable" => (hash[:is_post_overflow] == "是")}
        }
        
        return result_hash
      end
      
      # => 这里是DLP相关数据的获得,也就是界面数据防泄密的相关数据
      def get_dlp(hash)
        result_hash = {}
        result_hash["hide"] = []
        result_hash["hide"] << "src_code"  #这里应该是留待添加的功能
        result_hash["src_code"] = true
        if hash[:is_susceptive] == "是"
          result_hash["hide"] << "susceptive"
          result_hash["susceptive"] = true
        end
        if hash[:is_file_download_filter] == "是"
          result_hash["hide"] << "filedownload"
          result_hash["filedownload"] = true
        end
        
        # => 这里主要就是敏感信息防护的相关数据
        susceptive_array = []
        hash[:susceptive_list].split("&").each do |susceptive_list_str|
          tmp_id = 0
          tmp_names = []
          tmp_array_hash = {}
          test_hash = { "身份证" => 1, "MD5" => 1, "手机号码" => 1, "银行卡号" => 1, "邮箱" => 1}
          susceptive_list_str.split(":").each do |susceptive_tmp|
            if tmp_id == 0
              tmp_array_hash["dlps_name"] = susceptive_tmp
            elsif tmp_id == 1
              tmp_array_hash["hit"] = susceptive_tmp.to_i
              tmp_array_hash["deps"] = "woolenTest"
            else 
              tmp_names << { "inside" => (test_hash[susceptive_tmp] == 1), "name" => susceptive_tmp, "id" => tmp_id-2 } #这里坑爹的,ID全是0的
            end
            tmp_id += 1
          end
          tmp_array_hash["name"] = tmp_names
          susceptive_array << tmp_array_hash
        end
        result_hash["susceptiveset"] = {"array" => susceptive_array}
        
        if hash[:susceptive_way] == "IP"
          result_hash["susceptiveset"]["hit"] = 1
        else
          result_hash["susceptiveset"]["hit"] = 2
        end
        
        # => 这里主要就是文件下载的相关数据
        filedownload_array = []
        test_hash = { "dat" => 1, "bak" => 1, "dmp" => 1, "old" => 1, "backup" => 1, "asa" => 1, "log" => 1, "fp" => 1, "frx" => 1, "frt" => 1, "ora" => 1,
          "ctl" => 1, "dbf" => 1, "arc" => 1, "trc" => 1, "trm" => 1, "ndf" => 1, "ldf" => 1, "sql" => 1, "myd" => 1, "myi" => 1, "frm" => 1, "cnf" => 1,
          "mdb" => 1, "mde" => 1, "ade" => 1, "mda" => 1, "mdw" => 1, "ldb" => 1, "db" => 1, "conf" => 1, "lock" => 1, "pid" => 1, "config" => 1, "rpb" => 1,
          "ini" => 1, "bat" => 1, "cfg" => 1, "passwd" => 1, "java" => 1, "class" => 1, "cs" => 1, "tmp" => 1, "resx" => 1 }
        hash[:file_download_filter_list].split("&").each do |filedownload_list_str|
          tmp_array_hash = {}
          
          tmp_array_hash["name"] = filedownload_list_str
          tmp_array_hash["inside"] = ( test_hash[filedownload_list_str] == 1)
          filedownload_array << tmp_array_hash
        end
        result_hash["filedownloadset"] = {"array" => filedownload_array}
        return result_hash
      end
      
      # => 这里是操作相关的数据
      def get_opr(hash)
        result_hash = {"isaccept" => "", "accept" => false, "block" => false, "isloglabel" => [], 
          "record" =>  false ,"logset" => {"log_state" => {"state" => "","enable" => false}},"issmsalarm" => [], "send" => { "enable" => false }, "islockip" => [] , "islock" => { "enable" => false }}
        if hash[:operation] == "拒绝"
          result_hash["block"] = true
          result_hash["isaccept"] = "block"
        else
          result_hash["accept"] = true
          result_hash["isaccept"] = "accept"
        end
        if hash[:islockip] == "是"
          result_hash["islockip"] << "islock"
          result_hash["islock"]["enable"] = true
        end
        if hash[:record_log] == "是"
          result_hash["isloglabel"] << "record"
          result_hash["record"] = true
        end
        if hash[:state_enable] == "是"
          result_hash["logset"]["log_state"]["enable"] = true
        end
        result_hash["logset"]["log_state"]["state"] = hash[:state_num]
        if hash[:issmsalarm] == "是"
          result_hash["issmsalarm"] << "send"
          result_hash["send"]["enable"] = true
        end
        return result_hash
      end
    
      def get_web_type(head_types , is_custom)
        result_array = []
        id = 0
        head_types_array = head_types.split("&")
        head_types_array.each do |head_type|
          result_array << { "name" => head_type, "custom" => is_custom, "id" => id }
          id += 1
        end
        return result_array
      end
    
      #FTP弱口令设置类型(empty 空口令, same 用户名密码相同, less 少于8位字典序, num 少于8位纯数字, char 少于8位纯字母, numchar 少于6位仅数字字母 )
      def get_ftp_weakpasswd_protect_set(ftp_weakpasswd_protect_set_str)
        result_hash = {}
        ftp_weakpasswd_protect_set_array = ftp_weakpasswd_protect_set_str.split("&")
        ftp_weakpasswd_protect_set_array.each do |ftp_weakpasswd_protect_set|
          result_hash[ftp_weakpasswd_protect_set] = true ;
        end
        return result_hash
      end
      
      # streng_url的格式是 URL:DEPS & URL2:DEPS2
      def get_streng_url( streng_urls )
        result_array = []
        streng_url_array = streng_urls.split("&")
        streng_url_array.each do |streng_url_type|
          streng_url_type_array = streng_url_type.split(":")
          tmp_hash = {"name" => streng_url_type_array[0], "deps" => (streng_url_type_array[1]===nil ? "" :  streng_url_type_array[1]) }
          result_array << tmp_hash
        end
        return result_array
      end
	  
      #根据ID的数组获得整个Hash结构
      def get_web_attack_protect ( web_app_protect )
        result_array = []
        web_app_protect_id_array = web_app_protect.split("&")
        web_app_protect_id_array.each do |web_app_protect_id|
          web_app_protect_name = web_app_protect_id.to_web_app_protect_name
          tmp_hash = {"id" => web_app_protect_id, "name" => web_app_protect_name}
          result_array << tmp_hash
        end
        return result_array
      end
    end
  end
end
