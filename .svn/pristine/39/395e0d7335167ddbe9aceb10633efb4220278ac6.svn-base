# coding: utf8
=begin rdoc
作用: 封装对象定义下IP组的操作
维护记录:
维护人      时间                  行为
gsj      2011-12-07             创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module ObjectDefinition


=begin rdoc
类名: IP组
描述: IP组
=end
    class IpGroup < ATT::Base

=begin rdoc
关键字名: 新增IP组
描述: 新增IP组
参数:
id=>group_name,name=>IP组名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"IP组名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"IP组描述"
id=>ip_addresses,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"IP地址,多个时使用&分割,如100.100.21.16&1.2.3.4-11.11.11.1&1.1.1.1"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
      def add_ip_group(hash)
        ATT::KeyLog.debug("add ip group......")
        post_hash = get_add_ip_group_post_hash( hash )
        result_hash = AF::Login.get_session().post(ObjectIpGroupCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除IP组
描述: 删除IP组,删除类型是全部删除时,不会删除'全部'IP组
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的IP组,还是删除目前除'全部'外的所有IP组"
id=>group_names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的IP组名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_ip_group(hash)
        ATT::KeyLog.debug("delete ip groups......")
        if hash[:delete_type] == "全部删除"
          all_ip_group_names = get_all_ip_group_names() # 数组类型,不包含'全部'IP组
        else
          all_ip_group_names = hash[:group_names].to_s.split("&") # 数组类型
        end
        return_ok if all_ip_group_names.empty?
        post_hash = {"opr" => "delete", "name" => all_ip_group_names}
        result_hash = AF::Login.get_session().post(ObjectIpGroupCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增解析域名IP组
描述: 新增解析域名IP组
参数:
id=>group_name,name=>IP组名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"IP组名称"
id=>description,name=>描述,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"IP组描述"
id=>retry,name=>重试次数,type=>s,must=>false,default=>"1",value=>"{text}",descrip=>"重试次数"
id=>domain_name,name=>域名,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"域名"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|解析域名失败",descrip=>"期望结果"
=end
      def add_dns_ip_group( hash )
        ATT::KeyLog.debug("add dns ip groups......")
        ip_address = get_ip_address_of_domain( hash[:retry], hash[:domain_name])
        post_hash = get_add_ip_group_post_hash( {:name => "#{hash[:name]}", :description => "#{hash[:description]}", :ip_addresses => ip_address} )
        result_hash = AF::Login.get_session().post(ObjectIpGroupCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
      

    end
  end
end
