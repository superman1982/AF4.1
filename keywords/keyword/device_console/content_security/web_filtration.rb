# coding: utf8
=begin rdoc
作用: 封装WEB过滤页面上的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-08              创建
=end
require 'keywords/keyword/device_console'

module DeviceConsole

  module ContentSecurity


=begin rdoc
类名: WEB过滤
描述: WEB过滤
=end
    class WebFiltration < ATT::Base

=begin rdoc
关键字名: 新增URL过滤
描述: 新增URL过滤规则
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"URL过滤规则的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此URL过滤规则"
id=>description,name=>描述,type=>s,must=>false,default=>"zwjTest",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>source_group_type,name=>源用户类型,type=>s,must=>false,default=>"IP组",value=>"IP组|用户组",descrip=>"源用户选择IP组还是用户组"
id=>source_ip,name=>源IP组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当源用户选择IP组时,选择的IP组,多个时使用&分割"
id=>source_user,name=>源用户组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当源用户选择用户组时,选择的用户或组,若是用户组则使用其全路径,如'/默认组/',若是用户则直接使用用户名,多个时使用&分割,格式如'/默认组/&test'"
id=>url_type,name=>URL分类,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"选择的URL类型,多个时使用&分割,格式如'网上银行&电信业&幽默笑话&未分类'"
id=>http_get,name=>HTTPGET,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选HTTP(get)"
id=>http_post,name=>HTTPPOST,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选HTTP(post)"
id=>https,name=>HTTPS,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选HTTPS"
id=>take_effect_time,name=>生效时间,type=>s,must=>false,default=>"全天",value=>"{text}",descrip=>"生效时间,时间计划的名称"
id=>operation,name=>动作,type=>s,must=>false,default=>"拒绝",value=>"允许|拒绝",descrip=>"拒绝还是允许"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用勾选记录日志"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def add_url_filtration_rule(hash)
        ATT::KeyLog.debug("add url filtration rule......")
        post_hash = get_add_url_filtration_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(URLFiltrationCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
=begin rdoc
关键字名: 编辑URL过滤
描述: 编辑URL过滤规则
维护人: zwjie
参数:
id=>oldname,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"需要编辑URL过滤规则的名称"
id=>name,name=>新名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"URL过滤规则的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此URL过滤规则"
id=>description,name=>描述,type=>s,must=>false,default=>"zwjTest",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>source_group_type,name=>源用户类型,type=>s,must=>false,default=>"IP组",value=>"IP组|用户组",descrip=>"源用户选择IP组还是用户组"
id=>source_ip,name=>源IP组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当源用户选择IP组时,选择的IP组,多个时使用&分割"
id=>source_user,name=>源用户组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当源用户选择用户组时,选择的用户或组,若是用户组则使用其全路径,如'/默认组/',若是用户则直接使用用户名,多个时使用&分割,格式如'/默认组/&test'"
id=>url_type,name=>URL分类,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"选择的URL类型,多个时使用&分割,格式如'网上银行&电信业&幽默笑话&未分类'"
id=>http_get,name=>HTTPGET,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选HTTP(get)"
id=>http_post,name=>HTTPPOST,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选HTTP(post)"
id=>https,name=>HTTPS,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选HTTPS"
id=>take_effect_time,name=>生效时间,type=>s,must=>false,default=>"全天",value=>"{text}",descrip=>"生效时间,时间计划的名称"
id=>operation,name=>动作,type=>s,must=>false,default=>"拒绝",value=>"允许|拒绝",descrip=>"拒绝还是允许"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用勾选记录日志"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end    
      def edit_url_filtration_rule(hash)
        ATT::KeyLog.debug("edit url filtration rule......")
        post_hash = get_edit_url_filtration_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(URLFiltrationCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end  
      

=begin rdoc
关键字名: 删除URL过滤
描述: 删除URL过滤规则
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的URL过滤规则,还是删除目前所有的URL过滤规则"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的URL过滤规则名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_url_filteration_rule(hash)
        ATT::KeyLog.debug("delete url filtration rule......")
        if hash[:delete_type] == "全部删除"
          all_url_filteration_names = DeviceConsole::get_all_object_names(URLFiltrationCGI, "URL过滤规则") # 数组类型
        else
          all_url_filteration_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_url_filteration_names.empty? # 不存在任何URL过滤时,直接返回成功
        post_hash = {"opr" => "delete", "name" => all_url_filteration_names}
        result_hash = AF::Login.get_session().post(URLFiltrationCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end
     
=begin rdoc
关键字名: 启禁URL过滤
描述: 启禁URL过滤规则
维护人: zwjie
参数:
id=>enable_count,name=>操作个数,type=>s,must=>true,default=>"部分操作",value=>"部分操作|全部操作",descrip=>"操作指定名称的URL过滤,还是操作目前所有的URL过滤规则"
id=>names,name=>名称列表,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"当操作类型选择部分操作时,指定要操作的URL过滤规则名称,多个时使用&分割"
id=>enable_type,name=>操作类型,type=>s,must=>true,default=>"启用",value=>"启用|禁用",descrip=>"指定操作,是启用还是禁用"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_urlfilter(hash)
        ATT::KeyLog.debug("启用或禁用URL过滤规则.....")
        if hash[:enable_count] == "全部操作"
          all_url_policy_names = DeviceConsole::get_all_object_names(URLFiltrationCGI, "URL过滤规则") # 获取所有IPS策略的名称,数组类型
        else
          all_url_policy_names = hash[:names].to_s.split("&") # 数组类型
        end
        post_hash = {"opr" => ( hash[:enable_type] == "启用" ? "enable" : "disable"), "name" => all_url_policy_names }
        result_hash = AF::Login.get_session().post(URLFiltrationCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("启用或禁用URL过滤规则..错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 新增文件过滤
描述: 新增文件过滤规则
维护人: zwjie
参数:
id=>name,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"文件过滤规则的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此文件过滤规则"
id=>description,name=>描述,type=>s,must=>false,default=>"zwjTest",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>source_group_type,name=>源用户类型,type=>s,must=>false,default=>"IP组",value=>"IP组|用户组",descrip=>"源用户选择IP组还是用户组"
id=>source_ip,name=>源IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"当源用户选择IP组时,选择的IP组,多个时使用&分割"
id=>source_user,name=>源用户组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当源用户选择用户组时,选择的用户或组,若是用户组则使用其全路径,如'/默认组/',若是用户则直接使用用户名,多个时使用&分割,格式如'/默认组/&test'"
id=>file_type,name=>文件类型组,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"输入过滤文件类型组，多个以&隔开，例如电影&音乐"
id=>up,name=>上传,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选上传"
id=>down,name=>下载,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选下载"
id=>take_effect_time,name=>生效时间,type=>s,must=>false,default=>"全天",value=>"{text}",descrip=>"生效时间,时间计划的名称"
id=>operation,name=>动作,type=>s,must=>false,default=>"拒绝",value=>"允许|拒绝",descrip=>"拒绝还是允许"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用勾选记录日志"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
        def add_file_filtration_rule(hash)
        ATT::KeyLog.debug("add file filtration rule......")
        post_hash = get_add_file_filtration_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(FileFiltrationCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 编辑文件过滤
描述: 编辑文件过滤规则
维护人: zwjie
参数:
id=>oldname,name=>名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"需要编辑URL过滤规则的名称"
id=>name,name=>新名称,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"文件过滤规则的名称"
id=>enable,name=>启用,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否启用此文件过滤规则"
id=>description,name=>描述,type=>s,must=>false,default=>"zwjTest",value=>"{text}",descrip=>"描述"
id=>source_zone,name=>源区域,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"源区域,多个时使用&分割"
id=>source_group_type,name=>源用户类型,type=>s,must=>false,default=>"IP组",value=>"IP组|用户组",descrip=>"源用户选择IP组还是用户组"
id=>source_ip,name=>源IP组,type=>s,must=>false,default=>"全部",value=>"{text}",descrip=>"当源用户选择IP组时,选择的IP组,多个时使用&分割"
id=>source_user,name=>源用户组,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当源用户选择用户组时,选择的用户或组,若是用户组则使用其全路径,如'/默认组/',若是用户则直接使用用户名,多个时使用&分割,格式如'/默认组/&test'"
id=>file_type,name=>文件类型组,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"输入过滤文件类型组，多个以&隔开，例如电影&音乐"
id=>up,name=>上传,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选上传"
id=>down,name=>下载,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"是否勾选下载"
id=>take_effect_time,name=>生效时间,type=>s,must=>false,default=>"全天",value=>"{text}",descrip=>"生效时间,时间计划的名称"
id=>operation,name=>动作,type=>s,must=>false,default=>"拒绝",value=>"允许|拒绝",descrip=>"拒绝还是允许"
id=>record_log,name=>记录日志,type=>s,must=>false,default=>"否",value=>"是|否",descrip=>"是否启用勾选记录日志"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
        def edit_file_filtration_rule(hash)
        ATT::KeyLog.debug("edit file filtration rule......")
        post_hash = get_edit_file_filtration_rule_post_hash( hash )
        result_hash = AF::Login.get_session().post(FileFiltrationCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end


=begin rdoc
关键字名: 删除文件过滤
描述: 删除URL文件规则
维护人: zwjie
参数:
id=>delete_type,name=>删除类型,type=>s,must=>false,default=>"部分删除",value=>"部分删除|全部删除",descrip=>"删除指定名称的文件过滤规则,还是删除目前所有的URL过滤规则"
id=>names,name=>名称列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"当删除类型选择部分删除时,指定要删除的文件过滤规则名称,多个时使用&分割"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def delete_file_filteration_rule(hash)
        ATT::KeyLog.debug("delete file filtration rule......")
        if hash[:delete_type] == "全部删除"
          all_file_filteration_names = DeviceConsole::get_all_object_names(FileFiltrationCGI, "文件过滤规则") # 数组类型
        else
          all_file_filteration_names = hash[:names].to_s.split("&") # 数组类型
        end
        return_ok if all_file_filteration_names.empty? # 不存在任何文件过滤时,直接返回成功
        post_hash = {"opr" => "delete", "name" => all_file_filteration_names}
        result_hash = AF::Login.get_session().post(FileFiltrationCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end

=begin rdoc
关键字名: 启禁文件过滤
描述: 启禁文件过滤规则
维护人: zwjie
参数:
id=>enable_count,name=>操作个数,type=>s,must=>true,default=>"部分操作",value=>"部分操作|全部操作",descrip=>"操作指定名称的文件过滤,还是操作目前所有的文件过滤规则"
id=>names,name=>名称列表,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"当操作类型选择部分操作时,指定要操作的文件过滤规则名称,多个时使用&分割"
id=>enable_type,name=>操作类型,type=>s,must=>true,default=>"启用",value=>"启用|禁用",descrip=>"指定操作,是启用还是禁用"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
      def enable_disable_filefilter(hash)
        ATT::KeyLog.debug("启用或禁用文件过滤规则.....")
        if hash[:enable_count] == "全部操作"
          all_file_policy_names = DeviceConsole::get_all_object_names(FileFiltrationCGI, "文件过滤规则") # 获取所有IPS策略的名称,数组类型
        else
          all_file_policy_names = hash[:names].to_s.split("&") # 数组类型
        end
        post_hash = {"opr" => ( hash[:enable_type] == "启用" ? "enable" : "disable"), "name" => all_file_policy_names }
        result_hash = AF::Login.get_session().post(FileFiltrationCGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("启用或禁用文件过滤规则..错误消息是#{result_hash["msg"]}")
          return_fail
        end
      end


    end
  end
end
