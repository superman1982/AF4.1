# coding: utf8
=begin rdoc
作用: 封装对象定义下漏洞特征识别库的操作
维护记录:
维护人      时间                  行为
gsj     2012-05-24              创建
=end

module DeviceConsole

  module ObjectDefinition


=begin rdoc
类名: 漏洞特征识别库
描述: 漏洞特征识别库
=end
    class HoleLibrary < ATT::Base

=begin rdoc
关键字名: 编辑漏洞特征识别库
描述: 编辑某个内置的漏洞,修改其动作
维护人: gsj
参数:
id=>hole_id,name=>漏洞ID,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要编辑的漏洞的ID"
id=>operation,name=>动作,type=>s,must=>false,default=>"检测后拦截",value=>"检测后拦截|检测后放行|与云分析引擎联动|禁用",descrip=>"动作"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|漏洞不存在",descrip=>"期望结果"
=end
      def edit_hole_recognition_library(hash)
        hole_id = hash[:hole_id].to_i
        ATT::KeyLog.info("编辑漏洞ID:#{hole_id}的设置")
        old_data_hash = get_original_setting_of_hole(hole_id ) # 获取当前漏洞ID原来的信息
        new_data_hash = get_new_setting_of_hole(old_data_hash, hash[:operation]) # 修改设置的hash

        post_hash = { "opr" => "modify", "data" => new_data_hash }
        result_hash = AF::Login.get_session().post(HoleLibraryCGI, post_hash)
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
