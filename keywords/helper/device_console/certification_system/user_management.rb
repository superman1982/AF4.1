module DeviceConsole
  module CertificationSystem
    module UserManagementHelper
      #新增用户组时，获取post的hash数据
      def get_add_user_group( hash )
        #开始
        data_hash={"id"=>""}
        data_hash["desc"]= hash[:description]
        data_hash["path"]= hash[:path]
        data_hash["name"] =hash[:group_names].split("&").join(",")
        fathercrc =""
        result_hash = AF::Login.get_session().post(ListOrgTreeCGI, {"opr"=>"listorgtree"})
        post_data1=result_hash["data"]#存放data信息
        user_array=result_hash["data"]["children"]

        if hash[:path]=="/" then
          fathercrc =post_data1["id"]
        else
          path_array =hash[:path].split("/")
          i = 1 #循环变量
          while i < path_array.size
            fathercrc=-1
            user_array.each do |one_user|
              if path_array[i]==one_user["text"]
                fathercrc=one_user["id"]
                user_array=one_user["children"]
                break
              end
            end
            if  fathercrc== -1
              ATT::KeyLog.debug("路径:#{path_array[i]}不存在")
              return_fail("路径错误")
            end
            i+=1
          end
        end

        post_hash = {"opr" => "addgrp", "fathercrc"=>fathercrc, "data"=>data_hash }
        return post_hash
      end

      # 删除用户组时,获取post的hash数据
      def get_delete_user_group( hash )
        #开始
        post_hash = {"opr" => "delete", "name"=>"","select"=>"null","user"=>[]}
        org_array =[]#存放要删除的用户组信息，元素为org_hash
        org_hash={"name"=>"","id"=>""}#存放每个用户组的信息
        name_array =hash[:group_names].split("&")
        result_hash = AF::Login.get_session().post(ListOrgTreeCGI, {"opr"=>"listorgtree"})
        post_data1=result_hash["data"]#存放data信息
        user_array=result_hash["data"]["children"]
        id=""#存放目录id
        if hash[:path]=="/" then
          id=post_data1["id"]
        else
          path_array =hash[:path].split("/")
          i = 1 #循环变量
          while i < path_array.size
            id=-1
            user_array.each do |one_user|
              if path_array[i]==one_user["text"]
                id=one_user["id"]
                user_array=one_user["children"]
                break
              end
            end
            if id == -1
              ATT::KeyLog.debug("路径:#{path_array[i]}不存在")
              return_fail("路径错误")
            end
            i+=1
          end
        end

        #获取org_array信息
        name_array.each do |name|
          name_id=-1#name对应的id
          user_array.each do |one|
            if name==one["text"]
              name_id=one["id"]
              org_hash = {"name"=>name,"id"=>name_id}
              break
            end
          end
          if name_id == -1
            ATT::KeyLog.debug("用户组:#{name}不存在")
            return_fail("用户组不存在")
          end
          org_array << org_hash
        end
        filter_id=id#存放filter信息
        post_hash = {"opr" => "delete", "name"=>"","id"=>id,"select"=>"null",
          "org"=>org_array,"user"=>[],"filter"=>{"id"=>filter_id}}
        return post_hash
      end

      #新增单用户post_hash数据
      def get_add_single_user_post_hash( hash )
        #给user哈希赋值
        if hash[:path]=="/"
          fatherpath=hash[:path]
        else
          fatherpath=hash[:path]+"/"
        end
        user_hash={"name"=>hash[:login_name],"desc"=>hash[:description],
          "showname"=>hash[:show_name],"fatherpath"=>fatherpath}
        #给selfpass哈希赋值
        selfpass={}
        if hash[:local_passwd]=="是"
          selfpass["enable"]=true
          selfpass["password"]=hash[:passwd]
          selfpass["repassword"]=hash[:confirm_passwd]
        else
          selfpass["enable"]=false
          selfpass["password"]=""
          selfpass["repassword"]=""
        end
        #ipmac_bind哈希赋值
        ipmac_bind={}
        bind={}
        restrict={}
        if hash[:bind_ip_mac]=="是"
          if hash[:bind_method]=="用户和地址双向绑定"
            ipmac_bind["select"]="bind"
            ipmac_bind["bind"]=true
            ipmac_bind["restrict"]=false
            bind["enable"]=true
            bind["item"]=hash[:ip_macs]
            restrict["enable"]=false
            if hash[:bind_type]=="绑定IP"
              bind["ip"]=true
              bind["mac"]=false
              bind["ipmac"]=false
              bind["bind"]="ip"
            elsif hash[:bind_type]=="绑定MAC"
              bind["ip"]=false
              bind["mac"]=true
              bind["ipmac"]=false
              bind["bind"]="mac"
            else
              bind["ip"]=false
              bind["mac"]=false
              bind["ipmac"]=true
              bind["bind"]="ipmac"
            end
          else
            ipmac_bind["select"]="restrict"
            ipmac_bind["bind"]=false
            ipmac_bind["restrict"]=true
            bind["enable"]=false
            restrict["enable"]=true
            restrict["item"]=hash[:ip_macs]
            if hash[:bind_type]=="绑定IP"
              restrict["ip"]=true
              restrict["mac"]=false
              restrict["ipmac"]=false
              restrict["restrict"]="ip"
            elsif hash[:bind_type]=="绑定MAC"
              restrict["ip"]=false
              restrict["mac"]=true
              restrict["ipmac"]=false
              restrict["restrict"]="mac"
            else
              restrict["ip"]=false
              restrict["mac"]=false
              restrict["ipmac"]=true
              restrict["restrict"]="ipmac"
            end
          end
        else
          ipmac_bind["select"]="bind"
          ipmac_bind["bind"]=true
          ipmac_bind["restrict"]=false
          bind["enable"]=false
          restrict["enable"]=false
        end
        #时间相关哈希赋值
        if hash[:expire_type]=="永不过期"
          time="overtime"
          overtime=true
          expire_time={}
          expire_time["date"]=""
          expire_time["enable"]=false
        else
          time="expire_time"
          overtime=false
          expire_time={}
          expire_time["date"]=hash[:expire_time]
          expire_time["enable"]=true
        end

        hash_status={"user"=>user_hash,"selfpass"=>selfpass,"ipmac_bind"=>ipmac_bind,
          "bind"=>bind,"restrict"=>restrict,"create"=>"","common_user"=>hash[:public_account].to_logic,
          "logout"=>hash[:logout_popup].to_logic,
          "time"=>time,"overtime"=>overtime,"expire_time"=>expire_time,"enable"=>true
        }
        post_hash={"opr"=>"add","data"=>{"status"=>hash_status}}
        return post_hash
      end

      # 删除用户时,获取post的hash数据
      def get_delete_users_post_hash( hash )
        #开始
        post_hash = {"opr" => "delete", "name"=>"","select"=>"null","user"=>[]}
        user_array =[]#存放要删除的用户信息，元素为org_hash
        user_hash={"name"=>"","id"=>""}#存放每个用户的信息
        name_array =hash[:user_names].split("&")
        result_hash = AF::Login.get_session().post(ListOrgTreeCGI, {"opr"=>"listorgtree"})
        post_data1=result_hash["data"]#存放data信息
        user_array1=result_hash["data"]["children"]
        org_id=""#存放目录id
        if hash[:path]=="/" then
          org_id=post_data1["id"]
        else
          path_array =hash[:path].split("/")
          i = 1 #循环变量
          while i < path_array.size
            org_id=-1
            user_array1.each do |one_user|
              if path_array[i]==one_user["text"]
                org_id=one_user["id"]
                user_array1=one_user["children"]
                break
              end
            end
            if org_id == -1
              ATT::KeyLog.debug("路径:#{path_array[i]}不存在")
              return_fail("路径错误")
            end
            i+=1
          end
        end
        #获取该目录下的用户列表，
        result_hash2 = AF::Login.get_session().post(UserManageCGI, {"start"=>0,"limit"=>20,
            "filter"=>{"id"=>org_id},"opr"=>"listItem","type"=>0})
        u_array=result_hash2["data"]#存放该目录下的所有用户信息
        #获取user_array信息
        name_array.each do |name|
          name_id=-1#name对应的id
          u_array.each do |one|
            if name==one["name"]
              name_id=one["id"]
              user_hash = {"name"=>name,"id"=>name_id}
              break
            end
          end
          if name_id == -1
            ATT::KeyLog.debug("用户:#{name}不存在")
            return_fail("该用户不存在")
          end
          user_array << user_hash
        end
        filter_id=org_id#存放filter信息
        post_hash = {"opr" => "delete", "name"=>"","id"=>org_id,"select"=>"null",
          "user"=>user_array,"org"=>[],"filter"=>{"id"=>filter_id}}
        return post_hash
      end
    end
  end
end

