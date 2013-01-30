# coding: utf8
require 'yaml'
module ATT
  class DataMap
    @data_map =  ATT::ConfigureManager.get('data_map') #YAML.load_file(File.join(ATT::ConfigureManager.root,'config/data_map.yml')) 
    class <<self
      def [](key)
        ret = @data_map[key]
        if ret.nil?
          raise "read data_map '#{key}' failed, it' nil, but do you forget to config it ?"
        end
        ret
      end
      
      #for test
      def []=(key,v)
        @data_map[key] = v 
      end
    end
  end
  
end
