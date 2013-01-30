require 'watir'

module Watir
  class IE

    # 部分系统path会是纯小写,修复watir库中的该bug
    def self.each
      shell = WIN32OLE.new('Shell.Application')
      shell.Windows.each do |window|
        next unless (window.path =~ /Internet Explorer/i rescue false)
        next unless (hwnd = window.hwnd rescue false)
        ie = IE.bind(window)
        ie.hwnd = hwnd
        yield ie
      end
    end

    def self.record()
      @@hwnds = []
      each do |ie|
        #$log.debug ie.hwnd
        @@hwnds << ie.hwnd
      end
    end
    
    def self.attach_new()
      Watir::IE.attach_timeout = 30
      raise ArgumentError,"please call method 'record' before call me" unless defined?(@@hwnds)
      begin
        Watir::Wait.until do
          each do |ie|
            unless @@hwnds.include?(ie.hwnd)
              @@hwnds << ie.hwnd
              ie.wait
              return ie
            end
          end
          nil
        end
      rescue TimeOutException
      end
      raise NoMatchingWindowFoundException,"cannot found a new ie window"
    end

    def goto_no_wait(url)
      @ie.navigate(url)
      sleep 3
    end

  end
end

# 修正click_no_wait bug
require 'watir/page-container'
module Watir
	module PageContainer
		def eval_in_spawned_process(command)
			#puts 'call me'
		  command.strip!
		  load_path_code = _code_that_copies_readonly_array($LOAD_PATH, '$LOAD_PATH')
		  ruby_code = "require 'watir/ie'; "
		  # ruby_code = "$HIDE_IE = #{$HIDE_IE};" # This prevents attaching to a window from setting it visible. However modal dialogs cannot be attached to when not visible.
		  ruby_code << "pc = #{attach_command}; " # pc = page container
		  # IDEA: consider changing this to not use instance_eval (it makes the code hard to understand)
		  ruby_code << "pc.instance_eval(#{command.inspect})"
		  #exec_string = "start rubyw -e #{(load_path_code + '; ' + ruby_code).inspect}"
		  exec_string = "start rubyw -e #{(load_path_code + '; ' + ruby_code).gsub('"','\'').inspect}"
		  system(exec_string)
		end
	end
end

module Watir
  class Element

    def assert_exists
      begin
        Watir::Wait.until(20) { exists? }
      rescue
        ATT::KeyLog.error("assert_exists fail:　#{$!.class},#{$!.message}")
      end
      locate if respond_to?(:locate)
      unless ole_object
        raise UnknownObjectException.new(
          Watir::Exception.message_for_unable_to_locate(@how, @what))
      end
    end
    
  end
end

module Watir
  class IE

    # 打开一个新的浏览器窗口,如果打开失败,则重复直到打开成功为止
    def self.my_new
      begin
        dc_browser = Watir::IE.new # 创建浏览器可能会失败
      rescue Exception
        ATT::KeyLog.debug("发生异常:#{$!.class},稍后重新打开浏览器...")
        sleep 5
        retry
      end
      return dc_browser
    end

  end
end

module Watir
  class Frame

    # 执行js脚本
    def run_js(js_str)
      document.parentWindow.execScript(js_str)
    end
    
  end
end

module Watir
  class TextField
    # 文本框支持中文
    def characters_in(value, &blk)
      if RUBY_VERSION =~ /^1\.8/
        index = 0
        while index < value.length
		  if WIN32OLE.codepage ==  WIN32OLE::CP_UTF8
		    len = value[index] > 128 ? 3 : 1
		  else
		    len = value[index] > 128 ? 2 : 1
		  end
          yield value[index, len]
          index += len
        end
      else
        value.each_char(&blk)
      end
    end
  end
end