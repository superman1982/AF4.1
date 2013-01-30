=begin rdoc
作用: 封装执行主机上系统管理相关的操作
维护记录:
维护人      时间                  行为
gsj     2011-12-09              创建
=end

module LocalPc


=begin rdoc
类名: 系统管理
描述: 系统管理
=end
  class SystemManagement < ATT::Base

=begin rdoc
关键字名: 添加IP地址
描述: 为执行主机上的某个网卡添加IP地址
参数:
id=>connection_name,name=>连接名称,type=>s,must=>false,default=>"本地连接",value=>"{text}",descrip=>"要在此连接上添加IP地址,默认是本地连接"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要添加的IP地址"
id=>mask,name=>子网掩码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要添加的IP地址对应的掩码"
id=>gateway,name=>网关,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"网关,默认的空"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def add_ip_address(hash)
      gateway = hash[:gateway].to_s.empty? ? nil : hash[:gateway]
      begin
        ATT::LocalPC.add_ip(hash[:ip], hash[:mask], gateway, hash[:connection_name])
      rescue Exception
        ATT::KeyLog.error("#{$!.class},#{$!.message}")
        return_fail
      end
      return_ok
    end

=begin rdoc
关键字名: 删除IP地址
描述: 在执行主机上的某个网卡上删除IP地址
参数:
id=>connection_name,name=>连接名称,type=>s,must=>false,default=>"本地连接",value=>"{text}",descrip=>"要在此连接上添加IP地址,默认是本地连接"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要添加的IP地址"
id=>gateway,name=>网关,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"网关,默认的空"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def delete_ip_address(hash)
      gateway = hash[:gateway].to_s.empty? ? nil : hash[:gateway]
      begin
        ATT::LocalPC.delete_ip(hash[:ip], gateway, hash[:connection_name])
      rescue Exception
        ATT::KeyLog.error("#{$!.class},#{$!.message}")
        return_fail
      end
      return_ok
    end
    
=begin rdoc
关键字名: 设置IP地址
描述: 为执行主机上的某个网卡设置IP地址
参数:
id=>connection_name,name=>连接名称,type=>s,must=>false,default=>"本地连接",value=>"{text}",descrip=>"要在此连接上设置IP地址,默认是本地连接"
id=>ip,name=>IP地址,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要设置的IP地址"
id=>mask,name=>子网掩码,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"要设置的IP地址对应的掩码"
id=>gateway,name=>网关,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"网关,默认的空"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def set_ip_address(hash)
      gateway = hash[:gateway].to_s.empty? ? "none" : hash[:gateway]
      begin
        ATT::LocalPC.set_ip(hash[:ip], hash[:mask], gateway, hash[:connection_name])
      rescue Exception
        ATT::KeyLog.error("#{$!.class},#{$!.message}")
        return_fail
      end
      return_ok
    end

