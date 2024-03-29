# coding: utf8
=begin rdoc
作用: 封装地址转换页面上的操作
维护记录:
维护人      时间                  行为
gsj      2011-12-08             创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module FireWall


=begin rdoc
类名: 地址转换
描述: 地址转换
=end
    class AddressTranslation < ATT::Base

=begin rdoc
关键字名: 新增源地址转换
描述: 新增源地址转换
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源地址转换规则的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此源地址转换规则"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>source_ipgs,name=>源IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"源IP组,多个时使用&分割"
id=>destination,name=>目的区域或接口,type=>s,must=>false,default=>"区域",value=>"区域|接口",descrip=>"目的选择区域还是接口"
id=>dest_zone,name=>目的区域,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当目的选择区域时,勾选的区域,多个时使用&分割"
id=>dest_interface,name=>目的接口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当目的选择接口时,选择的某个接口"
id=>dest_ipgs,name=>目的IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"目的IP组,多个时使用&分割"
id=>protocol_type,name=>协议类型,type=>s,must=>false,default=>"所有协议",value=>"所有协议|TCP|UDP|ICMP|TCPUDP|IP",descrip=>"协议类型"
id=>protocol_num,name=>协议号,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当协议类型选择IP时,输入的协议号不能为空,范围是1-255"
id=>source_port,name=>源端口,type=>s,must=>false,default=>"所有端口",value=>"所有端口|指定端口",descrip=>"源端口选择所有端口还是指定端口"
id=>s_port,name=>指定源端口,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"源端口选择指定端口时,输入的端口号"
id=>dest_port,name=>目的端口,type=>s,must=>false,default=>"所有端口",value=>"所有端口|指定端口",descrip=>"目的端口选择所有端口还是指定端口"
id=>d_port,name=>指定目的端口,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"目的端口选择指定端口时,输入的端口号"
id=>translation_as,name=>源地址转换为,type=>s,must=>false,default=>"出接口地址",value=>"出接口地址|IP范围|指定IP|不转换",descrip=>"源地址转换为的类型"
id=>ip_scope,name=>IP范围,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源地址转换为IP范围时,输入的IP范围,格式如'1.1.1.1-2.2.2.2'"
id=>one_ip,name=>指定IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源地址转换为指定IP时,输入的IP,格式如'1.1.1.1'"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_source_address_translation(hash)
        ATT::KeyLog.debug("add source address translation......")
        post_hash = get_add_source_address_translation_post_hash( hash )
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增目的地址转换
描述: 新增目的地址转换
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"目的地址转换规则的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此目的地址转换规则"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>destip_type,name=>目的IP类型,type=>s,must=>false,default=>"指定IP",value=>"指定IP|IP组",descrip=>"目的IP选择指定IP还是IP组"
id=>dest_ips,name=>指定目的IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的IP选择指定IP时,输入的IP地址,多个时使用&分割"
id=>dest_ipgs,name=>目的IP组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的IP选择IP组时,选择的IP组,多个时使用&分割"
id=>protocol_type,name=>协议类型,type=>s,must=>false,default=>"TCP",value=>"所有协议|TCP|UDP|ICMP|TCPUDP|IP",descrip=>"协议类型"
id=>dest_ports,name=>目的端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择TCP或UDP或TCPUDP时,输入的端口号或端口范围,多个时使用&分割,格式如'82&89-95'"
id=>protocol_num,name=>协议号,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择IP时,输入的单个协议号,范围是1-255"
id=>ip_translation_as,name=>目的地址IP转换为,type=>s,must=>false,default=>"指定IP",value=>"IP范围|指定IP|不转换",descrip=>"目的地址IP转换为的类型"
id=>ip_scope,name=>IP范围,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的地址IP转换为IP范围时,输入的IP范围,格式如'1.1.1.1-2.2.2.2'"
id=>one_ip,name=>指定IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的地址IP转换为指定IP时,输入的IP,格式如'1.1.1.1'"
id=>port_translation_as,name=>目的地址端口转换为,type=>s,must=>false,default=>"指定端口",value=>"指定端口|不转换",descrip=>"协议类型选择TCP或UDP或TCPUDP时,目的地址端口转换为的类型"
id=>one_port,name=>指定目的端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择TCP或UDP或TCPUDP,目的端口只填写一个,目的地址端口转换为指定端口时,输入的单个端口号"
id=>source_ipgs,name=>源IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"高级设置中的源IP组,多个时使用&分割"
id=>source_port_type,name=>源端口类型,type=>s,must=>false,default=>"所有端口",value=>"指定端口|所有端口",descrip=>"高级设置中的源端口类型"
id=>source_one_port,name=>指定源端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"高级设置中,源端口类型选择指定端口时,输入的单个端口号"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_destination_address_translation(hash)
        ATT::KeyLog.debug("add destination address translation......")
        post_hash = get_add_destination_address_translation_post_hash( hash )
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增双向地址转换
描述: 新增双向地址转换
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"双向地址转换规则的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此双向地址转换规则"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>source_ipgs,name=>源IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"源IP组,多个时使用&分割"
id=>destination,name=>目的区域或接口,type=>s,must=>false,default=>"区域",value=>"区域|接口",descrip=>"目的区域/接口选择区域还是接口"
id=>dest_zone,name=>目的区域,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当目的区域/接口选择区域时,勾选的区域,多个时使用&分割"
id=>dest_interface,name=>目的接口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当目的区域/接口选择接口时,选择的某个接口"
id=>destip_type,name=>目的IP类型,type=>s,must=>false,default=>"指定IP",value=>"指定IP|IP组",descrip=>"目的IP选择指定IP还是IP组"
id=>dest_ips,name=>指定目的IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的IP选择指定IP时,输入的IP地址,多个时使用&分割"
id=>dest_ipgs,name=>目的IP组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的IP选择IP组时,选择的IP组,多个时使用&分割"
id=>protocol_type,name=>协议类型,type=>s,must=>false,default=>"TCP",value=>"所有协议|TCP|UDP|ICMP|TCPUDP|IP",descrip=>"协议类型"
id=>dest_ports,name=>目的端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择TCP或UDP或TCPUDP时,输入的端口号或端口范围,多个时使用&分割,格式如'82&89-95'"
id=>source_port_type,name=>源端口类型,type=>s,must=>false,default=>"所有端口",value=>"指定端口|所有端口",descrip=>"协议类型选择TCP或UDP或TCPUDP时,源端口设置中的源端口类型"
id=>source_one_port,name=>指定源端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择TCP或UDP或TCPUDP时,源端口设置中,源端口类型选择指定端口时,输入的单个端口号"
id=>protocol_num,name=>协议号,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择IP时,输入的单个协议号,范围是1-255"
id=>source_translation_as,name=>源地址转换为,type=>s,must=>false,default=>"出接口地址",value=>"出接口地址|IP范围|指定IP|不转换",descrip=>"源地址转换为的类型"
id=>source_ip_scope,name=>源地址转换IP范围,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源地址转换为IP范围时,输入的IP范围,格式如'1.1.1.1-2.2.2.2'"
id=>source_one_ip,name=>源地址转换指定IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源地址转换为指定IP时,输入的IP,格式如'1.1.1.1'"
id=>dest_translation_as,name=>目的地址IP转换为,type=>s,must=>false,default=>"指定IP",value=>"IP范围|指定IP|不转换",descrip=>"目的地址转换为的类型"
id=>dest_ip_scope,name=>目的地址转换IP范围,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的地址转换为IP范围时,输入的IP范围,格式如'1.1.1.1-2.2.2.2'"
id=>dest_one_ip,name=>目的地址转换指定IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的地址转换为指定IP时,输入的IP,格式如'1.1.1.1'"
id=>dest_port_translation_as,name=>目的地址端口转换为,type=>s,must=>false,default=>"不转换",value=>"不转换|指定端口",descrip=>"协议类型选择TCP或UDP或TCPUDP时,目的地址转换端口转换为不转换还是指定端口"
id=>dest_one_port,name=>目的地址转换端口,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"协议类型选择TCP或UDP或TCPUDP,目的端口只填写一个,目的地址转换端口转换为指定端口时,输入的端口号"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_bidirection_address_translation(hash)
        ATT::KeyLog.debug("add bidirection address translation......")
        post_hash = get_add_bidirection_address_translation_post_hash( hash )
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑源地址转换
描述: 编辑源地址转换,若某个参数未在用例的关键字中写出,该参数不使用原来的设置,使用当前新设置的值
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要编辑的源地址转换规则的名称,不允许修改名称"
id=>newname,name=>新名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"编辑为的新名称,默认采用原名"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此源地址转换规则"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>source_ipgs,name=>源IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"源IP组,多个时使用&分割"
id=>destination,name=>目的区域或接口,type=>s,must=>false,default=>"区域",value=>"区域|接口",descrip=>"目的选择区域还是接口"
id=>dest_zone,name=>目的区域,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当目的选择区域时,勾选的区域,多个时使用&分割"
id=>dest_interface,name=>目的接口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当目的选择接口时,选择的某个接口"
id=>dest_ipgs,name=>目的IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"目的IP组,多个时使用&分割"
id=>protocol_type,name=>协议类型,type=>s,must=>false,default=>"所有协议",value=>"所有协议|TCP|UDP|ICMP|TCPUDP|IP",descrip=>"协议类型"
id=>protocol_num,name=>协议号,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当协议类型选择IP时,输入的协议号不能为空,范围是1-255"
id=>source_port,name=>源端口,type=>s,must=>false,default=>"所有端口",value=>"所有端口|指定端口",descrip=>"源端口选择所有端口还是指定端口"
id=>s_port,name=>指定源端口,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"源端口选择指定端口时,输入的端口号"
id=>dest_port,name=>目的端口,type=>s,must=>false,default=>"所有端口",value=>"所有端口|指定端口",descrip=>"目的端口选择所有端口还是指定端口"
id=>d_port,name=>指定目的端口,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"目的端口选择指定端口时,输入的端口号"
id=>translation_as,name=>源地址转换为,type=>s,must=>false,default=>"出接口地址",value=>"出接口地址|IP范围|指定IP|不转换",descrip=>"源地址转换为的类型"
id=>ip_scope,name=>IP范围,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源地址转换为IP范围时,输入的IP范围,格式如'1.1.1.1-2.2.2.2'"
id=>one_ip,name=>指定IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源地址转换为指定IP时,输入的IP,格式如'1.1.1.1'"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def edit_source_address_translation(hash)
        ATT::KeyLog.debug("edit source address translation......")
        post_hash = get_edit_source_address_translation_post_hash( hash )
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑目的地址转换
描述: 编辑目的地址转换,若某个参数未在用例的关键字中写出,该参数不使用原来的设置,使用当前新设置的值
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要编辑的目的地址转换规则的名称"
id=>newname,name=>新名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"编辑为的新名称,默认采用原名"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此目的地址转换规则"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>destip_type,name=>目的IP类型,type=>s,must=>false,default=>"指定IP",value=>"指定IP|IP组",descrip=>"目的IP选择指定IP还是IP组"
id=>dest_ips,name=>指定目的IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的IP选择指定IP时,输入的IP地址,多个时使用&分割"
id=>dest_ipgs,name=>目的IP组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的IP选择IP组时,选择的IP组,多个时使用&分割"
id=>protocol_type,name=>协议类型,type=>s,must=>false,default=>"TCP",value=>"所有协议|TCP|UDP|ICMP|TCPUDP|IP",descrip=>"协议类型"
id=>dest_ports,name=>目的端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择TCP或UDP或TCPUDP时,输入的端口号或端口范围,多个时使用&分割,格式如'82&89-95'"
id=>protocol_num,name=>协议号,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择IP时,输入的单个协议号,范围是1-255"
id=>ip_translation_as,name=>目的地址IP转换为,type=>s,must=>false,default=>"指定IP",value=>"IP范围|指定IP|不转换",descrip=>"目的地址IP转换为的类型"
id=>ip_scope,name=>IP范围,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的地址IP转换为IP范围时,输入的IP范围,格式如'1.1.1.1-2.2.2.2'"
id=>one_ip,name=>指定IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的地址IP转换为指定IP时,输入的IP,格式如'1.1.1.1'"
id=>port_translation_as,name=>目的地址端口转换为,type=>s,must=>false,default=>"指定端口",value=>"指定端口|不转换",descrip=>"协议类型选择TCP或UDP或TCPUDP时,目的地址端口转换为的类型"
id=>one_port,name=>指定目的端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择TCP或UDP或TCPUDP,目的端口只填写一个,目的地址端口转换为指定端口时,输入的单个端口号"
id=>source_ipgs,name=>源IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"高级设置中的源IP组,多个时使用&分割"
id=>source_port_type,name=>源端口类型,type=>s,must=>false,default=>"所有端口",value=>"指定端口|所有端口",descrip=>"高级设置中的源端口类型"
id=>source_one_port,name=>指定源端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"高级设置中,源端口类型选择指定端口时,输入的单个端口号"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def edit_destination_address_translation(hash)
        ATT::KeyLog.debug("edit destination address translation......")
        post_hash = get_edit_destination_address_translation_post_hash( hash )
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑双向地址转换
描述: 编辑双向地址转换,若某个参数未在用例的关键字中写出,该参数不使用原来的设置,使用当前新设置的值
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要编辑的双向地址转换规则的名称"
id=>newname,name=>新名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"编辑为的新名称,默认采用原名"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此双向地址转换规则"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>source_ipgs,name=>源IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"源IP组,多个时使用&分割"
id=>destination,name=>目的区域或接口,type=>s,must=>false,default=>"区域",value=>"区域|接口",descrip=>"目的区域/接口选择区域还是接口"
id=>dest_zone,name=>目的区域,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当目的区域/接口选择区域时,勾选的区域,多个时使用&分割"
id=>dest_interface,name=>目的接口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当目的区域/接口选择接口时,选择的某个接口"
id=>destip_type,name=>目的IP类型,type=>s,must=>false,default=>"指定IP",value=>"指定IP|IP组",descrip=>"目的IP选择指定IP还是IP组"
id=>dest_ips,name=>指定目的IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的IP选择指定IP时,输入的IP地址,多个时使用&分割"
id=>dest_ipgs,name=>目的IP组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的IP选择IP组时,选择的IP组,多个时使用&分割"
id=>protocol_type,name=>协议类型,type=>s,must=>false,default=>"TCP",value=>"所有协议|TCP|UDP|ICMP|TCPUDP|IP",descrip=>"协议类型"
id=>dest_ports,name=>目的端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择TCP或UDP或TCPUDP时,输入的端口号或端口范围,多个时使用&分割,格式如'82&89-95'"
id=>source_port_type,name=>源端口类型,type=>s,must=>false,default=>"所有端口",value=>"指定端口|所有端口",descrip=>"协议类型选择TCP或UDP或TCPUDP时,源端口设置中的源端口类型"
id=>source_one_port,name=>指定源端口,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择TCP或UDP或TCPUDP时,源端口设置中,源端口类型选择指定端口时,输入的单个端口号"
id=>protocol_num,name=>协议号,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"协议类型选择IP时,输入的单个协议号,范围是1-255"
id=>source_translation_as,name=>源地址转换为,type=>s,must=>false,default=>"出接口地址",value=>"出接口地址|IP范围|指定IP|不转换",descrip=>"源地址转换为的类型"
id=>source_ip_scope,name=>源地址转换IP范围,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源地址转换为IP范围时,输入的IP范围,格式如'1.1.1.1-2.2.2.2'"
id=>source_one_ip,name=>源地址转换指定IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"源地址转换为指定IP时,输入的IP,格式如'1.1.1.1'"
id=>dest_translation_as,name=>目的地址IP转换为,type=>s,must=>false,default=>"指定IP",value=>"IP范围|指定IP|不转换",descrip=>"目的地址转换为的类型"
id=>dest_ip_scope,name=>目的地址转换IP范围,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的地址转换为IP范围时,输入的IP范围,格式如'1.1.1.1-2.2.2.2'"
id=>dest_one_ip,name=>目的地址转换指定IP,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"目的地址转换为指定IP时,输入的IP,格式如'1.1.1.1'"
id=>dest_port_translation_as,name=>目的地址端口转换为,type=>s,must=>false,default=>"不转换",value=>"不转换|指定端口",descrip=>"协议类型选择TCP或UDP或TCPUDP时,目的地址转换端口转换为不转换还是指定端口"
id=>dest_one_port,name=>目的地址转换端口,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"协议类型选择TCP或UDP或TCPUDP,目的端口只填写一个,目的地址转换端口转换为指定端口时,输入的端口号"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def edit_bidirection_address_translation(hash)
        ATT::KeyLog.debug("edit bidirection address translation......")
        post_hash = get_edit_bidirection_address_translation_post_hash( hash )
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除地址转换
描述: 删除指定的地址转换规则,可同时删除不同类型的地址转换规则
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的地址转换规则,还是删除目前所有的地址转换规则"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的地址转换规则名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_address_translations( hash )
        ATT::KeyLog.debug("delete address translations......")
        if hash[:delete_type] == "全部删除"
          all_translation_names = get_all_address_translation_names() # 数组类型
        else
          all_translation_names = hash[:names].to_s.split("&") # 数组类型
        end
        #return_ok if all_translation_names.empty?
        post_hash = {"opr" => "delete", "name" => all_translation_names}
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 启禁地址转换
描述: 启用或禁用地址转换规则
参数:
id=>names,name=>地址转换名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要启用或禁用的地址转换规则的名称,多个时使用&分割"
id=>operation,name=>操作,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"启用还是禁用指定的地址转换规则"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_address_translations( hash )
        operation = (hash[:operation] == "启用" ? "enable" : "disable")
        post_hash = {"opr" => operation, "name" => hash[:names].split("&") }
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end

