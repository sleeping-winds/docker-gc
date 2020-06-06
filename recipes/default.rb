#
# Cookbook:: docker-gc
# Recipe:: default
#
# Copyright:: 2020, John Losito, All Rights Reserved.

apt_update 'update'

[
	'git',
	'devscripts',
	'debhelper',
	'build-essential',
	'dh-make',
].each do |pkg|
	package pkg do
		action :install
	end
end

git "#{Chef::Config[:file_cache_path]}/docker-gc" do
	repository "https://github.com/spotify/docker-gc.git"
end

execute 'bulid' do
	command 'debuild --no-lintian -us -uc -b'
	cwd "#{Chef::Config[:file_cache_path]}/docker-gc"
	not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/docker-gc_0.2.0_all.deb") }
end

dpkg_package 'docker-gc' do
	source "#{Chef::Config[:file_cache_path]}/docker-gc_0.2.0_all.deb"
	action :install
end

cron_d 'docker-gc' do
	action :create
	minute '0'
	hour '*'
	day '*'
	month '*'
	weekday '*'
	command '/usr/sbin/docker-gc'
end
