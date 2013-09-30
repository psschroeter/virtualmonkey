#
# Cookbook Name:: virtualmonkey
# Recipe:: setup_rocketmonkey
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

# Install the jenkins server
# See cookbooks/jenkins/recipes/install_server for the "jenkins::install_server"
# recipe.
include_recipe "rs-jenkins::install_server"

log "  Checking out Rocketmonkey repository from:" +
  " #{node[:virtualmonkey][:rocketmonkey][:repo_url]}"
git node[:virtualmonkey][:rocketmonkey_path] do
  repository node[:virtualmonkey][:rocketmonkey][:repo_url]
  reference node[:virtualmonkey][:rocketmonkey][:repo_branch]
  action :sync
end

execute "git checkout" do
  cwd node[:virtualmonkey][:rocketmonkey_path]
  command "git checkout #{node[:virtualmonkey][:rocketmonkey][:repo_branch]}"
end

# The rocketmonkey main configuration file is created from a template initially
# allowing custom edits on the configuration. This template file is not
# completely controlled by Chef yet.
#
template "#{node[:virtualmonkey][:rocketmonkey_path]}/.rocketmonkey.yaml" do
  source "rocketmonkey_config.yaml.erb"
  owner node[:virtualmonkey][:user]
  group node[:virtualmonkey][:group]
  mode 0644
  variables(
    :jenkins_user => node[:'rs-jenkins'][:server][:user_name],
    :jenkins_password => node[:'rs-jenkins'][:server][:password],
    :right_acct_id => node[:virtualmonkey][:rest][:right_acct_id],
    :right_subdomain => node[:virtualmonkey][:rest][:right_subdomain]
  )
  action :create_if_missing
end

# Copy the rocketmonkey configuration files if they are not present. Presently,
# these configuration files are not managed by Chef.
log "  Creating rocketmonkey configuration files from tempaltes"
[
  "googleget.yaml",
  "rocketmonkey.clouds.yaml",
  "rocketmonkey.regexs.yaml"
].each do |config_file|
  execute "copy '#{config_file}' to '.#{config_file}'" do
    cwd node[:virtualmonkey][:rocketmonkey_path]
    command "cp #{config_file} .#{config_file}"
    not_if do
      ::File.exists?("#{node[:virtualmonkey][:rocketmonkey_path]}/.#{config_file}")
    end
  end
end

log "  Installing required gems for rocketmonkey"
execute "Install rocketmonkey gem dependencies" do
  cwd node[:virtualmonkey][:rocketmonkey_path]
  command "bundle install --system"
end