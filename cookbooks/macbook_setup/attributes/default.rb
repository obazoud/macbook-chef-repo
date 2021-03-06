# -*- coding: utf-8 -*-
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

default['macbook_setup']['home'] = ENV['HOME']
default['macbook_setup']['personal_dir'] =
  "#{default['macbook_setup']['home']}/src/personal"
default['macbook_setup']['dotfiles_dir'] =
  "#{default['macbook_setup']['personal_dir']}/dotfiles"
default['macbook_setup']['emacs_dir'] =
  "#{default['macbook_setup']['personal_dir']}/emacs"
default['macbook_setup']['scripts_dir'] =
  "#{default['macbook_setup']['home']}/bin"
default['macbook_setup']['fonts_dir'] =
  "#{default['macbook_setup']['home']}/Library/Fonts"

# Notes:
#
# * To fix the aria2 build, I ran `brew edit gmp' and added a
#   `--with-pic' flag. Hopefully I will not have issues in the
#   future. See here: <https://github.com/mxcl/homebrew/issues/12946>
# * I prefer ohcount to cloc and sloccount.
# * ZeroMQ (zmq) is included to speed up IPython installs. It can install a
#   bundled version to a virtualenv, but it's faster to have a globally built
#   version.
#
default['macbook_setup']['packages'] = %w{
ack
aria2
astyle
autojump
coreutils
dos2unix
git
graphicsmagick
graphviz
htop
markdown
mobile-shell
nmap
ohcount
parallel
pstree
pyenv
pyenv-virtualenv
qpdf
rbenv
ruby-build
tmux
tree
valgrind
watch
wget
zmq
zsh
}
