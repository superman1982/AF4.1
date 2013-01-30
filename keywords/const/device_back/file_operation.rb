module DeviceBack
  module FileOperationConst

    DNSMappingConfigFile = "/etc/sinfor/fw/dns.ini"
    InterfaceConfigFile = "/etc/sinfor/fw/netconfigeth.ini"
    AddressTransConfigFile = "/etc/sinfor/fw/natrule.ini"
    VlanConfigFile = "/etc/sinfor/fw/vlan.ini"
    ZoneConfigFile = "/etc/sinfor/fw/zone.ini"
    PortLinkageConfigFile = "/etc/sinfor/fw/portlinkage.ini"
    # DOS外网防护策略配置文件
    WANDOS_RULE_CONFIG = "/proc/net/wandos/rule"
    # => 王沃伦添加WAF相关配置文件
    WAFConfigFile = "/etc/sinfor/fw/waf.ini"
    DefDLPConfigFile = "/etc/sinfor/fw/defdip.ini"
    DLPExcldIPConfigFile = "/etc/sinfor/fw/excldip.ini"
    DLPExcldURLConfigFile = "/etc/sinfor/fw/excldurl.ini"
    #AIFW_DelIPConfigFile = "/etc/sinfor/fw/aifw_del_ip.ini"
    AIFWConfigFile = "/etc/sinfor/fw/aifw_config.ini"
  end
end
