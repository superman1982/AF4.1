# coding: utf8
module LocalPc
  module NetworkAccess
    module FtpHelper

      # ftp文件下载后的本地保存文件(带路径)
      def get_real_path(filenamepath)
        real_path = ""
        if filenamepath.include?(':')
          real_path = filenamepath.to_gbk
          return real_path
        end
        real_path = File.expand_path(File.join(ATT::ConfigureManager.root, "temp", filenamepath).to_gbk).to_s
        ATT::KeyLog.info("real_path = #{real_path}")
        return real_path
      end
    
    end
  end
end
