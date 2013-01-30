# coding: utf8
# 
# This file is generated by att util tool.
# by 2011-12-08 15:58:38
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'../../../../') unless $LOADED
require 'keywords/unittests/setup'

#$stdouttype = "GBK"

class TestWebFiltration < Test::Unit::TestCase
  def setup
    @common = Common.new
    @interface_zone = DeviceConsole::NetConfig::InterfaceZone.new
    @ip_group = DeviceConsole::ObjectDefinition::IpGroup.new
    @web_filtration = DeviceConsole::ContentSecurity::WebFiltration.new

    assert_success do
      @common.set_current_device( $common["login_hash"] ) # 设置正确的当前设备的IP,用户名,密码
    end
    
  end

  def test_add_url_filtration_rule
    # 新增区域
    assert_success do
      @interface_zone.add_zone(:name => "zone41", :forward_type => "三层区域", :interfaces => "",
        :enable_webui => "是", :enable_ssh => "是", :enable_snmp => "是", :manage_address => "全部")
    end
    # 新增区域
    assert_success do
      @interface_zone.add_zone(:name => "zone42", :forward_type => "三层区域", :interfaces => "",
        :enable_webui => "否", :enable_ssh => "否", :enable_snmp => "否", :manage_address => "全部")
    end
    # 新增IP组,正常
    assert_success do
      @ip_group.add_ip_group({:group_name => "ipgrp41", :description => "描述", :ip_addresses => "2.2.2.2&1.1.1.1-1.1.1.100"})
    end
    # 新增IP组,正常
    assert_success do
      @ip_group.add_ip_group({:group_name => "ipgrp42", :description => "描述", :ip_addresses => "4.3.2.2"})
    end
    # 新增URL过滤
    assert_success do
      @web_filtration.add_url_filtration_rule({:name => "url_filter1", :enable => "是", :description => "描述",\
            :source_zone => "zone41&zone42", :source_group_type => "IP组", :source_ip => "ipgrp41&ipgrp42",\
            :source_user => "", :url_type => "网上银行&电信业&幽默笑话&未分类", :http_get => "是",:http_post => "否",\
            :https => "是", :take_effect_time => "全天", :operation => "拒绝", :record_log => "是"})
    end
    # 新增URL过滤
    assert_success do
      @web_filtration.add_url_filtration_rule({:name => "url_filter2", :enable => "是", :description => "描述",\
            :source_zone => "zone42", :source_group_type => "用户组", :source_ip => "",\
            :source_user => "/默认组/", :url_type => "成人内容&运输业", :http_get => "否",:http_post => "是",\
            :https => "否", :take_effect_time => "全天", :operation => "允许", :record_log => "否"})
    end
    #禁用URL过滤规则
    assert_success do
      @web_filtration.enable_disable_urlfilter({:enable_count => "全部操作", :names => "",\
            :enable_type => "禁用"})
    end
    #启用URL过滤规则
    assert_success do
      @web_filtration.enable_disable_urlfilter({:enable_count => "部分操作", :names => "url_filter2",\
            :enable_type => "启用"})
    end
    #编辑URL过滤规则
      assert_success do
      @web_filtration.edit_url_filtration_rule({:oldname => "url_filter2", :name => "url_filter2", :enable => "是", :description => "描述",\
            :source_zone => "zone42", :source_group_type => "IP组", :source_ip => "ipgrp41",\
            :source_user => "", :url_type => "网上银行", :http_get => "是",:http_post => "否",\
            :https => "是", :take_effect_time => "全天", :operation => "允许", :record_log => "是"})
    end
    # 删除URL过滤
    assert_success do
      @web_filtration.delete_url_filteration_rule({:delete_type => "部分删除", :names => "url_filter1&url_filter2"})
    end
    # 新增URL过滤
    assert_success do
      @web_filtration.add_url_filtration_rule({:name => "url_filter3", :enable => "是", :description => "描述",\
            :source_zone => "zone42", :source_group_type => "IP组", :source_ip => "ipgrp41",\
            :source_user => "", :url_type => "成人内容&运输业", :http_get => "是",:http_post => "是",\
            :https => "是", :take_effect_time => "全天", :operation => "允许", :record_log => "是"})
    end
    # 删除URL过滤
    assert_success do
      @web_filtration.delete_url_filteration_rule({:delete_type => "全部删除", :names => ""})
    end
    # 删除所有的IP组
    assert_success do
      @ip_group.delete_ip_group({ :delete_type => "全部删除", :group_names => ""})
    end
    # 删除所有的区域
    assert_success do
      @interface_zone.delete_zone( {:delete_type => "全部删除", :names => ""})
    end
  end

  def test_add_file_filtration_rule
    # 新增区域
    assert_success do
      @interface_zone.add_zone(:name => "zone41", :forward_type => "三层区域", :interfaces => "",
        :enable_webui => "是", :enable_ssh => "是", :enable_snmp => "是", :manage_address => "全部")
    end
    # 新增区域
    assert_success do
      @interface_zone.add_zone(:name => "zone42", :forward_type => "三层区域", :interfaces => "",
        :enable_webui => "否", :enable_ssh => "否", :enable_snmp => "否", :manage_address => "全部")
    end
    # 新增IP组,正常
    assert_success do
      @ip_group.add_ip_group({:group_name => "ipgrp41", :description => "描述", :ip_addresses => "2.2.2.2&1.1.1.1-1.1.1.100"})
    end
    # 新增IP组,正常
    assert_success do
      @ip_group.add_ip_group({:group_name => "ipgrp42", :description => "描述", :ip_addresses => "4.3.2.2"})
    end

    #新增文件过滤
     assert_success do
      @web_filtration.add_file_filtration_rule({:name => "file_filter1", :enable => "是", :description => "描述",\
            :source_zone => "zone41&zone42", :source_group_type => "IP组", :source_ip => "ipgrp41&ipgrp42",\
            :source_user => "", :file_type => "电影", :up => "是",:down => "否",\
            :take_effect_time => "全天", :operation => "拒绝", :record_log => "是"})
    end
      assert_success do
      @web_filtration.add_file_filtration_rule({:name => "file_filter2", :enable => "是", \
            :source_zone => "zone41&zone42", :source_group_type => "IP组", :source_ip => "全部",\
            :source_user => "", :file_type => "电影&音乐", :up => "是",:down => "是",\
            :take_effect_time => "全天", :operation => "拒绝", :record_log => "是"})
    end

       assert_success do
      @web_filtration.edit_file_filtration_rule({:name => "file_filter2", :enable => "是", \
            :source_zone => "zone41&zone42", :source_group_type => "IP组", :source_ip => "全部",\
            :source_user => "", :file_type => "音乐", :up => "否",:down => "否",\
            :take_effect_time => "全天", :operation => "拒绝", :record_log => "是"})
    end

    #禁用文件过滤规则
    assert_success do
      @web_filtration.enable_disable_filefilter({:enable_count => "全部操作", :names => "",\
            :enable_type => "禁用"})
    end


    #启用文件过滤规则
    assert_success do
      @web_filtration.enable_disable_filefilter({:enable_count => "部分操作", :names => "file_filter2",\
            :enable_type => "启用"})
    end


     # 删除文件过滤
    assert_success do
      @web_filtration.delete_file_filteration_rule({:delete_type => "部分删除", :names => "file_filter1"})
    end


    # 新增文件过滤
    assert_success do
      @web_filtration.add_file_filtration_rule({:name => "file_filter3", :enable => "是", \
            :source_zone => "zone41&zone42", :source_group_type => "IP组", :source_ip => "全部",\
            :source_user => "", :file_type => "电影&音乐", :up => "是",:down => "是",\
            :take_effect_time => "全天", :operation => "拒绝", :record_log => "是"})
    end

    # 删除文件过滤
    assert_success do
      @web_filtration.delete_file_filteration_rule({:delete_type => "全部删除", :names => ""})
    end
    # 删除所有的IP组
    assert_success do
      @ip_group.delete_ip_group({ :delete_type => "全部删除", :group_names => ""})
    end
    # 删除所有的区域
    assert_success do
      @interface_zone.delete_zone( {:delete_type => "全部删除", :names => ""})
    end

  end

end