# coding: utf8
module DeviceConsole
  module FireWall
    module AddressTranslationHelper

      # 获取新增源地址转换时要post的hash
      def get_add_source_address_translation_post_hash( hash )
        status_hash = add_and_edit_snat_common_post_hash( hash ) # 新建和编辑源地址转换公共的post_hash
        
        post_hash = {"opr" => "add", "data" => { "status" => status_hash }}
        return post_hash
      end
      # 获取编辑源地址转换时要post的hash
      def get_edit_source_address_translation_post_hash( hash )
        status_hash = add_and_edit_snat_common_post_hash( hash ) # 新建和编辑源地址转换公共的post_hash
        post_hash = {"opr" => "modify","oldName" => hash[:name],"data" => { "status" => status_hash }}
        return post_hash
      end
      # 新建和编辑源地址转换公共的post_hash
      def add_and_edit_snat_common_post_hash( hash )
        if(hash[:newname] == "")
            hash[:newname] = hash[:name]
        end
        src_hash = { "src_zone" => hash[:source_zone].split("&").join(","), "src_ipg" => hash[:source_ipgs].split("&").join(",")}

        dst_hash = {"area_if" => "", "zone" => { "dst_zone" => "", "enable" => false}, "dst_if" => { "if" => "eth0", "enable" => false }, "ipg" => "" }
        if hash[:destination] == "区域"
          dst_hash["area_if"] = "zone"
          dst_hash["zone"]["dst_zone"] = hash[:dest_zone].split("&").join(",")
          dst_hash["zone"]["enable"] = true
        else
          dst_hash["area_if"] = "dst_if"
          dst_hash["dst_if"]["if"] = hash[:dest_interface]
          dst_hash["dst_if"]["enable"] = true
        end
        dst_hash["ipg"] = hash[:dest_ipgs].split("&").join(",")

        protype = convert_protocol_type(hash[:protocol_type])
        pronum = convert_protocol_num(protype, hash[:protocol_num])
        protocol_hash = { "protype" => protype, "pronum" => pronum }
        protocol_hash["src_port"] = ""
        protocol_hash["src_all"] = {"enable" => false}
        protocol_hash["src_spec"] = {"enable" => false, "src_spec" => "1"}
        protocol_hash["dst_port"] = ""
        protocol_hash["dst_all"] = {"enable" => false}
        protocol_hash["dst_spec"] = {"enable" => false, "dst_spec" => "1"}
        # 源端口
        if hash[:source_port] == "所有端口" # 所有端口|指定端口
          protocol_hash["src_port"] = "src_all"
          protocol_hash["src_all"]["enable"] = true
        else
          protocol_hash["src_port"] = "src_spec"
          protocol_hash["src_spec"]["enable"] = true
          protocol_hash["src_spec"]["src_spec"] = hash[:s_port]
        end
        # 目的端口
        if hash[:dest_port] == "所有端口" # 所有端口|指定端口
          protocol_hash["dst_port"] = "dst_all"
          protocol_hash["dst_all"]["enable"] = true
        else
          protocol_hash["dst_port"] = "dst_spec"
          protocol_hash["dst_spec"]["enable"] = true
          protocol_hash["dst_spec"]["dst_spec"] = hash[:d_port]
        end
        # 源地址转换为
        srctr_hash = {"trmode" => "addr_oif", "src_min" => "", "src_max" => "", "src_specip" => "" }
        if hash[:translation_as] == "IP范围" # 出接口地址|IP范围|指定IP|不转换
          srctr_hash["trmode"] = "addr_ipg"
          srctr_hash["src_min"] = hash[:ip_scope].split("-")[0].to_s
          srctr_hash["src_max"] = hash[:ip_scope].split("-")[1].to_s
        elsif hash[:translation_as] == "指定IP"
          srctr_hash["trmode"] = "specip"
          srctr_hash["src_specip"] = hash[:one_ip]
        elsif hash[:translation_as] == "不转换"
          srctr_hash["trmode"] = "addr_notr"
        end

        status_hash = { "type" => "0", "name" => "#{hash[:name]}", "desc" => "#{hash[:description]}", "enable" => hash[:enable].to_logic}
        status_hash["src"] = src_hash
        status_hash["dst"] = dst_hash
        status_hash["protocol"] = { "setting" => protocol_hash }
        status_hash["srctr"] = srctr_hash
        return status_hash
      end
      # 转换协议类型
      def convert_protocol_type( protocol_type ) # 所有协议|TCP|UDP|ICMP|TCPUDP|IP
        tmp_hash = {"所有协议" => "0", "TCP" => "6", "UDP" => "17", "ICMP" => "1", "TCPUDP" => "6,17", "IP" => "4"}
        return tmp_hash["#{protocol_type}"] if tmp_hash.has_key?("#{protocol_type}")
        return_fail("不存在的协议类型")
      end
      # 转换协议号
      def convert_protocol_num(protype, protocol_num)
        if protype == "0"
          return ""
        elsif protype == "6" || protype == "17" || protype == "1" || protype == "6,17"
          return protype
        elsif protype == "4"
          return "#{protocol_num}"
        end
      end

      # 获取所有地址转换规则的名称
      def get_all_address_translation_names
        names = [] # 存放所有地址转换规则的名称
        all_address_translations = DeviceConsole::list_all_objects_with_limit(NetworkAddressTransCGI,"地址转换规则") # list_all_address_translations
        all_address_translations.each do |address_translation|
          names << address_translation["name"]
        end
        ATT::KeyLog.debug("所有地址转换规则的名称:#{names.join(',')}")
        return names
      end
