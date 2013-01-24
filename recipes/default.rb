#
# Cookbook Name:: download-make-install
# Recipe:: default
#
# Copyright 2013, Takayuki SHIMIZUKAWA
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

package 'build-essential'  # for g++ compiler

node.download_make_install.packages.each do |entry|
  if entry.is_a? String
    url = entry
    target = nil
  else
    url = entry[:url]
    target = entry[:target]
  end

  download_make_install url do
    install_prefix node.download_make_install.install_prefix
    target target
  end
end
