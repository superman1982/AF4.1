module AF
  class MyBrowser

    # watir获取浏览器版本
    def self.check_ie_version(ie)
      n = ie.document.invoke('parentWindow').navigator.appVersion
      m=/MSIE\s(.*?);/.match(n)

      if m and m[1] == '8.0'
        '8.0'
      elsif m and m[1] == '7.0'
        '7.0'
      elsif m and m[1] == '6.0'
        '6.0'
      elsif m and m[1] == '9.0'
        '9.0'
      else
        raise ArgumentError,'未知的浏览器版本'
      end
    end

    # 关闭所有的浏览器窗口
    def self.close_browsers
      `tskill iexplore`
    end

    # 清空IE浏览器的缓存
    def self.clear_ie_cache
      cache_ie = Watir::IE.new
      cache_ie.visible = false
      control = WIN32OLE.new("HttpWatch.Controller")
      begin
        plugin = control.IE.Attach(cache_ie.ie)
      rescue Exception
        plugin = control.Attach(cache_ie.ie) # win2000系统上使用低版本的httpwatch,与高版本的httpwatch的接口不一致
      end
      plugin.ClearCache()
      cache_ie.close()
    end
    
  end
end