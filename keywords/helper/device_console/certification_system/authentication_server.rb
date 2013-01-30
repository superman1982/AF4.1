# coding: utf-8
module DeviceConsole
  module CertificationSystem
    module AuthenticationServerHelper
      #构造LDAP服务器的json数据
        def create_ldap_server_json(hash)
          basic_hash = {"ip" => hash[:ip],"port" => hash[:port].to_i,"timeout" => hash[:timeout].to_i,\
              "basedn" => hash[:basedn]
          }
          advance_hash = {"type" => "","anonymous" => hash[:anonymous].to_logic,"user" => hash[:user],\
              "passwd" => hash[:passwd],"userAttr" => hash[:userAttr],"groupAttr" => hash[:groupAttr],\
              "filter" => hash[:filter],"attr" => hash[:attr]
          }
          if hash[:type] == "MS Active Directory"
            advance_hash["type"] = 0
          elsif hash[:type] == "Open LDAP"
            advance_hash["type"] = 1
          elsif hash[:type] == "SUN LADP"
            advance_hash["type"] = 2
          elsif hash[:type] == "IBM LDAP"
            advance_hash["type"] = 3
          else
            advance_hash["type"] = 4
          end
          morecfg_hash = {"useext" => hash[:useext].to_logic,"pagesize" => hash[:pagesize].to_i,"sizelimits" => hash[:sizelimits].to_i}
          data_hash = {"name" => hash[:name],"basic" => basic_hash,"advance" => advance_hash,"morecfg" => morecfg_hash,"enable" => hash[:enable].to_logic}
          return data_hash
        end
        #获取新增LADP服务器的POST数据
        def get_add_ldap_server_post_hash(hash)
          data_hash = create_ldap_server_json(hash)
          post_hash ={"opr" => "add","type" => "ldap","data" => data_hash}
          return  post_hash
        end
        #获取编辑LADP服务器的POST数据
        def get_edit_ldap_server_post_hash(hash)
          data_hash = create_ldap_server_json(hash)
          post_hash ={"opr" => "modify","type" => "ldap","data" => data_hash}
          return  post_hash
        end
        #构造RADIUS服务器的json数据
        def create_radius_server_json(hash)
          data_hash = {"name" => hash[:name],"basic" => {"ip" => hash[:ip],"port" => hash[:port].to_i,"timeout" => hash[:timeout].to_i,\
                "sharekey" => hash[:sharekey],"protocol" => ""},"enable" => hash[:enable].to_logic}
          if hash[:protocol] == "不加密的协议PAP"
            data_hash["basic"]["protocol"] = "pap"
          elsif hash[:protocol] == "质询握手身份验证协议"
            data_hash["basic"]["protocol"] = "ask"
          elsif hash[:protocol] == "Microsoft CHAP"
            data_hash["basic"]["protocol"] = "chap"
          elsif hash[:protocol] == "Microsoft CHAP2"
            data_hash["basic"]["protocol"] = "chap2"
          else
            data_hash["basic"]["protocol"] = "eap"
          end
          return data_hash
        end
        #获取新增RADIUS服务器的POST数据
        def get_add_radius_server_post_hash(hash)
          data_hash = create_radius_server_json(hash)
          post_hash ={"opr" => "add","type" => "radius","data" => data_hash}
          return  post_hash
        end
        #获取编辑RADIUS服务器的POST数据
        def get_edit_radius_server_post_hash(hash)
          data_hash = create_radius_server_json(hash)
          post_hash ={"opr" => "modify","type" => "radius","data" => data_hash}
          return  post_hash
        end

        #构造POP3服务器的json数据
        def create_pop3_server_json(hash)
          data_hash = {"name" => hash[:name],"basic" => {"ip" => hash[:ip],"port" => hash[:port].to_i,"timeout" => hash[:timeout].to_i,\
              },"enable" => hash[:enable].to_logic}
          return data_hash
        end
        #获取新增POP3服务器的POST数据
        def get_add_pop3_server_post_hash(hash)
          data_hash = create_pop3_server_json(hash)
          post_hash ={"opr" => "add","type" => "pop3","data" => data_hash}
          return  post_hash
        end
        #获取编辑POP3服务器的POST数据
        def get_edit_pop3_server_post_hash(hash)
          data_hash = create_pop3_server_json(hash)
          post_hash ={"opr" => "modify","type" => "pop3","data" => data_hash}
          return  post_hash
        end

    end
  end
end
