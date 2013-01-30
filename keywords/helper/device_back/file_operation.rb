module DeviceBack
  module FileOperationHelper

    # 根据参数中的配置文件获取执行的命令
    def get_check_config_file_command( config_name )
      tmp_hash = {"DNSMapping" => DNSMappingConfigFile, "接口" => InterfaceConfigFile, "地址转换" => AddressTransConfigFile,
        "VLAN" => VlanConfigFile, "区域" => ZoneConfigFile, "接口联动" => PortLinkageConfigFile, 
        "WEB应用防护" => WAFConfigFile, "自定义敏感信息" => DefDLPConfigFile, "DLP排除IP" => DLPExcldIPConfigFile, "DLP排除URL" => DLPExcldURLConfigFile, "联动封锁IP" => AIFWConfigFile } #沃伦增加
      return_fail("不支持的配置文件") unless tmp_hash.has_key?("#{config_name}")
      return "cat " + tmp_hash["#{config_name}"]
    end
    # 检查配置文件中的某些检查项的值是否与期望一致
    def check_config_file(file_content, config_name, record_key, item_values)
      k_and_v_array = item_values.to_s.split("&") # 要检查的'字段=值'组成的数组
      # 检查参数'检查项和值'的值中是否包含记录标识
      value_of_key = check_item_values_including_record_key(k_and_v_array, record_key) # 返回'检查项和值'中记录标识的值

      case config_name
      when "DNSMapping"
        check_dnsmapping_config_file(file_content, record_key, k_and_v_array, value_of_key)
      when "接口","区域","接口联动"
        check_config_file_with_delimiter(file_content, record_key, k_and_v_array, value_of_key)
      when "地址转换"
        check_addr_trans_config_file(file_content, record_key, k_and_v_array, value_of_key)
      when "VLAN"
        check_config_file_with_delimiter(file_content, record_key, k_and_v_array, value_of_key)
      when "WEB应用防护"
        check_config_file_with_delimiter(file_content, record_key, k_and_v_array, value_of_key, "[record")
      when "自定义敏感信息","联动封锁IP"
        check_config_file_with_delimiter(file_content, record_key, k_and_v_array, value_of_key)
      when "DLP排除IP","DLP排除URL"
        check_config_file_with_delimiter(file_content, record_key, k_and_v_array, value_of_key, "[wlRecord")
      else
        return_fail("不支持的配置文件")
      end
    end
    
    # 检查参数'检查项和值'的值中是否包含记录标识
    def check_item_values_including_record_key(k_and_v_array, record_key)
      k_and_v_array.each do |k_and_v_str|
        key, value = get_key_value_without_blank(k_and_v_str)
        if key == record_key
          ATT::KeyLog.error("检查项和值:#{k_and_v_array.join('&')}中包含了记录的标识:#{record_key},要检查其值是否为#{value}")
          return value
        end
      end
      ATT::KeyLog.error("检查项和值:#{k_and_v_array.join('&')}中不包含记录的标识:#{record_key}")
      return_fail("检查项和值不包含记录标识")
    end
        
    # 检查DNSMapping配置文件中的某些检查项的值是否与期望一致
    def check_dnsmapping_config_file(file_content, record_key, k_and_v_array, value_of_key)
      check_config_file_with_delimiter(file_content, record_key, k_and_v_array, value_of_key)
    end
    
    # 检查地址转换配置文件中的某些检查项的值是否与期望一致
    def check_addr_trans_config_file(file_content, record_key, k_and_v_array, value_of_key)
      check_config_file_with_delimiter(file_content, record_key, k_and_v_array, value_of_key)
    end
    
    # => 检查配置文件,delimiter是对配置文件分割的关键字符串
    def check_config_file_with_delimiter(file_content, record_key, k_and_v_array, value_of_key,record_delimiter = "\n\n")
      record_array = file_content.split(record_delimiter) # 配置文件中所有记录组成的数组
      record_array.each do |one_config_record|
        next unless one_config_record.include?(record_key) # 不包含记录标识的记录,不在检查范围内
        if one_config_record.include?("#{record_key} = #{value_of_key}") # 在配置文件内找到了要检查的记录
          k_and_v_array.each do |k_and_v_str|
            k, v = get_key_value_without_blank(k_and_v_str)
            if one_config_record.include?("#{k} = #{v}")
              ATT::KeyLog.info("配置文件内包含#{k_and_v_str}")
            else
              ATT::KeyLog.error("配置文件内,记录的内容:\n#{one_config_record}\n不包含#{k_and_v_str}")
              return_fail
            end
          end
          return_ok # 检查完毕,直接返回
        end
      end
      # 遍历配置文件内所有的记录,不包含要检查的记录
      ATT::KeyLog.error("配置文件的内容:\n#{file_content},不包含'#{record_key} = #{value_of_key}'标识的记录")
      return_fail("记录不存在")
    end

    # 分解'key=value'字符串,返回key和value
    def get_key_value_without_blank(k_and_v_str, delimiter = "=")
      k, v = k_and_v_str.split(delimiter)
      key = k.to_s.strip
      value = v.to_s.strip
      return [key, value]
    end

    # 检查子接口配置文件中的某些检查项的值是否与期望一致
    def check_subport_config(file_content, subport_name, item_values)
      interface, vlan_id = get_key_value_without_blank(subport_name, ".") # 从子接口的名称中分离出物理接口和vlan_id
      k_and_v_array = item_values.to_s.split("&") # 要检查的'字段=值'组成的数组
      
      record_delimiter = "\n\n"
      record_array = file_content.split(record_delimiter) # 配置文件中所有记录组成的数组
      record_array.each do |one_config_record|
        # 找到了指定的子接口
        if one_config_record.include?("physical_port = #{interface}") && one_config_record.include?("vlan_id = #{vlan_id}")
          k_and_v_array.each do |k_and_v_str| # 检查各检查项的值是否与期望一致
            k, v = get_key_value_without_blank(k_and_v_str)
            if one_config_record.include?("#{k} = #{v}")
              ATT::KeyLog.info("配置文件内包含#{k_and_v_str}")
            else
              ATT::KeyLog.error("配置文件内,记录的内容:\n#{one_config_record}\n不包含#{k_and_v_str}")
              return_fail
            end
          end
          return_ok # 检查完毕,直接返回
        end
      end
      # 遍历配置文件内所有的记录,不包含要检查的记录
      ATT::KeyLog.error("配置文件的内容:\n#{file_content},不包含'physical_port = #{interface}&vlan_id = #{vlan_id}'标识的记录")
      return_fail("记录不存在")
    end

    # 对比期望值和实际值是否相同
    def compare_attr_value(attr_value_hoped, attr_value)
      if attr_value_hoped.nil? || attr_value.nil?
        ATT::KeyLog.error("attr_value_hoped.class=#{attr_value_hoped.class},attr_value.class=#{attr_value.class}")
        return_fail
      end
      if attr_value_hoped == attr_value
        return true
      else
        return false
      end
    end

    
  end
end
