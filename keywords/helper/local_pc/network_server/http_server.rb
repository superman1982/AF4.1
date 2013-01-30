# coding: utf8
module LocalPc
  module NetworkServer
    module HttpServerHelper
      def get_http_respone_head(hash,str)
        if (str == nil or str.empty? )
          return ;
        end
        str.split("&;&").each do |respone_head_line|
          respone_head_line_array = respone_head_line.split(":")
          hash[respone_head_line_array[0]] = []
          hash[respone_head_line_array[0]][0] = 1
          hash[respone_head_line_array[0]][1] = respone_head_line_array[1]
        end
      end
    end
  end
end
