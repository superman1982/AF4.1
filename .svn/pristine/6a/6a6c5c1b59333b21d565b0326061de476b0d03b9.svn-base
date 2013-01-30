# coding: utf8
=begin rdoc
模块名: 设备数据中心
描述: 封装设备数据中心上的操作
=end
module DeviceDataCenter

  module_function

  # 打开左树上,title指定名称的链接
  def menu_open( title )
    raise ATT::Exceptions::NotFoundError,"尚未登录数据中心" if $leftframe.nil?
    link_specified = $leftframe.div(:id, "Accordion1").link(:text, title)
    if link_specified.exists?
      link_specified.click
    else
      ATT::KeyLog.info("请检查文本是#{title}的链接是否存在")
      raise ATT::Exceptions::NotFoundError,"链接不存在"
    end
  end

end
