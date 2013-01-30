# coding: utf8
module DeviceConsole
  module CertificationSystem
    module UserAuthenticationHelper

      # 获取认证区域的名称,返回数组
      def get_id_array_of_zones( zones )
        zone_array = zones.split("&")
        hash_info_of_zones = DeviceConsole::list_all_objects(UserAuthenticateZoneCGI, "认证区域")
        zone_id_array = []

        zone_array.each do |zone_str|
          zone_id = -1 # zone_str 对应的zone 的id
          hash_info_of_zones.each do |one_zone_info|
            if zone_str == one_zone_info["name"]
              zone_id = one_zone_info["id"] # 整型
              break
            end
          end
          if zone_id == -1
            ATT::KeyLog.debug("认证区域:#{zone_str}不存在")
            return_fail("认证区域不存在")
          end
          zone_id_array << zone_id
        end
        ATT::KeyLog.debug("认证区域:#{zones}的id:#{zone_id_array.join(',')}")
        return zone_id_array
      end
      #构造用户认证策略的json数据
      def create_authenticate_rule_post_hash(hash)
        ip_mac = ""
        ip_mac = hash[:ipmac].split("&").join("\r\n").gsub(':','-')
        authway_hash = {"selectway" => "","noauth" => "","pwauth" => "","singleauth" => ""}
        authway_hash["noauth"] = {"selectuser" => "","ip2user" => false,"mac2user" => false,"pc2user" => false,\
            "enable" => false
        }
        if hash[:noauth] == "把IP作为用户名"
          authway_hash["noauth"]["selectuser"] = "ip2user"
          authway_hash["noauth"]["ip2user"] = true
        elsif hash[:noauth] == "把MAC作为用户名"
          authway_hash["noauth"]["selectuser"] = "mac2user"
          authway_hash["noauth"]["mac2user"] = true
        else
          authway_hash["noauth"]["selectuser"] = "pc2user"
          authway_hash["noauth"]["pc2user"] = true
        end
        authway_hash["pwauth"] = {"enable" => false}
        authway_hash["singleauth"] = {"exceptuser" => "","enable" => false}
        authway_hash["singleauth"]["exceptuser"] = hash[:exceptuser].split("&").join(",")
        if hash[:authway] == "不需要认证/单点登录"
          authway_hash["selectway"] = "noauth"
          authway_hash["noauth"]["enable"] = true
        elsif hash[:authway] == "本地密码认证/外部密码认证/单点登录"
          authway_hash["selectway"] = "pwauth"
          authway_hash["pwauth"]["enable"] = true
        else
          authway_hash["selectway"] = "singleauth"
          authway_hash["singleauth"]["enable"] = true
        end
        newoption_hash = {"selectnewuser" => "","add2local" => "","snapuser" => "","forbidlogin" => false}
        newoption_hash["add2local"] = {"path" => hash[:path],"auto" => {"enable" => hash[:auto].to_logic},\
            "other" => {"publiclimit" => {"selectaccount" => "","public" => false,"private" => false},\
              "ipmaclimit" => {"select" => "","ip" => false,"mac" => false,"ipmac" => false,\
                "ipmac_bind" => {"select" => "","bind" => false,"restrict" => false,},"enable" => hash[:ipmaclimit].to_logic}
          },"enable" => false
        }
        newoption_hash["snapuser"] = {"rightpath" => hash[:rightpath],"enable" => false}
        if hash[:newoption] == "添加到指定的本地组中"
          newoption_hash["selectnewuser"] = "add2local"
          newoption_hash["add2local"]["enable"] = true
        elsif hash[:newoption] == "仅作为临时帐号"
          newoption_hash["selectnewuser"] = "snapuser"
          newoption_hash["snapuser"]["enable"] = true
        else
          newoption_hash["selectnewuser"] = "forbidlogin"
          newoption_hash["forbidlogin"] = "true"
        end
        if hash[:publiclimit] =="允许多人同时使用"
          newoption_hash["add2local"]["other"]["publiclimit"]["selectaccount"] = "public"
          newoption_hash["add2local"]["other"]["publiclimit"]["public"] = true
        else
          newoption_hash["add2local"]["other"]["publiclimit"]["selectaccount"] = "private"
          newoption_hash["add2local"]["other"]["publiclimit"]["private"] = true
        end
        if hash[:select] == "仅绑定IP"
          newoption_hash["add2local"]["other"]["ipmaclimit"]["select"] = "ip"
          newoption_hash["add2local"]["other"]["ipmaclimit"]["ip"] = true
        elsif hash[:select] == "仅绑定MAC"
          newoption_hash["add2local"]["other"]["ipmaclimit"]["select"] = "mac"
          newoption_hash["add2local"]["other"]["ipmaclimit"]["mac"] = true
        else
          newoption_hash["add2local"]["other"]["ipmaclimit"]["select"] = "ipmac"
          newoption_hash["add2local"]["other"]["ipmaclimit"]["ipmac"] = true
        end
        if hash[:ipmac_bind] == "双向绑定"
          newoption_hash["add2local"]["other"]["ipmaclimit"]["ipmac_bind"]["select"] = "bind"
          newoption_hash["add2local"]["other"]["ipmaclimit"]["ipmac_bind"]["bind"] = true
        else
          newoption_hash["add2local"]["other"]["ipmaclimit"]["ipmac_bind"]["select"] = "restrict"
          newoption_hash["add2local"]["other"]["ipmaclimit"]["ipmac_bind"]["restrict"] = true
        end
        data_hash = {"name" => hash[:name],"depict" => hash[:description],"ipmac" => ip_mac,"authway" => authway_hash,\
            "newoption" => newoption_hash}
        return data_hash
      end
      #获取新增用户认证策略的POST数据
      def get_add_authenticate_rule_post_hash(hash)
        data_hash = create_authenticate_rule_post_hash(hash)
        post_hash = {"opr" => "add", "data" => data_hash}
        return post_hash
      end
      #获取编辑用户认证策略的POST数据
      def get_edit_authenticate_rule_post_hash(hash)
        data_hash = create_authenticate_rule_post_hash(hash)
        post_hash = {"opr" => "modify", "data" => data_hash}
        return post_hash
      end
      #获取编辑用户认证选项的POST数据
      def get_edit_authenticate_option_post_hash(hash)
        domain_hash = {"component" => {"sharekey" => hash[:sharekey],"enable" => hash[:auto].to_logic},\
            "monitor" => {"server" => "","enable" => hash[:listen]},"enable" => hash[:enable_domain].to_logic}
        domain_hash["monitor"]["server"] = hash[:domain_server].split("&").join("\n")
        proxy_hash = {"server" => "","enable" => hash[:enable_proxy].to_logic}
        proxy_hash["server"] = hash[:proxy_server].split("&").join("\n")
        pop3_hash = {"server" => "","enable" =>hash[:enable_pop3].to_logic}
        pop3_hash["server"] = hash[:pop3_server].split("&").join("\n")
        web_hash = {"server" => hash[:web_server],"server_opt" => {"direct" => hash[:server_opt].to_logic},\
            "form" => hash[:form],"keyword" => "","success" => {"keyword" => "","enable" => false},\
            "failure" => {"keyword" => "","enable" => false},"enable" => hash[:enable_web].to_logic
        }
        web_hash["success"]["keyword"] = hash[:success]
        web_hash["failure"]["keyword"] = hash[:failure]
        if hash[:keyword_opt] == "认证成功关键字"
          web_hash["keyword"] = "success"
          web_hash["success"]["enable"] = true
        else
          web_hash["keyword"] = "failure"
          web_hash["failure"]["enable"] = true
        end
        other_hash = {"mirror" => {"inf" => [],"enable" => hash[:enable_mirror].to_logic}}
        other_hash["mirror"]["inf"] = hash[:mirror_list].split("&")
        data_hash = {"sso" => {"domain" => domain_hash,"proxy" => proxy_hash,"pop3" => pop3_hash,"web" => web_hash,\
              "other" => other_hash},"jump" => "","recent" => false,"logout" => false,"custom" => {"url" => "","enable" => false},\
            "conflict" => "","force" => false,"alert" => false,"snmp" => {"timeout" => hash[:timeout].to_i,"interval" => hash[:interval].to_i,\
              "server" => "","enable" => hash[:enable_snmp].to_logic
          },"other" => {"autologout" => {"logout" => hash[:logout_time],"enable" => hash[:enable_autologout].to_logic},\
              "post" => hash[:post].to_logic,"dns" => hash[:dns].to_logic,"base" => hash[:base].to_logic,"chkmac" => hash[:chkmac].to_logic,\
              "authfail" => {"times" => hash[:times].to_i,"minutes" => hash[:minutes].to_i,"enable" => hash[:authfail].to_logic}
          }
        }
        if hash[:jump] == "最近请求的页面"
          data_hash["jump"] = "recent"
          data_hash["recent"] = true
        elsif hash[:jump] == "注销页面"
          data_hash["jump"] = "logout"
          data_hash["logout"] = true
        else
          data_hash["jump"] = "custom"
          data_hash["custom"]["enable"] = true
        end
        data_hash["custom"]["url"] = hash[:custom_url]
        if hash[:conflict] == "强制注销以前的登录，在当前IP上认证通过"
          data_hash[:conflict] = "force"
          data_hash[:force] = true
        else
          data_hash[:conflict] = "alert"
          data_hash[:alert] = true
        end
        data_hash["snmp"]["server"] = hash[:server_snmp].split("&").join("\n")
        post_hash = {"opr" => "submit","data" => data_hash}
        return post_hash
      end
      #获取所有的认证策略名称列表
      def get_all_authenticate_names
        all_authenticate_names = []
        post_hash = {"opr" => "listPolicy"}
        result_hash = AF::Login.get_session().post(UserAuthenticateCGI, post_hash)
        if result_hash["success"]
          result_hash["data"].each do |object|
            if object["name"] != "默认策略"
              all_authenticate_names << object["name"]
            end
          end
          return all_authenticate_names
        else
          ATT::KeyLog.info("获取用户认证策略列表失败,错误消息是#{result_hash["msg"]}")
          raise ATT::Exceptions::NotFoundError,"获取列表失败"
        end
      end








    end
  end
end
