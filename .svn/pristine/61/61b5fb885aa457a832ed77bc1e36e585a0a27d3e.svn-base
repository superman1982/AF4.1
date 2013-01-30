# coding: utf8
=begin rdoc
作用: 封装系统节点下日志设置页面上的操作
维护记录:
维护人      时间                  行为
gsj     2012-01-29              创建
=end

module DeviceConsole

  module System


=begin rdoc
类名: 日志设置
描述: 日志设置
=end
    class LogSetting < ATT::Base

=begin rdoc
关键字名: 内置数据中心日志设置
描述: 修改内置数据中心的日志设置
维护人: gsj
参数:
id=>enable_inner_dc,name=>启用内置数据中心,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用内置数据中心,默认启用"
id=>method,name=>删除方法,type=>s,must=>false,default=>"天数",value=>"天数|磁盘空间",descrip=>"按天数还是磁盘空间来删除内置数据中心的日志"
id=>days,name=>最长保存天数,type=>s,must=>false,default=>"15",value=>"{text}",descrip=>"选择按天数自动删除日志时,输入的最长保存天数"
id=>percentage,name=>最大磁盘比例,type=>s,must=>false,default=>"80",value=>"{text}",descrip=>"选择按磁盘空间自动删除日志时,输入的最大磁盘比例"
id=>enable_merge,name=>启用日志归并,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用日志归并,默认启用"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def modify_inner_dc_setting(hash)
        post_hash = get_inner_dc_setting_post_hash(hash)
        result_hash = AF::Login.get_session().post(LogSettingCGI, post_hash)
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