=begin rdoc
关键字名: 导入地址转换
描述: 导入地址转换规则,实现由2步完成,先上传规则文件到设备后台的某个目录下,然后post数据{"opr":"import","file":"xx"},即通过UI上传文件的过程由sftp上传完成
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>dir,name=>本地路径,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"要导入的文件所在的本地路径,默认为项目/temp文件夹下"
id=>filename,name=>文件名,type=>s,must=>false,default=>"natrule.conf",value=>"{text}",descrip=>"要导入的文件名称"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|规则已存在|接口不存在",descrip=>""
=end
      def import_address_translations( hash )
        fileid_str = AF::Util.randstr(13) # 获取指定长度的数字字符串
        upload_natrule_file(hash, fileid_str ) # 上传规则文件到设备后台的/tmp目录下,命名为fileid_str

        post_hash = {"opr" => "import", "file" => fileid_str }
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash) # 导入
        if result_hash["success"] && result_hash["msg"].include?("规则重复")
          ATT::KeyLog.info("导入地址转换规则失败,错误消息是#{result_hash["msg"]}")
          return_fail("规则已存在")
        elsif result_hash["success"] && result_hash["msg"].include?("不存在")
          ATT::KeyLog.info("导入地址转换规则失败,错误消息是#{result_hash["msg"]}")
          return_fail("接口不存在")
        elsif result_hash["success"]
          ATT::KeyLog.info("导入地址转换规则成功")
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end

