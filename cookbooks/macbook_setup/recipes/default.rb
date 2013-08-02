# coding: UTF-8
#
# Cookbook Name:: macbook_setup
# Recipe:: default
#
# Author:: Sean Fisk <sean@seanfisk.com>
# Copyright:: Copyright (c) 2013, Sean Fisk
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License")
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

require 'etc'

# Include homebrew as the default package manager.
# (default is MacPorts)
include_recipe 'homebrew'

# Set latest bash 4 as the default shell.
#
# Unfortunately, these commands will cause password prompts, meaning
# chef has to be watched. The "workaround" is to put them at the
# beginning of the run.
#
# We also need to install bash separately from the other homebrew
# packages because it needs to be available for changing the default
# shell. We don't want to wait for all the other packages to be
# installed to see the prompt, but we need the shell to be available
# before setting it as the default.
package 'bash' do
  action :install
end

PATH_TO_BASH = '/usr/local/bin/bash'
SHELLS_FILE = '/etc/shells'

# First, add bash to /etc/shells so it is recognized as a valid user shell.
execute "add latest bash to #{SHELLS_FILE}" do
  command "sudo bash -c 'echo #{PATH_TO_BASH} >> #{SHELLS_FILE}'"
  not_if do
    # Don't execute if this bash is already in the shells config file.
    File.open(SHELLS_FILE).lines.any? do
      |line| line.include?(PATH_TO_BASH)
    end
  end
end

# Then, set bash as the current user's shell.
execute 'set latest bash as default shell' do
  command "chsh -s '#{PATH_TO_BASH}'"
  # getpwuid defaults to the current user, which is what we want.
  not_if { Etc.getpwuid().shell == PATH_TO_BASH }
end

include_recipe 'dmg'
include_recipe 'zip'
include_recipe 'mac_os_x'

# Password-protected screensaver + delay
include_recipe 'mac_os_x::screensaver'

# iTerm2
include_recipe 'iterm2'

dmg_package 'Adium' do
  source 'http://download.adium.im/Adium_1.5.6.dmg'
  checksum 'd5f580b7db57348c31f8e0f18691d7758a65ad61471bf984955360f91b21edb8'
  volumes_dir 'Adium 1.5.6'
  action :install
end

dmg_package 'Quicksilver' do
  source 'http://github.qsapp.com/downloads/Quicksilver%201.0.0.dmg'
  checksum '0afb16445d12d7dd641aa8b2694056e319d23f785910a8c7c7de56219db6853c'
  dmg_name 'Quicksilver 1.0.0'
  action :install
  # This should work but it doesn't seem to. So we went with the
  # `not_if' solution below.

  # notifies :create, 'mac_os_x_plist_file[com.blacktree.Quicksilver.plist]'
end

mac_os_x_plist_file 'com.blacktree.Quicksilver.plist' do
  # Create a plist file for Quicksilver specifying the hotkey, among
  # other things. Unfortunately, this doesn't avoid going through the
  # setup assistant, but it helps out a bit.

  # Don't overwrite the file if it already exists.
  not_if do
    File.exists?(node['macbook_setup']['home'] +
                 "/Library/Preferences/#{source}")
    end
end

dmg_package 'Emacs' do
  source 'http://emacsformacosx.com/emacs-builds/' +
    'Emacs-24.3-universal-10.6.8.dmg'
  checksum '92b3a6dd0a32b432f45ea925cfa34834' +
    'c9ac9f7f0384c38775f6760f1e89365a'
  action :install
end

dmg_package 'Google Chrome' do
  source 'https://dl.google.com/chrome/mac/' +
    'stable/GGRO/googlechrome.dmg'
  checksum '0e43d17aa2fe454e890bd58313f567de' +
    '07e2343c0d447ef5496dbda9ff45e64d'
  dmg_name 'googlechrome'
  action :install
end

dmg_package 'Skim' do
  source 'http://downloads.sourceforge.net/project/' +
    'skim-app/Skim/Skim-1.4.3/Skim-1.4.3.dmg'
  checksum 'bc01dffe6f471fffc531222a56ab27f5' +
    '53ce42b91c800fe53f3770926feda809'
  action :install
