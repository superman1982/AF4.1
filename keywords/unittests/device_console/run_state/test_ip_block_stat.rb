# coding: utf8
#
# This file is generated by att util tool.
# by 2012-08-25 10:28:41
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'../../../../') unless $LOADED
require 'keywords/unittests/setup'

class TestIpBlockStat < Test::Unit::TestCase
  def setup
    @common = Common.new
    @test_obj = keyword_proxy_for_class_name( DeviceConsole::RunState::IpBlockStat ).new

    assert_success do
      @common.set_current_device( $common["login_hash"] ) # 设置正确的当前设备的IP,用户名,密码
    end
    make_hash_relieve()
    make_hash_clear()
    make_hash_set_time()
    make_hash_check_ip_block()
  end
  
  def make_hash_relieve
    @hash_relieve_1 = { :block_ip_str => "5.5.88.3", :hope => "成功" }
    @hash_relieve_2 = { :block_ip_str => "5.5.88.4&5.5.88.5", :hope => "成功" }
    @hash_relieve_3 = { :block_ip_str => "5.5.88.31231", :hope => "失败" }
    @hash_relieve_4 = { :block_ip_str => "", :hope => "成功" }
  end
  def make_hash_clear
    @hash_clear_1 = {  :hope => "成功" }
    # => 靠,清空两次都可以成功的...只是做js端的限制不许清空两次
    @hash_clear_2 = {  :hope => "成功" }
  end
  def make_hash_set_time
    @hash_time_1 = { :lock_time => 3, :hope => "成功" }
    @hash_time_2 = { :lock_time => 30, :hope => "成功" }
    @hash_time_3 = { :lock_time => 0, :hope => "失败" }
    @hash_time_4 = { :lock_time => 31, :hope => "失败" }
    @hash_time_5 = { :lock_time => "31as", :hope => "失败" }
    
  end
  def make_hash_check_ip_block
    @hash_check_1 = { :ip_addrs => "192.168.0.0&2.2.2.2", :hope => "成功" }
    @hash_check_2 = { :ip_addrs => "192.168.0.0&2.2.2.2&", :hope => "成功" }
    @hash_check_3 = { :ip_addrs => "111.121.5.1", :hope => "成功" }
    @hash_check_4 = { :ip_addrs => "5.2.333.2", :hope => "成功" }
    @hash_check_5 = { :ip_addrs => "192.168.0.0&2.2.2.2&5.6.7.8&11.12.13.14&15.16.17.18", :hope => "成功" }
  end
  def test_relieve_ip_block
    puts("这里是 test_relieve_ip_block ... ===================@@Woolen Test@@====================")
    assert_success do
      @test_obj.relieve_ip_block(@hash_relieve_1)
    end
    assert_success do
      @test_obj.relieve_ip_block(@hash_relieve_2)
    end
    assert_success do
      @test_obj.relieve_ip_block(@hash_relieve_3)
    end
    assert_success do
      @test_obj.relieve_ip_block(@hash_relieve_4)
    end
  end
  
  def test_clear_ip_block
    puts("这里是 test_clear_ip_block ... ===================@@Woolen Test@@====================")
    assert_success do
      @test_obj.clear_ip_block(@hash_clear_1)
    end
    assert_success do
      @test_obj.clear_ip_block(@hash_clear_2)
    end
  end
  
  def test_set_ip_block_time
    puts("这里是 test_set_ip_block_time ... ===================@@Woolen Test@@====================")
    assert_success do
      @test_obj.set_ip_block_time(@hash_time_1)
    end
    assert_success do
      @test_obj.set_ip_block_time(@hash_time_2)
    end
    assert_fail do
      @test_obj.set_ip_block_time(@hash_time_3)
    end
    assert_fail do
      @test_obj.set_ip_block_time(@hash_time_4)
    end
  end
  
  def test_check_ip_block
    puts("这里是 test_set_ip_block_time ... ===================@@Woolen Test@@====================")
    assert_fail do
      @test_obj.check_ip_block(@hash_check_1)
    end
    assert_fail do
      @test_obj.check_ip_block(@hash_check_2)
    end
    assert_success do
      @test_obj.check_ip_block(@hash_check_3)
    end
    assert_fail do
      @test_obj.check_ip_block(@hash_check_4)
    end
    assert_fail do
      @test_obj.check_ip_block(@hash_check_5)
    end
  end
end