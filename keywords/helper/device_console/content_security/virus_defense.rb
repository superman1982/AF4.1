# coding: utf8
module DeviceConsole
  module ContentSecurity
    module VirusDefenseHelper
      def get_edit_virus_defense_strategy_post_hash( hash )
        src_hash = {"src_zone" => "", "ip_user_group" => "", "ip_group" => {"src_ip" => "", "enable" => false },\
            "user_group" => { "src_user" => { "org" => "", "itemName" => "" }, "enable" => false }}
        src_hash["src_zone"] = hash[:source_zone].split("&").join(",")
        if hash[:source_group_type] == "IP组"
          src_hash["ip_user_group"] = "ip_group"
          src_hash["ip_group"]["src_ip"] = hash[:source_ip].split("&").join(",")
          src_hash["ip_group"]["enable"] = true
        elsif hash[:source_group_type] == "用户组"
          src_hash["ip_user_group"] = "user_group"
          src_hash["user_group"]["enable"] = true
          src_hash["user_group"]["src_user"]["org"] = hash[:source_user].split("&").join(",")
        end
        det_hash = {"dst_zone" => "", "dst_ip" => ""}
        det_hash["dst_zone"] = hash[:dest_zone].split("&").join(",")
        det_hash["dst_ip"] = hash[:dest_ip].split("&").join(",")
        av_cfg_hash = {"http_av" => [],"http_download" => false, "ftp_av" => [],"ftp_download" => false, \
            "mail_av" => [],"recv" => false,"send" => false,"filetype" => {"type" => ""}, \
            "exclude" => {"site" => "", "enable" => false}
        }
        if hash[:virus_http] == "是"
          av_cfg_hash["http_av"] << "http_download"
          av_cfg_hash["http_download"] = true
        end
        if hash[:virus_ftp] == "是"
          av_cfg_hash["ftp_av"] << "ftp_download"
          av_cfg_hash["ftp_download"] = true
        end
        if hash[:virus_pop3] == "是"
          av_cfg_hash["mail_av"] << "recv"
          av_cfg_hash["recv"] = true
        end
        if hash[:virus_smtp] == "是"
          av_cfg_hash["mail_av"] << "send"
          av_cfg_hash["send"] = true
        end
        av_cfg_hash["filetype"]["type"] = hash[:virus_filetype].split("&").join("\n")
        av_cfg_hash["exclude"]["site"] = hash[:url_list].split("&").join("\n")
        av_cfg_hash["exclude"]["enable"] = hash[:enable_url].to_logic
        action_hash = {"log" => hash[:record_log].to_logic, "block" => hash[:operation].to_logic}
        status_hash ={"src" => src_hash,"det" => det_hash,"gateway_av_cfg" => av_cfg_hash, \
            "check_after_attack" => action_hash,"enable" => hash[:enable].to_logic}
        post_hash = {"opr" => "modify","data" => {"status" => status_hash}}
        return post_hash
      end
      
    end
  end
end