=begin rdoc
关键字名: 获取IP地址
描述: 获取执行主机的IP地址
维护人: zwjie
参数:
id=>ip_key,name=>IP字段,type=>s,must=>false,default=>"IPv4 地址&IP Address",value=>"#{text}",descrip=>"执行ipconfig后指定IP地址所在行的标识符"
id=>which,name=>IP下标,type=>i,must=>false,default=>"1",value=>"#{text}",descrip=>"指定返回那个IP地址，默认是返回第1个"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
      def exec_ipconfig_cmd(hash)
        command = "ipconfig"
        exec_result = ATT::LocalPC.execute_cmd(command)
        ATT::KeyLog.info("执行#{command}的结果是:\n#{exec_result}")
        get_ip = []
        ips = hash[:ip_key].split("&")
        ips.each do |ip|
          if exec_result.include?(ip)
            ip_hash = exec_result.scan(/#{ip}[^:]*:[^:\n]*/)
            ip_hash.each do |every_ip|
              get_ip << every_ip.split(":")[1]
            end
            length = get_ip.length
            ATT::KeyLog.info("执行命令ipconfig后，获取到的IP地址有#{length}个，分别是:")
            i = 1
            get_ip.each  do |ip|
              ATT::KeyLog.info("IP#{i}:#{ip}")
              i = i + 1
            end
            ATT::KeyLog.info("#{[length,get_ip]}")
            if(hash[:which] < 1 || hash[:which] > length)
             ATT::KeyLog.debug("执行命令ipconfig后有#{length}个IP，指定要获取第#{hash[:which]}个IP不存在")
             return_fail
            else
            ATT::KeyLog.info("指定获取的IP地址是：#{get_ip[hash[:which]-1]}")
            return get_ip[hash[:which]-1]
            end
          end
        end
        ATT::KeyLog.error("执行命令ipconfig后,没有指定的#{hash[:ip_key].split("&").join(",")}字段")
        return_fail
    end

=begin rdoc
关键字名: 设置DNS服务器地址
描述: 在执行主机上的某个网卡上设置DNS服务器地址,参数首选DNS为空表示清除所有DNS服务器地址
参数:
id=>connection_name,name=>连接名称,type=>s,must=>false,default=>"本地连接",value=>"{text}",descrip=>"要在此连接上设置DNS服务器,默认是本地连接"
id=>first_dns,name=>首选DNS,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"首选DNS服务器地址,取值为空时清空DNS服务器设置"
id=>secondary_dns,name=>备选DNS,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"备选DNS,默认是空"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def set_dns_server_addresses(hash)
      if hash[:first_dns].to_s.empty? # 首选DNS是空,设置DNS服务器地址为空
        begin
          ATT::LocalPC.clear_dns( hash[:connection_name] )
        rescue Exception
          ATT::KeyLog.error("#{$!.class},#{$!.message}")
          return_fail
        end
      else # 设置DNS服务器地址
        secondarydns  = hash[:secondary_dns].to_s.empty? ? nil : hash[:secondary_dns]
        begin
          ATT::LocalPC.set_dns(hash[:first_dns], secondarydns, hash[:connection_name])
        rescue Exception
          ATT::KeyLog.error("#{$!.class},#{$!.message}")
          return_fail
        end
      end
      return_ok
    end
=begin rdoc
关键字名: 清除本地DNS缓存
描述: 在执行主机上清除DNS缓存
参数:
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>""
=end
    def clear_local_dns_cache( hash )
      flush_command = "ipconfig /flushdns"
      flush_result = ATT::LocalPC.execute_cmd(flush_command)
      ATT::KeyLog.info("执行#{flush_command}的结果是#{flush_result}")
      if flush_result.include?("已成功刷新 DNS 解析缓存") || flush_result.include?("Successfully flushed the DNS Resolver Cache")
        return_ok
      end
      return_fail
    end

=begin rdoc
关键字名: 查找进程ID
描述: 在执行主机上执行tasklist,查找指定进程名的进程ID
参数:
id=>process_name,name=>进程名称,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"查找此名称的进程ID"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def find_process_id( hash )
      process_name = hash[:process_name]
      pid_array = find_pid_of_specified_process( process_name ) # 返回指定名称的进程所有进程ID
      if pid_array.empty?
        ATT::KeyLog.error("进程:#{process_name}不存在...")
        return_fail
      else
        return [ pid_array[0] ] # 若有多个同名进程时,仅返回第一个进程的ID
      end
    end
    
=begin rdoc
关键字名: 强制杀死进程
描述: 强制杀死进程指定ID的进程
参数:
id=>pid,name=>进程ID,type=>s,must=>true,default=>"",value=>"{text}",descrip=>"杀死此ID的进程"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def force_to_kill_pid( hash )
      sleep 5 # 稍等
      tskill_command = "tskill #{hash[:pid]}"
      tskill_result = ATT::LocalPC.execute_cmd(tskill_command)
      ATT::KeyLog.debug("执行#{tskill_command}的结果是:#{tskill_result.dump}")
      if !tskill_result.strip.empty? && tskill_result.strip.include?("找不到进程")
        ATT::KeyLog.debug("ID是#{hash[:id]}的进程不存在...")
      end
      return_ok
    end

=begin rdoc
关键字名: 执行CMD命令
描述: 执行一个CMD命令(封装特殊的功能有:1.清空IE缓存)
参数:
id=>cmd,name=>执行命令,type=>s,must=>true,default=>"dir",value=>"{text}",descrip=>"执行的CMD命令,现封装有关键字特殊命令: cleanIEcache => 清空IE缓存"
id=>checkpoint,name=>检查点,type=>s,must=>false,default=>"",value=>"{text}",descrip=>"检查点,多个可用&隔开,第一个若为dilimiter=xxx,则xxx为结果的分隔符,紧接着第二个应该未结果分隔块的key,例子:'dilimiter=abc&key=name&checkpoint"
id=>occurtimes,name=>包含条数,type=>s,must=>false,default=>"0",value=>"{text}",descrip=>"多行内容出现检查点的条数,每行不管出现多少次,都算1条"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败",descrip=>"期望结果"
=end
    def force_to_kill_pid( hash )
      command = ""
      if(hash[:cmd] == "cleanIEcache")
        Thread.new{ AF::Util.clear_ie_cache() }
        command = "set \"z=HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\" & for %a in (cache history cookies) do ( for /f \"tokens=2*\" %b in (\'reg query \"%z%\" /v %a\') do (if exist \"%c\" (del /f /s /q \"%c\")))"
      else
        command = hash[:cmd]
      end
      result = ATT::LocalPC.execute_cmd(command)
      ATT::KeyLog.debug("执行#{command}的结果是:#{result.dump}")
      # => 沃伦把设备后台代码和PC运行命令代码重复部分重构,抽象起来了
      return AF::Util.check_command_result(result,hash[:checkpoint],hash[:occurtimes])
    end
    
  end
end
