# encoding: utf-8
=begin rdoc
作用: 这个文件对应配置流控的通道
维护记录:
维护人      时间                  行为
[王沃伦]     2012-12-24           创建
=end

module DeviceConsole

  module FluxManager


=begin rdoc
类名: 通道配置
描述: 对应流控通道的配置
=end
    class PassageWay < ATT::Base

=begin rdoc
关键字名: 启禁流控管理
描述: 启禁流控管理
维护人: 王沃伦
参数:
id=>enable,name=>启禁流控,type=>s,must=>false,default=>"启用",value=>"启用|禁用",descrip=>"启用流控还是禁用流控"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
      def enable_disable_fluxmanage(hash)
        json_hash = get_enable_disable_hash(hash)
        DeviceConsole::check_post_result(FluxManagerCGI,json_hash,{"info" => "启禁流控管理"})
      end

=begin rdoc
关键字名: 新增流控通道
描述: 新增流控通道
维护人: 王沃伦
参数:
id=>name,name=>通道名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"这个是通道名称"
id=>enable,name=>是否启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用通道"
id=>line,name=>生效线路,type=>s,must=>false,default=>"1",value=>"1|2|3|4|5|6|7",descrip=>"生效线路的数字"
id=>passage_type,name=>带宽通道类型,type=>s,must=>false,default=>"限制通道",value=>"限制通道|保证通道",descrip=>"选择保证带宽还是限制带宽"
id=>ensure_up_rate,name=>保证上行百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"上行保证带宽占的百分比,用不超过100的数字"
id=>ensure_upmax_rate,name=>保证上行最大百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"上行保证带宽占的最大的百分比,用不超过100的数字"
id=>ensure_down_rate,name=>保证下行百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"下行保证带宽占的百分比,用不超过100的数字"
id=>ensure_downmax_rate,name=>保证下行最大百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"下行保证带宽占的最大的百分比,用不超过100的数字"
id=>ensure_priority,name=>保证带宽优先级,type=>s,must=>false,default=>"High",value=>"High|Medium|Low",descrip=>"保证的带宽优先级"
id=>limit_upmax_rate,name=>限制上行百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"下行限制带宽占的百分比,用不超过100的数字"
id=>limit_downmax_rate,name=>限制下行百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"下行限制带宽占的百分比,用不超过100的数字"
id=>limit_priority,name=>限制带宽优先级,type=>s,must=>false,default=>"High",value=>"High|Medium|Low",descrip=>"限制的带宽优先级"
id=>is_enable_single_ip_speed,name=>是否启用单IP最大带宽,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"勾选启用与否单IP限制带宽的功能"
id=>single_ip_up_max,name=>单IP限制最大上传速率,type=>s,must=>false,default=>"50",value=>"{text}",descrip=>"单IP下行限制带宽占的百分比,用不超过100的数字"
id=>single_ip_down_max,name=>单IP限制最大下载速率,type=>s,must=>false,default=>"50",value=>"{text}",descrip=>"单IP下行限制带宽的具体速率,必须是数字,以KB为单位"
id=>is_enable_advance,name=>是否启用高级选项,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"勾选启用与否高级选项的功能"
id=>apply_app_type,name=>适用应用类型,type=>s,must=>false,default=>"所有应用",value=>"所有应用|自定义",descrip=>"单选使用的应用类型"
id=>custom_app_selected,name=>自定义应用具体选择的应用,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"具体选择自定义的应用,编写规则如下: 每个选择的应用之间用'@;@'隔开,选择的每个应用有三个数据元,第一个是数据所属类别,第二个是应用所属的上级目录,一个是应用具体的名称,如: 文件类型@_@电影"
id=>apply_obj_type,name=>适用对象选择,type=>s,must=>false,default=>"IP组",value=>"IP组|用户",descrip=>"单选适用IP组还是用户组"
id=>ip_group,name=>IP组名称,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"选择的IP组的名称"
id=>user_group,name=>用户组,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"选择的IP组的名称"
id=>time_group_name,name=>生效时间,type=>s,must=>false,default=>"2*0*全天",value=>"{text}",descrip=>"时间计划组的名称"
id=>dstip_group,name=>目标IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"选择的目标IP组的名称"
id=>interface_selected,name=>选择的子接口还是vlan,type=>s,must=>false,default=>"子接口",value=>"子接口|vlan",descrip=>"单选子接口还是vlan"
id=>sub_eth,name=>子接口选择,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"选择子接口的名称"
id=>vlan_eth,name=>vlanID,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"填写vlan的ID号"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def add_passage(hash={})
        json_hash = get_add_passage_hash(hash)
        DeviceConsole::check_post_result(FluxManagerCGI,json_hash,{"info" => "添加流控通道"})
      end

=begin rdoc
关键字名: 删除流控通道
描述: 删除流控通道
维护人: 王沃伦
参数:
id=>name,name=>策略名称,type=>s,must=>false,default=>"全部删除",value=>"{text}",descrip=>"策略的名字,以@;@作为分隔符号分隔,如果要全部删除,则这里填 '全部删除' 即可"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def del_passage(hash={})
        json_hash = get_del_passage_hash(hash)
        DeviceConsole::check_post_result(FluxManagerCGI,json_hash,{"info" => "删除流控通道"})
      end

