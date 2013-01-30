# coding: utf8
=begin rdoc
作用: 请输入作用
维护记录:
维护人      时间                  行为
[王沃伦]     2012-08-25                     创建
=end

module DeviceConsole

  module RunState


=begin rdoc
类名: 联动封锁源IP
描述: 界面的"联动封锁源IP"相关操作
=end
    class IpBlockStat < ATT::Base

=begin rdoc
关键字名: 解除封锁IP
描述: 针对界面上的勾选中某个IP后的"解除封锁"按钮
维护人: 王沃伦
参数:
id=>block_ip_str,name=>解除封锁源IP列表,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"勾选的封锁IP的列表,多个封锁IP之间用&隔开"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def relieve_ip_block(hash={})
        ATT::KeyLog.debug("解除封锁IP......")
        post_hash = get_relieve_ipblock_post_hash( hash )
        result_hash = AF::Login.get_session().post(IP_BLOCK_STAT_CGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("解除封锁IP:==========错误消息是: ** #{result_hash["msg"]} **")
          return_fail
        end
      end

=begin rdoc
关键字名: 清除所有封锁IP
描述: 对应界面中的"清除所有封锁IP"按钮操作
维护人: 王沃伦
参数:
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def clear_ip_block(hash={})
        ATT::KeyLog.debug("清除所有封锁IP......")
        post_hash = get_clear_ipblock_post_hash( hash )
        result_hash = AF::Login.get_session().post(IP_BLOCK_STAT_CGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("清除所有封锁IP :==========错误消息是: ** #{result_hash["msg"]} **")
          return_fail
        end
      end

=begin rdoc
关键字名: 设置IP封锁时间
描述: 对应界面中的"设置IP封锁时间"按钮操作
维护人: 王沃伦
参数:
id=>lock_time,name=>封锁时间,type=>s,must=>false,default=>"10",value=>"{text}",descrip=>"所设置的封锁IP时间"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def set_ip_block_time(hash={})
        ATT::KeyLog.debug("设置IP封锁时间......")
        post_hash = {"opr" => "modify", "data" => {"locktime" => hash[:lock_time].to_i} }
        result_hash = AF::Login.get_session().post(IP_BLOCK_STAT_CGI, post_hash)
        if result_hash["success"]
          return_ok
        else
          ATT::KeyLog.info("设置IP封锁时间 :==========错误消息是: ** #{result_hash["msg"]} **")
          return_fail
        end
      end

=begin rdoc
关键字名: 检查IP被封锁
描述: 检查某个IP是否被封锁了
维护人: 王沃伦
参数:
id=>ip_addrs,name=>检查的ip地址,type=>s,must=>ture,default=>"1.1.1.1",value=>"{text}",descrip=>"多个时用&分开"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def check_ip_block(hash={})
        ATT::KeyLog.debug("检查IP被封锁......")
        all_ip_block = DeviceConsole::get_all_object_attrib(IP_BLOCK_STAT_CGI, "IP被封锁","ip") # 获取所有被封锁的IP属性
        ip_block_count = 0
        (hash[:ip_addrs].split("&")).each do |ip_addr|
          all_ip_block.each do |ip|
            if (ip == ip_addr)
              ip_block_count += 1
              ATT::KeyLog.info("ip :#{ip_addr}找到在封锁中 **")
            end
          end
        end
        if ip_block_count == hash[:ip_addrs].split("&").size
          return_ok
        else
          ATT::KeyLog.error("没能全找到预期封锁的IP ===========**")
          return_fail
        end
      end      

      #end of class IpBlockStat
    end
    #don't add any code after here.

  end

end
