# coding: utf8
module DeviceDataCenter
  module LogQueryHelper

    # 根据参数获取正确格式的日期和时间
    def get_date_and_time( startdate, starttime, enddate, endtime)
      if startdate.to_s.empty?
        start_date = $main_sub_frame.text_field(:id, "startDate").value # 已经填充上的默认值
      else
        start_date = startdate.to_s # startdate 的格式如'2011-12-07'
      end
      if starttime.to_s.empty?
        start_time = "00:00"
      else
        start_time = starttime.gsub(/\\/,"").split(":")[0..1].join(":") # starttime 的格式如'12:30'
      end
      if enddate.to_s.empty?
        end_date = $main_sub_frame.text_field(:id, "endDate").value # 已经填充上的默认值
      else
        end_date = enddate.to_s # enddate 的格式如'2011-12-07'
      end
      if endtime.to_s.empty?
        end_time = "00:00"
      else
        end_time = endtime.gsub(/\\/,"").split(":")[0..1].join(":") # endtime 的格式如'12:30'
      end
      return [start_date, start_time, end_date, end_time]
    end
    # 输入开始日期和时间
    def input_start_date_time(start_date, start_time)
      #$main_sub_frame.run_js("document.getElementById('startDate').removeAttribute('readonly')") # 删除其只读属性
      $main_sub_frame.text_field(:id, "startDate").value = start_date # 不使用set方法,可越过只读限制
      $main_sub_frame.text_field(:id, "startTime").set(start_time)
    end
    # 输入结束日期和时间
    def input_end_date_time(end_date, end_time)
      #$main_sub_frame.run_js("document.getElementById('endDate').removeAttribute('readonly')") # 删除其只读属性
      $main_sub_frame.text_field(:id, "endDate").value = end_date
      $main_sub_frame.text_field(:id, "endTime").set(end_time)
    end
    # 选择源区域
    def select_source_zone( source_zone )
      unless source_zone == "所有区域"
        $main_sub_frame.select_list(:id, "sourceArea").select(source_zone)
      end
    end
    # 输入源IP/用户
    def input_source_ip_or_user(source_type, source_ip, source_user, source_usergrp, sub_grp)
      if source_type == "所有"
      elsif source_type == "IP"
        $main_sub_frame.radio(:id, "radIP").set
        $main_sub_frame.text_field(:id, "sourceIp").set(source_ip)
      elsif source_type == "用户"
        $main_sub_frame.radio(:id, "radUsers").set
        $main_sub_frame.text_field(:id, "sourceUser").set(source_user)
      elsif source_type == "组"
        $main_sub_frame.radio(:id, "radGroup").set
        #$main_sub_frame.run_js("document.getElementById('sourceGroup').removeAttribute('readonly')") # 删除其只读属性
        $main_sub_frame.text_field(:id, "sourceGroup").value = source_usergrp
        if sub_grp == "是"
          $main_sub_frame.checkbox(:id, "subGroup").set
        else
          $main_sub_frame.checkbox(:id, "subGroup").clear
        end
      end
    end
    # 选择目的区域
    def select_dest_zone( dest_zone )
      unless dest_zone == "所有区域"
        $main_sub_frame.select_list(:id, "destArea").select(dest_zone)
      end
    end
    # 输入目的IP
    def input_dest_ip( dest_ip )
      $main_sub_frame.text_field(:id, "destIp").set(dest_ip)
    end
    # 选择服务或应用
    def select_service_or_app(service_app, services, protocol, port, apps)
      if service_app == "全部"
      elsif service_app == "服务"
        $main_sub_frame.select_list(:id, "srvAppType").select(service_app)
        $main_sub_frame.run_js("change_source();")
        $main_sub_frame.select_list(:id, "preDefineService").select(services)
        if services == "自定义"
          $main_sub_frame.select_list(:id, "protocol").select(protocol)
          $main_sub_frame.text_field(:id, "port").set(port)
        end
      elsif service_app == "应用"
        $main_sub_frame.run_js("change_source();")
        $main_sub_frame.select_list(:id, "srvAppType").select(service_app)
        #$main_sub_frame.run_js("document.getElementById('appTypeValue').removeAttribute('readonly')") # 删除其只读属性
        $main_sub_frame.text_field(:id, "appTypeValue").value = apps
      end
    end
    # 勾选允许和拒绝
    def select_accept_and_reject( accept, refuse)
      if accept == "是"
        $main_sub_frame.checkbox(:id, "action_0").set
      else
        $main_sub_frame.checkbox(:id, "action_0").clear
      end
      if refuse == "是"
        $main_sub_frame.checkbox(:id, "action_1").set
      else
        $main_sub_frame.checkbox(:id, "action_1").clear
      end
    end
    # 点击查询按钮
    def click_query_button()
      $main_sub_frame.checkbox(:id, "newtab").clear
      $main_sub_frame.button(:id, "sure").click
    end
    # 检查查询结果,records_hoped'的格式如: 服务/应用#协议#源区域#所属组#源IP/用户#目的区域#目的IP#匹配策略名#动作'
    # "HTTP应用/HTTP_POST  TCP  lan  /AF/  user1  wan  218.17.246.172  appctr  拒绝  "
    def check_query_result(records_hoped)
      column_index_array = [3,4,5,6,7,9,12,14] # 查询结果中,列的索引
      result_lines = $main_sub_frame.div(:id, "result").tables.size
      if result_lines <= 1 # 查询结果是空
        ATT::KeyLog.error("查询结果是空")
        ATT::KeyLog.error("期望结果是:\n#{records_hoped}")
        return_fail
      end
      unless records_hoped.empty?
        rows_text_array = [] # 存放所有的查询结果行
        for line_index in 2..result_lines
          result_table = $main_sub_frame.div(:id, "result").tables[line_index]
          for line in 1..result_table.row_count
            one_row = result_table[line]
            column_text_array = []
            for column in 3..one_row.column_count
              if column_index_array.include?(column)
                column_text_array << one_row[column]
              end
            end
            rows_text_array << column_text_array.join("#")
          end
        end
        record_hoped_array = records_hoped.split("&")
        rows_text_array_no_same = rows_text_array.uniq
        record_hoped_array_no_same = record_hoped_array.uniq
        if(rows_text_array_no_same.uniq - record_hoped_array_no_same).size == rows_text_array_no_same.size - record_hoped_array_no_same.size
          ATT::KeyLog.error("查询结果中包含期望的记录")
          return_ok
        else
          ATT::KeyLog.error("实际结果是:\n#{rows_text_array.join("\n")}")
          ATT::KeyLog.error("期望结果是:\n#{record_hoped_array.join("\n")}")
          return_fail
        end
      end
    end

  end
end