=begin rdoc
关键字名: 导出地址转换
描述: 导出地址转换规则,实现由2步完成,先post数据{"opr":"export","name":["s","d"]},然后下载配置文件到本地
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>names,name=>地址转换名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要导出的地址转换规则的名称,多个时使用&分割"
id=>type,name=>导出类型,type=>s,must=>false,default=>"导出为conf文件",value=>"导出为conf文件|导出为csv表格",descrip=>"导出文件类型"
id=>dir,name=>本地路径,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"导出后保存在的本地路径,默认为项目/temp文件夹下"
id=>filename,name=>文件名,type=>s,must=>false,default=>"natrule.conf",value=>"{text}",descrip=>"导出后保存为的文件名称"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|尚未指定设备",descrip=>""
=end
      def export_address_translations( hash )
        return_fail("尚未指定设备") if $gw_ip.nil?
        if hash[:type] == "导出为conf文件"
          post_hash = {"opr" => "exportconf", "name" => hash[:names].split("&") }
        else
          post_hash = {"opr" => "exportcsv", "name" => hash[:names].split("&") }
        end
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash) # 导出
        if result_hash["success"]
          file_url = result_hash["url"]
          download_url = "https://#{$gw_ip}/php/loadfile.php?file=#{file_url}"
          ATT::KeyLog.info("要导出的地址转换文件的路径是:#{download_url}")
          download_natrule_file(hash, download_url) # 下载地址转换规则文件
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end