end

zip_package 'gfxCardStatus' do
  # 2.2.1 is for Mac OS 10.6 Snow Leopard compatibility. 2.3 and
  # upwards require 10.7 Lion. Upgrade when we ditch the venerable
  # Snow Leopard.
  source 'http://codykrieger.com/downloads/gfxCardStatus-2.2.1.zip'
  checksum 'b6867efa99f3682042505e47850b314f' +
    '2ae39258d024aeebf63c32a28c83dbc9'
  action :install
end

zip_package 'Flux' do
  source 'https://justgetflux.com/mac/Flux.zip'
  checksum 'c4cb2b2e08c07678e4825c7472f78fe8' +
    'fca8e78846625dcb7a4fe4fcae503471'
  action :install
end

# Set up clock with day of week, date, and 24-hour clock.
mac_os_x_plist_file 'com.apple.menuextra.clock.plist'

# Show percentage on battery indicator.
mac_os_x_plist_file 'com.apple.menuextra.battery.plist'

# Clone my dotfiles and emacs git repositories

directory node['macbook_setup']['personal_dir'] do
  recursive true
  action :create
end

git node['macbook_setup']['dotfiles_dir'] do
  repository 'git@github.com:seanfisk/dotfiles.git'
  enable_submodules true
  action :checkout
  notifies :run, 'execute[install dotfiles]'
end

execute 'install dotfiles' do
  # Running `make install-osx' does the regular install, then patches
  # .tmux.conf to make this work:
  # <https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard>
  command 'make install-osx'
  cwd node['macbook_setup']['dotfiles_dir']
  action :nothing
end

git node['macbook_setup']['emacs_dir'] do
  repository 'git@github.com:seanfisk/emacs.git'
  enable_submodules true
  action :checkout
  notifies :run, 'execute[install emacs configuration]'
end

execute 'install emacs configuration' do
  command 'make install'
  cwd node['macbook_setup']['emacs_dir']
  action :nothing
end

# Install tmux-MacOSX-pasteboard reattach-to-user-namespace program
directory node['macbook_setup']['scripts_dir'] do
  recursive true
  action :create
end

tmux_macosx_dir =
  "#{Chef::Config[:file_cache_path]}/tmux-MacOSX-pasteboard"
git tmux_macosx_dir do
  repository 'https://github.com/ChrisJohnsen/' +
    'tmux-MacOSX-pasteboard.git'
  action :sync
  notifies :run, 'bash[compile and install tmux-MacOSX-pasteboard]'
end

bash 'compile and install tmux-MacOSX-pasteboard' do
  # We are using a line continuation in a Bash script, not in Ruby.
  # rubocop:disable LineContinuation
  code <<-EOH
  set -o errexit # exit on first error
  make reattach-to-user-namespace
  cp reattach-to-user-namespace \\
    '#{node["macbook_setup"]["scripts_dir"]}'
  EOH
  # rubocop:enable LineContinuation
  cwd tmux_macosx_dir
  action :nothing
end

# About installing rbenv
#
# Even though the rbenv cookbooks looks nice, they don't work as I'd
# like. fnichol's supports local install, but insists on templating
# /etc/profile.d/rbenv.sh *even when doing a local install*. That
# makes no sense. I don't want that.
#
# The RiotGames rbenv cookbook only supports global install.
#
# So let's just install through trusty homebrew.

# Install homebrew packages

node['macbook_setup']['packages'].each do |pkg_name|
  package pkg_name do
    action :install
  end
end

# Install pythonz Python installation manager
include_recipe 'pythonz'

# Install the MacTeX distribution (for composing LaTeX)

# We should have already installed the aria2c downloader with
# homebrew. Since MacTex is huge (about 2.2G), we'll use aria2c to
# torrent it.
execute 'torrent MacTeX' do
  # Make sure to check the integrity, and don't do any seeding.
  command 'aria2c --check-integrity=true --seed-time=0 ' +
    'http://www.tug.org/mactex/mactex2013.pkg.torrent'
  notifies # something
end
