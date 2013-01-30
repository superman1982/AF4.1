# encoding: utf-8
=begin rdoc
作用: 请输入作用
维护记录:
维护人      时间                  行为
[王沃伦]     2012-12-28          创建
=end

module DeviceConsole

  module RunState


=begin rdoc
类名: 流量管理状态
描述: 检查流量管理状态的各种速度
=end
    class FluxView < ATT::Base

=begin rdoc
关键字名: 检测线路速率
描述: 检查线路的速率,包括配置的虚拟线路,以及总速率
维护人: 王沃伦
参数:
id=>name,name=>线路名称,type=>s,must=>false,default=>"总速率",value=>"{text}",descrip=>"线路的名称,可以为'总速率',或者对应的线路 '线路1','线路2'..."
id=>check_direction,name=>检测方向,type=>s,must=>false,default=>"下载",value=>"上传|下载",descrip=>"检测速率的方向,上传或下载"
id=>check_type,name=>检测类型,type=>s,must=>false,default=>"速率",value=>"速率|百分比",descrip=>"检测的类型,速率或者占用百分比"
id=>check_data,name=>检测范围,type=>s,must=>false,default=>"10@;@20",value=>"{text}",descrip=>"根据检测类型的不同定义为不同的含义,当检测类型是速率时,这是检测速率的范围上下限(单位为'bps'注意不是'Bps'),当检测类型是比率时,这里是百分比的上下限,上下限之间用 '@;@'隔开"
id=>check_times,name=>检测次数,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"检测的次数,默认检测的次数中有60%是在设定范围内的话,认为符合预期,检测将每隔一秒检测一次"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def check_main_speed(hash={})
        send_hash = {"opr" =>"listWanspeed"}
        check_n_times_data(hash,send_hash,"检测线路速率")
        
      end

=begin rdoc
关键字名: 检测通道速率
描述: 检测配置的通道的速率
维护人: 王沃伦
参数:
id=>name,name=>通道名称,type=>s,must=>false,default=>"默认通道",value=>"{text}",descrip=>"通道的名称,检测时根据这个名称定位"
id=>check_direction,name=>检测方向,type=>s,must=>false,default=>"下载",value=>"上传|下载",descrip=>"检测速率的方向,上传或下载"
id=>check_type,name=>检测类型,type=>s,must=>false,default=>"速率",value=>"速率|百分比",descrip=>"检测的类型,速率或者占用百分比"
id=>check_data,name=>检测范围,type=>s,must=>false,default=>"10@;@20",value=>"{text}",descrip=>"根据检测类型的不同定义为不同的含义,当检测类型是速率时,这是检测速率的范围上下限(单位为'bps'注意不是'Bps'),当检测类型是比率时,这里是百分比的上下限,上下限之间用 '@;@'隔开"
id=>check_times,name=>检测次数,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"检测的次数,默认检测的次数中有60%是在设定范围内的话,认为符合预期,检测将每隔一秒检测一次"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def check_passage_speed(hash={})
        send_hash = {"opr" =>"listChannel","anode" => nil, "filter" => {"showOption" => 0, "historyInfo" => 1}}
        # => 和检测线路的数据格式是不一样,但是处理逻辑是一致的,抽象之
        check_n_times_data(hash,send_hash,"检测通道速率")
      end

=begin rdoc
关键字名: 检测排除策略速率
描述: 检测通道的排除策略速率
维护人: 王沃伦
参数:
id=>name,name=>线路名称,type=>s,must=>false,default=>"总速率",value=>"{text}",descrip=>"线路的名称,可以为'总速率',或者对应的线路 '线路1','线路2'..."
id=>check_direction,name=>检测方向,type=>s,must=>false,default=>"下载",value=>"上传|下载",descrip=>"检测速率的方向,上传或下载"
id=>check_data,name=>检测范围,type=>s,must=>false,default=>"10@;@20",value=>"{text}",descrip=>"排除策略没有百分比"
id=>check_times,name=>检测次数,type=>s,must=>false,default=>"5",value=>"{text}",descrip=>"检测的次数,默认检测的次数中有60%是在设定范围内的话,认为符合预期,检测将每隔一秒检测一次"
id=>hope,name=>期望结果,type=>s,must=>false,default=>"成功",value=>"成功|失败|none",descrip=>"期望结果为'none'时,将略过期望结果检查,直接认为执行成功,请慎重使用"
=end
      def check_exclude_speed(hash={})
        send_hash = {"opr" =>"listExcludePolicy"}
        # => 排除策略没有百分比
        hash[:check_type] = "速率"
        check_n_times_data(hash,send_hash,"检测排除策略速率")
      end


      #end of class FluxView
    end
    #don't add any code after here.

  end

end
