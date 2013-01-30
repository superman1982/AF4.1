# coding: utf8
require 'mysql'

module AF

  class DataBase

    @@db_con_map = {} # 存放设备的名称与数据库连接的映射,可支持若干个设备的后台数据库访问
    @@device_config_map = {} # 存放设备的名称与设备配置的映射

    # 从test_device.yml配置文件中获取设备后台数据库的信息,连接mysql并执行sql语句
    def self.exec_sql(sqlstr, device_name = "")
      db_ip, db_user, db_passwd, db_port, db_name = get_db_config(device_name)# 根据设备名称(名称是空时取第一台设备),获取其后台数据库的配置信息
      innerresult = connect_sql(db_ip, db_user, db_passwd, db_port, db_name, sqlstr, device_name)
      return innerresult # Mysql::Result 类型
    end

    # 连接mysql并执行sql语句
    def self.connect_sql(ip, user, password, port, db_name, sqlstr, device_name)
      retry_times = 0
      result = nil
      begin
        unless @@db_con_map.has_key?(device_name)
          db_connect = Mysql.real_connect(ip, user, password, db_name, port)
          ATT::KeyLog.info("连接后台数据库....")
          @@db_con_map["#{device_name}"] = db_connect
        end
        ATT::KeyLog.info("执行sql语句:#{sqlstr}")
        @@db_con_map["#{device_name}"].query("SET NAMES utf8") # 将结果输出的编码设置为UTF-8
        result = @@db_con_map["#{device_name}"].query(sqlstr)
      rescue Mysql::Error => error
        ATT::KeyLog.error("查询出现错误:#{error}")
        if error.to_s.include?("Unknown column")
          raise "查询出错"
        elsif error.to_s.include?("an error in your SQL syntax")
          raise "SQL语法错误"
        elsif error.to_s.include?("doesn't exist")
          raise "表不存在"
        elsif error.to_s.include?("MySQL server has gone away") || error.to_s.include?("Lost connection to MySQL server during query") # 数据库连接已经断开,稍等再重新打开
          sleep 30
          begin
            db_connect = Mysql.real_connect(ip, user, password, db_name, port)
          rescue Mysql::Error => error
            ATT::KeyLog.error("再次连接出现错误:#{error},尝试打开数据库远程访问权限")
            get_db_operation_privilege(device_name, user, password) # 连接数据库失败时,尝试打开数据库远程访问的权限
          end
          @@db_con_map["#{device_name}"] = db_connect
        end
        retry_times += 1
        get_db_operation_privilege(device_name, user, password) # 连接数据库失败时,尝试打开数据库远程访问的权限
        retry if retry_times <= 1 # 仅重试一次
      ensure
      end
      raise "查询失败" if result.nil?
      return result
    end
    
    private

    # 根据设备的名称,获取其后台数据库的配置信息
    def self.get_db_config(device_name)
      if @@device_config_map.has_key?(device_name)
        return @@device_config_map[device_name]
      end
      ATT::KeyLog.info("获取设备:#{device_name}的后台数据库配置...")
      test_devices = ATT::ConfigureManager.get("test_device.yml")["testdevice"]
      if device_name.to_s.empty?
        db_ip = test_devices[0]["host"]
        db_user = test_devices[0]["db_user"]
        db_passwd = test_devices[0]["db_passwd"]
        db_port = test_devices[0]["db_port"]
        db_db = test_devices[0]["db_name"]
        ATT::KeyLog.info("设备:#{device_name}的后台数据库配置:#{db_ip}/#{db_user}/#{db_passwd}/#{db_port}/#{db_db}")
        @@device_config_map["#{device_name}"] = [db_ip, db_user, db_passwd, db_port, db_db]
        return @@device_config_map["#{device_name}"]
      end
      test_devices.each do |device|
        if device["name"] == device_name
          db_ip = device["host"]
          db_user = device["db_user"]
          db_passwd = device["db_passwd"]
          db_port = device["db_port"]
          db_db = device["db_name"]
          ATT::KeyLog.info("设备:#{device_name}的后台数据库配置:#{db_ip}/#{db_user}/#{db_passwd}/#{db_port}/#{db_db}")
          @@device_config_map["#{device_name}"] = [db_ip, db_user, db_passwd, db_port, db_db]
          return @@device_config_map["#{device_name}"]
        end
      end
      ATT::KeyLog.info("test_device.yml文件中不存在名称是:#{device_name}的设备!")
      raise ATT::Exceptions::ArgumentError,"设备不存在"
    end

    # 连接数据库失败时,尝试打开数据库远程访问的权限
    def self.get_db_operation_privilege(device_name, user, password)
      name = (device_name.to_s.empty? ? nil : device_name)
      ssh_connect = ATT::TestDevice.new(name)
      ssh_connect.exec_command(%Q{/virus/mysql/bin/mysql -p#{password} -e "grant all privileges on *.* to '#{user}'@'%' identified by '#{password}' with grant option";
 /virus/mysql/bin/mysql -p#{password} -e "flush privileges";})
      ATT::KeyLog.debug("open privilege successfully")
    end
  
  end
  
end