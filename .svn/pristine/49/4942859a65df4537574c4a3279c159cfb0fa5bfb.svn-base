# coding: utf8
module AF
  class Util

    # 获取指定长度的数字字符串
    def self.randstr( len = 9 )
      chars = ("0".."9").to_a
      str = ""
      1.upto(len) do |i|
        str << chars[rand(chars.size-1)]
      end
      return str
    end
    
    def self.check_command_result(result,checkpoint,occurtimes)
      # => 以下为沃伦添加的代码逻辑,意图达到分隔返回的结果,然后对带特定key分隔的结果块进行检查点匹配
      # => 用来分析一些下发程序,来匹配下发程序能成功下发某个规则(因为下发程序一般都下发所有规则,打印的日志每个规则一块结果
      the_checkpoint_array = checkpoint.split("&")
      ATT::KeyLog.debug("得到的特殊检查点是 :: the_checkpoint = #{the_checkpoint_array.to_s} size = #{the_checkpoint_array.size} 
            \n[0] = #{the_checkpoint_array[0]} [1] = #{the_checkpoint_array[1]} \n 判断结果0 : #{the_checkpoint_array[0] =~ /^dilimiter=.+/}\n 判断结果1 : #{the_checkpoint_array[1] =~ /^key=.+/ }")
      if the_checkpoint_array.size == 3 and the_checkpoint_array[0] =~ /^dilimiter=.+/ and the_checkpoint_array[1] =~ /^key=.+/ 
        ATT::KeyLog.debug("这里进入了 woolen逻辑,判断是否分割块")
        dilimiter = the_checkpoint_array[0].split("=")[1]
        key = the_checkpoint_array[1].split("=")[1]
        final_result = result.split(dilimiter)
        final_result.each do |result_block|
          if result_block.include?(key)
            raise ATT::Exceptions::RightExecuteError,"成功" if occurtimes.to_i == 0 and result_block.include?(the_checkpoint_array[2])
            sum_times = 0
            result_block.each_line{|line| sum_times+=1 if line.include?(the_checkpoint_array[2])}
            if sum_times == occurtimes.to_i
              raise ATT::Exceptions::RightExecuteError,"成功"
            else
              log "匹配上Key但是没有匹配到足够的次数的checkpoint,其中key为: #{key} checkpoint为 : #{the_checkpoint_array[2]} , 次数为: #{hash[:occurtimes]}"
              raise ATT::Exceptions::RightExecuteError,"失败"
            end
          end
        end
        ATT::KeyLog.debug("这没有一个块包含KEY,result = #{result}")
        raise ATT::Exceptions::RightExecuteError,"失败"
      end
      # => end of 沃伦添加
      unless checkpoint.to_s.empty?
        if result.to_s.include?(checkpoint)
          raise ATT::Exceptions::RightExecuteError,"成功" if occurtimes.to_i == 0
          sum_times = 0
          result.each_line{|line| sum_times+=1 if line.include?(checkpoint)}
          if sum_times == occurtimes.to_i
            raise ATT::Exceptions::RightExecuteError,"成功"
          else
            log "The result is #{result};The checkpoint is #{checkpoint}.The expired occurtimes is #{occurtimes},but found occurtimes is #{sum_times}"
            raise ATT::Exceptions::RightExecuteError,"失败"
          end
        else
          ATT::KeyLog.debug("匹配失败了~!! 得到的返回输出是 ::\n#{result}")
          raise ATT::Exceptions::RightExecuteError,"失败"
        end
      end
    end
    # => 用httpwatch插件清空缓存
    def self.clear_ie_cache
      cache_ie = Watir::IE.new
      cache_ie.visible = false
      control = WIN32OLE.new("HttpWatch.Controller")
      plugin = control.IE.Attach(cache_ie.ie)
      plugin.ClearCache() # 清缓存
      plugin.ClearAllCookies() # 清cookie
      cache_ie.close()
    end
  end
end