=begin rdoc
关键字名: 编辑流控通道
描述: 编辑流控通道
维护人: 王沃伦
参数:
id=>name,name=>通道名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"这个是通道名称"
id=>enable,name=>是否启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用通道"
id=>line,name=>生效线路,type=>s,must=>false,default=>"1",value=>"1|2|3|4|5|6|7",descrip=>"生效线路的数字"
id=>passage_type,name=>带宽通道类型,type=>s,must=>false,default=>"限制通道",value=>"限制通道|保证通道",descrip=>"选择保证带宽还是限制带宽"
id=>ensure_up_rate,name=>保证上行百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"上行保证带宽占的百分比,用不超过100的数字"
id=>ensure_upmax_rate,name=>保证上行最大百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"上行保证带宽占的最大的百分比,用不超过100的数字"
id=>ensure_down_rate,name=>保证下行百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"下行保证带宽占的百分比,用不超过100的数字"
id=>ensure_downmax_rate,name=>保证下行最大百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"下行保证带宽占的最大的百分比,用不超过100的数字"
id=>ensure_priority,name=>保证带宽优先级,type=>s,must=>false,default=>"High",value=>"High|Medium|Low",descrip=>"保证的带宽优先级"
id=>limit_upmax_rate,name=>限制上行百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"下行限制带宽占的百分比,用不超过100的数字"
id=>limit_downmax_rate,name=>限制下行百分比,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"下行限制带宽占的百分比,用不超过100的数字"
id=>limit_priority,name=>限制带宽优先级,type=>s,must=>false,default=>"High",value=>"High|Medium|Low",descrip=>"限制的带宽优先级"
id=>is_enable_single_ip_speed,name=>是否启用单IP最大带宽,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"勾选启用与否单IP限制带宽的功能"
id=>single_ip_up_max,name=>单IP限制最大上传速率,type=>s,must=>false,default=>"50",value=>"{text}",descrip=>"单IP下行限制带宽占的百分比,用不超过100的数字"
id=>single_ip_down_max,name=>单IP限制最大下载速率,type=>s,must=>false,default=>"50",value=>"{text}",descrip=>"单IP下行限制带宽的具体速率,必须是数字,以KB为单位"
id=>is_enable_advance,name=>是否启用高级选项,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"勾选启用与否高级选项的功能"
id=>apply_app_type,name=>适用应用类型,type=>s,must=>false,default=>"所有应用",value=>"所有应用|自定义",descrip=>"单选使用的应用类型"
id=>custom_app_selected,name=>自定义应用具体选择的应用,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"具体选择自定义的应用,编写规则如下: 每个选择的应用之间用'@;@'隔开,选择的每个应用有三个数据元,第一个是数据所属类别,第二个是应用所属的上级目录,一个是应用具体的名称,如: 文件类型@_@电影"
id=>apply_obj_type,name=>适用对象选择,type=>s,must=>false,default=>"IP组",value=>"IP组|用户",descrip=>"单选适用IP组还是用户组"
id=>ip_group,name=>IP组名称,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"选择的IP组的名称"
id=>user_group,name=>用户组,type=>s,must=>false,default=>"/",value=>"{text}",descrip=>"选择的IP组的名称"
id=>time_group_name,name=>生效时间,type=>s,must=>false,default=>"2*0*全天",value=>"{text}",descrip=>"时间计划组的名称"
id=>dstip_group,name=>目标IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"选择的目标IP组的名称"
id=>interface_selected,name=>选择的子接口还是vlan,type=>s,must=>false,default=>"子接口",value=>"子接口|vlan",descrip=>"单选子接口还是vlan"
id=>sub_eth,name=>子接口选择,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"选择子接口的名称"
id=>vlan_eth,name=>vlanID,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"填写vlan的ID号"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def edit_passage(hash={})
        json_hash = get_edit_passage_hash(hash)
        DeviceConsole::check_post_result(FluxManagerCGI,json_hash,{"info" => "编辑流控通道"})
      end

=begin rdoc
关键字名: 新增流控排除策略
描述: 新增流控排除策略
维护人: 王沃伦
参数:
id=>name,name=>策略名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"排除策略的名称"
id=>type,name=>应用类型,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"适用的应用类型"
id=>dip,name=>目标IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"目标IP组"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def add_exclude_rule(hash={})
        json_hash = get_add_exclude_hash(hash)
        DeviceConsole::check_post_result(FluxManagerCGI,json_hash,{"info" => "添加流控排除策略"})
      end

=begin rdoc
关键字名: 编辑流控排除策略
描述: 编辑流控排除策略
维护人: 王沃伦
参数:
id=>name,name=>策略名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"排除策略的名称"
id=>type,name=>应用类型,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"适用的应用类型"
id=>dip,name=>目标IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"目标IP组"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def edit_exclude_rule(hash={})
        json_hash = get_edit_exclude_hash(hash)
        DeviceConsole::check_post_result(FluxManagerCGI,json_hash,{"info" => "修改流控排除策略"})
      end

=begin rdoc
关键字名: 删除流控排除策略
描述: 删除流控排除策略
维护人: 王沃伦
参数:
id=>name,name=>策略名称,type=>s,must=>false,default=>"全部删除",value=>"{text}",descrip=>"策略的名字,以@;@作为分隔符号分隔,如果要全部删除,则这里填 '全部删除' 即可"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def del_exclude_rule(hash={})
        json_hash = get_del_exclude_hash(hash)
        DeviceConsole::check_post_result(FluxManagerCGI,json_hash,{"info" => "删除流控排除策略"})
      end


      #end of class PassageWay
    end
    #don't add any code after here.

  end

end
