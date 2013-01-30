# coding: utf8
=begin rdoc
作用: 封装路由模块的关键字
维护记录:
维护人      时间                  行为
gsj     2011-12-07              创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module NetConfig


=begin rdoc
类名: 路由
描述: 路由
=end
    class Route < ATT::Base

=begin rdoc
关键字名: 新增单个静态路由
描述: 新增单个静态路由
参数:
id=>dest_address,name=>目的地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"目的地址,不能为空"
id=>netmask,name=>网络掩码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"网络掩码,不能为空"
id=>next_nop,name=>下一跳IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"下一跳IP地址,不能为空"
id=>interface,name=>接口,type=>s,must=>false,default=>"自动选择接口",value=>"{text}",descrip=>"接口"
id=>metric_value,name=>度量值,type=>i,must=>false,default=>"0",value=>"{text}",descrip=>"度量值"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_single_static_route(hash)
        ATT::KeyLog.debug("add single static route......")
        post_hash = get_add_single_static_route_post_hash( hash )
        result_hash = AF::Login.get_session().post(StaticRouteCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 删除静态路由
描述: 删除指定的静态路由
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定的静态路由,还是删除目前所有的静态路由"
id=>routes,name=>静态路由列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的静态路由,每个静态路由的格式如'目的地址/网络掩码/下一跳IP/度量值',多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|静态路由格式错误|静态路由不存在",descrip=>""
=end
      def delete_static_route( hash )
        ATT::KeyLog.debug("delete static route......")
        if hash[:delete_type] == "全部删除"
          route_name_array = DeviceConsole::get_all_object_names(StaticRouteCGI, "静态路由")
        else
          route_name_array = get_static_route_names( hash[:routes] )
        end
        return_ok if route_name_array.empty? # 已经没有任何静态路由了
        post_hash = {"opr" => "deleteRoute", "name" => route_name_array }
        result_hash = AF::Login.get_session().post(StaticRouteCGI, post_hash)
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
