# coding: utf-8
#
# This file is generated by att util tool.
# by 2012-12-28 17:25:01
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'../../../../') unless $LOADED
require 'keywords/unittests/setup'

class TestFileGroup < Test::Unit::TestCase
  def setup
    @common = Common.new
    @file_group = DeviceConsole::ObjectDefinition::FileGroup.new

    assert_success do
      @common.set_current_device( $common["login_hash"] ) # 设置正确的当前设备的IP,用户名,密码
    end
  end
  
  def test_add_delete_file_group
    #全部删除
    assert_success do
      @file_group.delete_file_group({ :delete_type => "全部删除"})
    end
    #新增文件类型,默认值
    assert_success do
      @file_group.add_file_group({ :group_name => "test1",:type => ".mp3"})
    end
    #新增文件类型,指定多个文件类型
    assert_success do
      @file_group.add_file_group({ :group_name => "test2",:description => "test2",:type => ".mp4&.mp5"})
    end
    #新增文件类型,没有类型
    assert_fail do
      @file_group.add_file_group({ :group_name => "test3",:description => "test3",:type => ""})
    end
    #部分删除
    assert_success do
      @file_group.delete_file_group({ :delete_type => "部分删除", :group_names => "test2"})
    end
    #全部删除
    assert_success do
      @file_group.delete_file_group({ :delete_type => "全部删除"})
    end
  end
    
end