=begin rdoc
关键字名: 检查地址转换规则数目
描述: 检查地址转换规则数目
参数:
id=>count,name=>规则数,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"期望存在的规则数目"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|规则数错误",descrip=>""
=end
      def check_address_translation_item_count( hash )
        post_hash = {"opr" => "list", "start" => 0, "limit" => 65535 }
        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          real_rules_count = result_hash["count"]
          if real_rules_count == hash[:count].to_i
            return_ok
          else
            ATT::KeyLog.info("实际地址转换规则数目是:#{real_rules_count},期望规则数是:#{hash[:count].to_i}")
            return_fail("规则数错误")
          end
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end

=begin rdoc
关键字名: 移动地址转换
描述: 移动地址转换规则
参数:
id=>names,name=>地址转换名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要移动的地址转换规则的名称,多个时使用&分割"
id=>serial_num,name=>序号,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"移动到此序号"
id=>location,name=>位置,type=>s,must=>false,default=>"之前",value=>"之前|之后",descrip=>"移动到此序号之前还是之后"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|序号错误",descrip=>""
=end
      def move_address_translation( hash )
        all_translation_names = get_all_address_translation_names() # 数组类型
        if hash[:serial_num].to_i <= 0 || hash[:serial_num].to_i > all_translation_names.size
          ATT::KeyLog.info("序号错误,应大于0,小于等于#{all_translation_names.size}")
          return_fail("序号错误")
        end
        num = 0
        direction = (hash[:location] == "之前" ? 1 : 0)
        post_hash = { "opr" => "move", "name" => hash[:names].split("&"), "num" => num,\
            "data" => { "to" => hash[:serial_num], "dir" => direction} }

        result_hash = AF::Login.get_session().post(NetworkAddressTransCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end

=begin rdoc
关键字名: 新增DNSMapping
描述: 新增DNSMapping规则
参数:
id=>domain_name,name=>域名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"域名,不能为空"
id=>public_ip,name=>公网IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"公网IP地址,不能为空"
id=>local_ip,name=>内网IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"内网IP地址,不能为空"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_dns_mapping_rule( hash )
        post_hash = { "opr" => "add", "data" => {"proto" => ["udp"],"tcp" => false, "udp" => true} }
        post_hash["data"]["domain"] = hash[:domain_name]
        post_hash["data"]["pub_ip"] = hash[:public_ip]
        post_hash["data"]["local_ip"] = hash[:local_ip]
        
        result_hash = AF::Login.get_session().post(DnsMappingCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end

=begin rdoc
关键字名: 删除DNSMapping
描述: 删除DNSMapping规则
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定的DNSMapping规则,还是删除目前所有的DNSMapping规则"
id=>public_ips,name=>公网IP列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的DNSMapping规则中的公网IP地址,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_dns_mapping_rule( hash )
        ATT::KeyLog.debug("delete dns mapping rules......")
        if hash[:delete_type] == "全部删除"
          public_ip_array = get_all_dns_mapping_public_ips() # 获取所有DNSMapping中的public_ip组成的数组
        else
          public_ip_array = hash[:public_ips].split("&")
        end
        return_ok if public_ip_array.empty?
        post_hash = {"opr" => "delete", "name" => public_ip_array }
        result_hash = AF::Login.get_session().post(DnsMappingCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=begin rdoc
关键字名: 编辑DNSMapping
描述: 编辑DNSMapping规则
参数:
id=>public_ip,name=>公网IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要编辑的公网IP地址"
id=>new_public_ip,name=>新公网ip,type=>s,must=>flase,default=>"",value=>"{text}",descrip=>"编辑公网IP时,新的公网IP,为空时使用原来的公网IP"
id=>domain_name,name=>域名,type=>s,must=>flase,default=>"",value=>"{text}",descrip=>"域名"
id=>local_ip,name=>内网IP,type=>s,must=>flase,default=>"",value=>"{text}",descrip=>"内网IP地址"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|DNSMapping不存在",descrip=>""
=end
      def edit_dns_mapping_rule( hash )
        dns_mapping_exists?( hash[:public_ip] )# 判断指定的公网ip对应的记录是否存在
        new_public_ip = hash[:new_public_ip].to_s.empty? ? hash[:public_ip] : hash[:new_public_ip]
        post_hash = { "opr" => "modify", "data" => {"proto" => ["udp"],"tcp" => false, "udp" => true} }
        post_hash["data"]["domain"] = hash[:domain_name]
        post_hash["data"]["local_ip"] = hash[:local_ip]
        post_hash["data"]["pub_ip"] = new_public_ip

        result_hash = AF::Login.get_session().post(DnsMappingCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end
=begin rdoc
关键字名: 检查DNSMapping设置
描述: 在DNSMapping列表页面,检查某个DNSMapping当前的设置
参数:
id=>proto_type,name=>协议类型,type=>s,must=>false,default=>"UDP",value=>"UDP",descrip=>"要检查的协议类型编号"
id=>domain_name,name=>域名,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"要检查的域名"
id=>public_ip,name=>公网ip,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要检查的公网ip"
id=>local_ip,name=>内网ip,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"要检查的内网ip"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|不存在的协议类型|协议类型错误|域名错误|内网ip地址错误|公网ip地址不存在",descrip=>""
=end
      def check_dns_mapping_rule_setting( hash )
        ATT::KeyLog.debug("检查DNSMapping 公网ip为#{hash[:public_ip]}的设置")
        post_hash = {"opr" => "list"}
        result_hash = AF::Login.get_session().post(DnsMappingCGI, post_hash)
        if result_hash["success"]
          ATT::KeyLog.info("获取数据成功,现在开始检查...")
          check_dns_mapping_setting(result_hash["data"], hash )
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail()
        end
      end
      
    end
  end
end
