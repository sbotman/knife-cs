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

class String
  def word_wrap n
    words = self.split ' '
    str = words.shift
    words.each do |word|
      connection = (str.size - str.rindex("\n").to_i + word.size > n) ? "\n" : " "
      str += connection + word
    end
    str
  end
end

class Chef
  class Knife
    class CsTest < Chef::Knife

      include Chef::Knife::CsBase

      banner "knife cs test (options)"

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

      def format_description(description)
        desc = []
        description.split(';').each do |line|
          line.word_wrap(80).split("\n").each do |d|
            desc << d
          end
        end 
        desc
      end

      def run
        $stdout.sync = true

        validate!
        apis = connection.list_apis['listapisresponse']
        filter = apis['api'].select { |a| a['name'] == 'deployVirtualMachine' }.first
        params = [
          "Name",
          "Description",
          "Type",
          "Length",
          "Required"
        ]
        
        filter['params'].each do |param|
          round = 1
          format_description(param['description']).each do |descript|
            if round == 1 
              params << param['name'].to_s
              params << descript.strip.capitalize
              params << param['type'].to_s
              params << param['length'].to_s
              params << param['required'].to_s
            else
              params << ""
              params << descript.strip.capitalize
              params << ""
              params << ""
              params << ""
            end
            round += 1
          end
        end
  
        puts ui.list(params, :uneven_columns_across, 5) 
      end
    end
  end
end
