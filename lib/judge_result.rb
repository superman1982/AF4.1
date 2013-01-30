=begin
# 作用: post数据给设备后,判断返回的数据是否与期望结果一致,仅适用于期望结果只有成功和失败的关键字
# uri => post数据给此uri
# hash_json => 要post的hash类型的数据
# operation => 当前正在控制台上的操作,如编辑物理接口,新增源地址转换规则
=end
def post_and_judge_result(cgi, data_hash, operation)
  result_hash = AF::Login.get_session().post(cgi, data_hash)
  return_msg = result_hash["msg"]

  if !result_hash["errorno"].nil? && result_hash["errorno"] < 0
    return ["Failed", "CGI处理错误,错误消息为: #{return_msg}"]
  end

  if result_hash["success"] == true
    if operation.include?("登录控制台修改系统时间") || operation.include?("重启") # 若设备要重启或需重新登录,则不断尝试登录设备控制台,直到设备恢复正常
      ATT::KeyLog.info("不断尝试登录设备控制台,等待系统恢复正常...")
      sleep 120
      begin
        post_return = AF::Login.get_session().post("/cgi-bin/cfg-status.cgi", {"opr" => "status"} )
      rescue Exception
        ATT::KeyLog.info("#{$!.to_s},尝试登陆失败,重试...")
        sleep 30
        retry
      end
    end
    ATT::KeyLog.info("#{operation}成功,返回消息为:#{return_msg}")
    return_ok "成功"
  else
    ATT::KeyLog.info("#{operation}失败,返回消息为:#{return_msg}")
    return_ok "失败"
  end
end