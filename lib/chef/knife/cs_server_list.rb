#
# Author:: Sander Botman (<sbotman@schubergphilis.com>)
# Copyright:: Copyright (c) 2014
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/cs_base'

class Chef
  class Knife
    class CsServerList < Chef::Knife

      include Chef::Knife::CsBase

      banner "knife cs server list (options)"

      option :id,
             :short => "-i",
             :long => "--id",
             :boolean => true,
             :default => false,
             :description => "Display the ID's instead of the names in output"

      option :tags,
             :short => "-t TAG1,TAG2",
             :long => "--tags TAG1,TAG2",
             :description => "List of tags to output"

      def run
        $stdout.sync = true

        validate!

        server_list = [
          (config[:id] ? ui.color('ID', :bold) : ui.color('Name', :bold)),
          ui.color('Public IP', :bold),
          ui.color('Private IP', :bold),
          ui.color('Service', :bold),
          ui.color('Image', :bold),
          ui.color('Zone', :bold),
          ui.color('State', :bold)
        ].flatten.compact

        output_column_count = server_list.length

        rules = connection.list_port_forwarding_rules

        connection.servers.all.each do |server|

          config[:id] ? server_list << server.id.to_s : server_list << server.name.to_s

          server_list << get_public_ip_address(server, rules).to_s
          server_list << get_private_ip_address(server).to_s

          if config[:id]
            server_list << server.flavor_id.to_s
            server_list << server.image_id.to_s
            server_list << server.zone_id.to_s
          else
            flavor = server.flavor_name.to_s
            server_list << ui.color(flavor, fcolor(flavor))
            server_list << server.image_name.to_s
            server_list << server.zone_name.to_s
          end

          state = server.state.to_s.downcase
          server_list << ui.color(state, scolor(state))
        end

        puts ui.list(server_list, :uneven_columns_across, output_column_count)

      end    

      private
 
      def fcolor(flavor)
        case flavor
          when /.*micro.*/i
            :blue
          when /.*small.*/i
            :magenta
          when /.*medium.*/i
            :cyan
          when /.*large.*/i
            :green
          when /.*xlarge.*/i
            :red
        end
      end

      def scolor(state)
        case state
          when /destroyed/i, /expunging/i
            :purple
          when /shutting-down/i, /terminated/i, /stopping/i, /stopped/i
            :red
          when /pending/i
            :yellow
          else
           :green
        end
      end

      def groups_with_ids(groups)
        groups.map{|g|
          "#{g} (#{@group_id_hash[g]})"
        }
      end

      def vpc_with_name(vpc_id)
        this_vpc = @vpcs.select{|v| v.id == vpc_id }.first
        if this_vpc.tags["Name"]
          vpc_name = this_vpc.tags["Name"]
          "#{vpc_name} (#{vpc_id})"
        else
          vpc_id
        end
      end

      def get_private_ip_address(server)
        return nil if server.nics.empty?
        default_nic = server.nics.select {|n| n['isdefault'] == true }.first
        return nil if default_nic.nil? || default_nic.empty?
        default_nic['ipaddress']
      end
 
      def check_ssh_or_winrm_port(server)
        return false unless server['protocol'] == 'tcp'
        [ '22', '5985', '5986' ].each do |port|
          return true if server['privateport'] <= port && server['privateendport'] >= port 
        end
        false
      end

      def get_public_ip_address(server, rules=nil)
        return nil if rules.nil?
        return nil unless rules.key?('listportforwardingrulesresponse') || rules['listportforwardingrulesresponse'].key?('portforwardingrule')
        f = rules['listportforwardingrulesresponse']['portforwardingrule'].select { |n| n['virtualmachineid'] == server.id && check_ssh_or_winrm_port(n) }.first
        return nil if f.nil? || f.empty?
        f['ipaddress'].to_s
      end
    end
  end
end
