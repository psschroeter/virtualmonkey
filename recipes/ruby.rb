#
# Cookbook Name:: virtualmonkey
# Recipe:: ruby
#
# Copyright (C) 2013 RightScale, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

marker "recipe_start_rightscale" do
  template "rightscale_audit_entry.erb"
end

gem_package "bundler" do
  gem_binary "/usr/local/bin/gem_binary"
  action :purge
end

if node['virtualmonkey']['ruby']['version'] == "ruby 1.9"
  include_recipe "ruby::install_1_9"
else
  include_recipe "ruby::install_1_8"
end