=begin
      # 获取所有地址转换规则列表,返回数组,元素类型是hash
      def list_all_address_translations
        post_hash = {"opr" => "list", "start" => 0, "limit" => 65535}
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          return result_hash["data"] # 数组的元素类型是hash
        else
          ATT::KeyLog.info("获取地址转换规则列表失败,错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=end
      # 获取新增目的地址转换时要post的hash
      def get_add_destination_address_translation_post_hash( hash )
        status_hash = add_and_edit_dnat_common_post_hash( hash ) # 新建和编辑目的地址转换规则,公共的post_hash
        
        post_hash = {"opr" => "add", "data" => { "status" => status_hash }}
        return post_hash
      end
      # 获取编辑目的地址转换时要post的hash
      def get_edit_destination_address_translation_post_hash( hash )
        status_hash = add_and_edit_dnat_common_post_hash( hash )
        unless hash[:newname].to_s.empty? # 编辑时,可能会修改名称
          status_hash["name"] = "#{hash[:newname]}"
        end

        post_hash = {"opr" => "modify", "data" => { "status" => status_hash }}
        return post_hash
      end
      # 新建和编辑目的地址转换规则,公共的post_hash
      def add_and_edit_dnat_common_post_hash( hash )
        dst_hash = {"ip_if" => "", "dst_ip" => { "dst_specip"=>"", "enable"=>false }, "dst_ipg" => { "ipg"=>"", "enable"=>false} }
        # 目的
        if hash[:destip_type] == "指定IP"
          dst_hash["ip_if"] = "dst_ip"
          dst_hash["dst_ip"]["dst_specip"] = hash[:dest_ips].split("&").join(",")
          dst_hash["dst_ip"]["enable"] = true
        else
          dst_hash["ip_if"] = "dst_ipg"
          dst_hash["dst_ipg"]["ipg"] = hash[:dest_ipgs].split("&").join(",")
          dst_hash["dst_ipg"]["enable"] = true
        end
        # 协议
        protype = convert_protocol_type(hash[:protocol_type])
        protocol_hash = { "protype" => protype, "pronum" => "", "dst_port" => "" }
        if protype == "6" || protype == "17" || protype == "6,17" # TCP UDP TCPUDP
          protocol_hash["dst_port"] = hash[:dest_ports].split("&").join(",")
        elsif protype == "4" # IP
          protocol_hash["pronum"] = hash[:protocol_num]
        end
        # 目的地址转换为,初始值,下面再修改
        dsttr_hash = {"addr_tr" => "addr_notr", "dst_min" => "", "dst_max" => "", "dst_spec_ip" => ""}
        dsttr_hash["port_tr_group"] = ""
        dsttr_hash["port_notr"] = {"enable" => false}
        dsttr_hash["port_tr"] = {"port" => "", "enable" => false}
        if hash[:ip_translation_as] == "IP范围" # IP范围|指定IP|不转换
          dsttr_hash["addr_tr"] = "addr_ipg"
          dsttr_hash["dst_min"] = hash[:ip_scope].split("-")[0].to_s
          dsttr_hash["dst_max"] = hash[:ip_scope].split("-")[1].to_s
        elsif hash[:ip_translation_as] == "指定IP"
          dsttr_hash["addr_tr"] = "specip"
          dsttr_hash["dst_spec_ip"] = hash[:one_ip]
        elsif hash[:ip_translation_as] == "不转换"
          dsttr_hash["addr_tr"] = "addr_notr"
        end
        if protype == "6" || protype == "17" || protype == "6,17" # 协议类型选择 TCP UDP TCPUDP
          if hash[:port_translation_as] == "指定端口"
            dsttr_hash["port_tr_group"] = "port_tr"
            dsttr_hash["port_tr"]["enable"] = true
            dsttr_hash["port_tr"]["port"] = hash[:one_port]
          elsif hash[:port_translation_as] == "不转换"
            dsttr_hash["port_tr_group"] = "port_notr"
            dsttr_hash["port_notr"]["enable"] = true
          end
        else # 协议类型选择 所有协议 ICMP IP
          dsttr_hash["port_tr_group"] = "port_notr"
          dsttr_hash["port_notr"]["enable"] = true
        end
        # 高级设置,初始值,下面再修改
        setting_hash = { "src" => {"src_ipg" => "全部"},"protocol" => {"src_port" => "src_all", "src_all"=>{"enable"=>true}, "src_spec"=>{"enable"=>false,"src_spec"=>""} } }
        setting_hash["src"]["src_ipg"] = hash[:source_ipgs].split("&").join(",")
        if protype == "6" || protype == "17" || protype == "6,17"
          if hash[:source_port_type] == "指定端口" # 所有端口
            setting_hash["protocol"]["src_port"] = "src_spec"
            setting_hash["protocol"]["src_all"]["enable"] = false
            setting_hash["protocol"]["src_spec"]["enable"] = true
            setting_hash["protocol"]["src_spec"]["src_spec"] = hash[:source_one_port].to_i
          end
        end

        status_hash = { "type" => "1", "name" => "#{hash[:name]}", "desc" => "#{hash[:description]}", "enable" => hash[:enable].to_logic}
        status_hash["src"] = { "src_zone" => hash[:source_zone].split("&").join(",")}
        status_hash["dst"] = dst_hash
        status_hash["protocol"] = protocol_hash
        status_hash["dsttr"] = dsttr_hash
        status_hash["setting"] = setting_hash
        return status_hash
      end

      # 获取新增双向地址转换时要post的hash
      def get_add_bidirection_address_translation_post_hash( hash )
        status_hash = add_and_edit_binat_common_post_hash( hash ) # 新建和编辑双向地址转换公共的post_hash
        
        post_hash = {"opr" => "add", "data" => { "status" => status_hash }}
        return post_hash
      end
      # 获取编辑双向地址转换时要post的hash
      def get_edit_bidirection_address_translation_post_hash( hash )
        status_hash = add_and_edit_binat_common_post_hash( hash ) # 新建和编辑双向地址转换公共的post_hash
        unless hash[:newname].to_s.empty? # 编辑时,可能会修改名称
          status_hash["name"] = "#{hash[:newname]}"
        end

        post_hash = {"opr" => "modify", "data" => { "status" => status_hash }}
        return post_hash
      end
      # 新建和编辑双向地址转换公共的post_hash
      def add_and_edit_binat_common_post_hash( hash )
        # 源
        src_hash = { "src_zone" => hash[:source_zone].split("&").join(","), "src_ipg" => hash[:source_ipgs].split("&").join(",")}
        # 目的,初始值,下面再修改
        dst_hash = {"area_if" => "", "zone" => { "dst_zone"=>"","enable"=>false }, "dst_if" => {"if"=>"","enable"=>false  },\
            "ip_if" => "", "dst_ip" => {"dst_specip"=>"","enable"=>false }, "dst_ipg" => { "ipg"=>"","enable"=>false } }
        if hash[:destination] == "区域" # 区域|接口
          dst_hash["area_if"] = "zone"
          dst_hash["zone"]["enable"] = true
          dst_hash["zone"]["dst_zone"] = hash[:dest_zone].split("&").join(",")
        elsif hash[:destination] == "接口"
          dst_hash["area_if"] = "dst_if"
          dst_hash["dst_if"]["enable"] = true
          dst_hash["dst_if"]["if"] = hash[:dest_interface]
        end
        if hash[:destip_type] == "指定IP" # 指定IP|IP组
          dst_hash["ip_if"] = "dst_ip"
          dst_hash["dst_ip"]["enable"] = true
          dst_hash["dst_ip"]["dst_specip"] = hash[:dest_ips].split("&").join(",")
        elsif hash[:destip_type] == "IP组"
          dst_hash["ip_if"] = "dst_ipg"
          dst_hash["dst_ipg"]["enable"] = true
          dst_hash["dst_ipg"]["ipg"] = hash[:dest_ipgs].split("&").join(",")
        end
        # 协议,初始值,下面再修改
        protocol_hash = {"protype" => "0", "pronum" => "", "dst_port" => "", \
            "src_setting" => {"src_port"=>"src_all","src_all"=>{"enable"=>true},"src_spec"=>{"src_spec"=>"","enable"=>false} } }
        protype = convert_protocol_type(hash[:protocol_type])
        protocol_hash["protype"] = protype
        if protype == "6" || protype == "17" || protype == "6,17" # 协议类型选择 TCP UDP TCPUDP
          protocol_hash["dst_port"] = hash[:dest_ports].split("&").join(",")
          if hash[:source_port_type] == "指定端口" # 指定端口|所有端口
            protocol_hash["src_setting"]["src_port"] = "src_spec"
            protocol_hash["src_setting"]["src_spec"]["src_spec"] = hash[:source_one_port]
            protocol_hash["src_setting"]["src_spec"]["enable"] = true
            protocol_hash["src_setting"]["src_all"]["enable"] = false
          end
        elsif protype == "4" # IP
          protocol_hash["pronum"] = hash[:protocol_num]
        end
        # 源地址转换,初始值,下面再修改
        srctr_hash = {"trmode" => "addr_oif", "src_min" => "", "src_max" => "", "src_specip" => "" }
        if hash[:source_translation_as] == "IP范围" # 出接口地址|IP范围|指定IP|不转换
          srctr_hash["trmode"] = "addr_ipg"
          srctr_hash["src_min"] = hash[:source_ip_scope].split("-")[0].to_s
          srctr_hash["src_max"] = hash[:source_ip_scope].split("-")[1].to_s
        elsif hash[:source_translation_as] == "指定IP"
          srctr_hash["trmode"] = "specip"
          srctr_hash["src_specip"] = hash[:source_one_ip]
        elsif hash[:source_translation_as] == "不转换"
          srctr_hash["trmode"] = "addr_notr"
        end
        # 目的地址转换,初始值,下面再修改
        dsttr_hash = {"addr_tr" => "addr_notr", "dst_min" => "", "dst_max" => "", "dst_spec_ip" => ""}
        dsttr_hash["dst_port_tr"] = "port_notr"
        dsttr_hash["port_notr"] = {"enable" => true}
        dsttr_hash["port_tr"] = {"port" => "", "enable" => false}
        if hash[:dest_translation_as] == "IP范围" # IP范围|指定IP|不转换
          dsttr_hash["addr_tr"] = "addr_ipg"
          dsttr_hash["dst_min"] = hash[:dest_ip_scope].split("-")[0].to_s
          dsttr_hash["dst_max"] = hash[:dest_ip_scope].split("-")[1].to_s
        elsif hash[:dest_translation_as] == "指定IP"
          dsttr_hash["addr_tr"] = "specip"
          dsttr_hash["dst_spec_ip"] = hash[:dest_one_ip]
        end
        if protype == "6" || protype == "17" || protype == "6,17" # 协议类型选择 TCP UDP TCPUDP
          if hash[:dest_port_translation_as] == "指定端口" # 不转换|指定端口
            dsttr_hash["dst_port_tr"] = "port_tr"
            dsttr_hash["port_notr"]["enable"] = false
            dsttr_hash["port_tr"]["enable"] = true
            dsttr_hash["port_tr"]["port"] = hash[:dest_one_port]
          end
        end

        status_hash = { "type" => "2", "name" => "#{hash[:name]}", "desc" => "#{hash[:description]}", "enable" => hash[:enable].to_logic}
        status_hash["src"] = src_hash
        status_hash["dst"] = dst_hash
        status_hash["protocol"] = protocol_hash
        status_hash["srctr"] = srctr_hash
        status_hash["dsttr"] = dsttr_hash
        return status_hash
      end

      # 下载nat规则文件
      def download_natrule_file(hash, download_url)
        if hash[:dir].to_s.empty? # 项目根目录/temp
          save_as_file = File.expand_path(File.join(ATT::ConfigureManager.root, "temp", hash[:filename]))
          dir = File.expand_path(File.join(ATT::ConfigureManager.root, "temp"))
          ATT::KeyLog.info("目录为#{dir}")
        else
          save_as_file = File.expand_path(File.join(hash[:dir], hash[:filename]))
          dir = hash[:dir]
        end
        if File.exist?(save_as_file) # 已经存在时,删除它
          File.delete(save_as_file)
          ATT::KeyLog.info("删除原来的文件成功")
        end
        #wget_exe = File.expand_path(File.join(ATT::ConfigureManager.root, "bin", "wget.exe"))
        #download_command = "#{wget_exe} --no-check-certificate #{download_url} --output-document=#{save_as_file} -nH"
        #download_result = `#{download_command}`
        ssh_connection = ATT::TestDevice.new(hash[:devicename])
        ssh_connection.download("/var/tmp/natrule_config.csv", dir) # 下载nat规则文件
        sleep 6
        if File.exist?(save_as_file)
          ATT::KeyLog.info("导出地址转换成功,保存在本地的#{save_as_file}")
          return_ok
        else
          ATT::KeyLog.info("导出地址转换失败")
          return_fail
        end
      end

      # 上传规则文件到设备后台的/tmp目录下,命名为fileid_str
      def upload_natrule_file(hash, fileid_str)
        if hash[:dir].to_s.empty? # 项目根目录/temp
          local_file = File.expand_path(File.join(ATT::ConfigureManager.root, "temp", hash[:filename]))
        else
          local_file = File.expand_path(File.join(hash[:dir], hash[:filename]))
        end
        ATT::KeyLog.info("要上传到设备的文件是:#{local_file}")

        ssh_connection = ATT::TestDevice.new(hash[:devicename])
        ssh_connection.upload(local_file, "/tmp", fileid_str) # 上传规则文件到设备后台的/tmp目录下,命名为fileid_str
      end

      # 获取所有DNSMapping中的public_ip组成的数组
      def get_all_dns_mapping_public_ips()
        public_ips = [] # 存放所有的public_ip
        all_dns_mappings = DeviceConsole::list_all_objects(DnsMappingCGI, "DNSMapping")
        all_dns_mappings.each do |dns_mapping|
          public_ips << dns_mapping["pub_ip"]
        end
        ATT::KeyLog.debug("所有的DNSMapping中的pub_ip:#{public_ips.join(',')}")
        return public_ips
      end

      # 转换协议类型
      def convert_proto_type(type)
        tmp_hash = {"UDP" => 2}
        return tmp_hash["#{type}"] if tmp_hash.has_key?("#{type}")
        return_fail("不存在的协议类型")
      end
      #检查DNS mapping正确与否
      def check_dns_mapping_setting(dns_mapping_setting, hash )
        dns_mapping_setting.each do |dns_mapping|
          if dns_mapping["pub_ip"] == hash[:public_ip]
            return_fail("协议类型错误") if !hash[:proto_type].to_s.empty? && convert_proto_type(hash[:proto_type]) != dns_mapping["proto"]
            return_fail("域名错误") if !hash[:domain_name].to_s.empty? && hash[:domain_name] != dns_mapping["domain"]
            return_fail("内网ip地址错误") if !hash[:local_ip].to_s.empty? && hash[:local_ip] != dns_mapping["local_ip"]
            return_ok
          end
        end
        ATT::KeyLog.info("#{hash[:public_ip]}不存在")
        return_fail("公网ip地址不存在")
      end

      # 判断指定的公网ip对应的记录是否存在
      def dns_mapping_exists?( public_ip )
        # 查找指定公网IP对应的记录
        all_dns_mappings = DeviceConsole::list_all_objects(DnsMappingCGI, "DNSMapping")
        all_dns_mappings.each do |dns_mapping|
          if dns_mapping["pub_ip"] == public_ip
            return true
          end
        end
        ATT::KeyLog.info("公网ip#{public_ip}对应的记录不存在")
        return_fail("DNSMapping不存在")
      end
      
    end
  end
end