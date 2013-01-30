# coding: utf8
=begin rdoc
作用: 封装设备后台系统本身的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-09              创建
=end

module DeviceBack


=begin rdoc
类名: 系统操作
描述: 系统操作
=end
  class SystemOperation < ATT::Base

=begin rdoc
关键字名: 后台执行命令
描述: 后台执行命令
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>sshcommand,name=>执行命令,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要执行的命令"
id=>checkpoint,name=>检查点,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"检查点,【沃伦添加】多个可用&隔开,第一个若为dilimiter=xxx,则xxx为结果的分隔符,紧接着第二个应该未结果分隔块的key,例子:'dilimiter=abc&key=name&checkpoint【沃伦添加】"
id=>occurtimes,name=>包含条数,type=>s,must=>false,default=>"0",value=>"{text}",descrip=>"多行内容出现检查点的条数,每行不管出现多少次,都算1条"
id=>block,name=>是否阻塞,type=>s,must=>false,default=>"是",value=>"是|否",descrip=>"默认是阻塞的,即执行完命令再返回"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def exec_command(hash)
      ssh_connection = ATT::TestDevice.new(hash[:devicename])
      result = ""
      ATT::KeyLog.info "执行的命令是 :::: #{hash[:sshcommand]}"
      value,result = ssh_connection.exec_command(hash[:sshcommand]) if hash[:block]=="是"
      value,result = ssh_connection.exec_command_nowait(hash[:sshcommand]) if hash[:block]=="否"
      ATT::KeyLog.debug("返回值是 ::::value = #{value}")
      # => 沃伦把设备后台代码和PC运行命令代码重复部分重构,抽象起来了
      return AF::Util.check_command_result(result,hash[:checkpoint],hash[:occurtimes])
    end

=begin rdoc
关键字名: 等待至外网IP解封
描述: 等待,直到指定的外网IP从外网DOS防护黑名单(/proc/net/wandos/sipdeny)中消失
维护人: gsj
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>ip,name=>IP,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"等待此IP从外网DOS防护黑名单中消失"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def wait_until_wan_ip_free( hash )
      ip = hash[:ip]
      ATT::KeyLog.info("要等待外网DOS防护黑名单中的#{ip}被解封...")
      ssh_connection = ATT::TestDevice.new(hash[:devicename])
      while true
        value,result = ssh_connection.exec_command("cat /proc/net/wandos/sipdeny")
        if result.include?(ip)
          ATT::KeyLog.info("#{ip}仍在外网DOS防护黑名单中...")
          sleep 5
        else
          ATT::KeyLog.info("#{ip}在外网DOS防护黑名单中消失了...")
          break
        end
      end
      sleep 5 ; return_ok
    end

=begin rdoc
关键字名: 清除扫描攻击黑名单
描述: 清除IP地址扫描,ICMP扫描,端口扫描,SYN扫描产生的黑名单,避免等待被封锁的时间
维护人: gsj
参数:
id=>devicename,name=>设备名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要操作的设备名称,与test_device.yml中的名称一致"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def clear_source_and_dst_in_blacklist( hash )
      ssh_connection = ATT::TestDevice.new(hash[:devicename])
      FLUSH_COMMAND_ARRAY.each do |flush_command|
        value,result = ssh_connection.exec_command(flush_command)
      end
      ssh_connection.close
      return_ok
    end

  end
end
