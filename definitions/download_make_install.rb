EXT_TYPE_CMD = {
  '.tar' => ['tar', 'xf'],
  '.tgz' => ['tar', 'zxf'],
  '.tar.gz' => ['tar', 'zxf'],
  '.tar.bz2' => ['tar', 'jxf'],
  '.zip' => ['unzip', ''],
  '.gz' => ['gzip', '-d'],
  '.bz2' => ['bzip2', '-d'],
}
EXT_TYPES = EXT_TYPE_CMD.keys.collect{|k| [k.length, k]}.sort.reverse.collect{|n,k|k}

def extract_command(path)
  lpath = path.downcase
  EXT_TYPES.each do |ext|
    if lpath[-ext.length..-1] == ext
      cmd, opt = EXT_TYPE_CMD[ext]
      return [cmd, opt, path].join(' ')
    end
  end
  "tar zxf #{path}"  #fall-back for unknown extension.
end

def extract_name(path):
  lpath = path.downcase
  EXT_TYPES.each do |ext|
    if lpath[-ext.length..-1] == ext
      return path[0..-ext.length]
    end
  end
  path[0..-File::extname(path).length]  #fall-back for unknown extension.
end

define :download_make_install, :action => :build, :install_prefix => '/usr/local' do
  archive_url = params[:name]
  archive_dir = Chef::Config[:file_cache_path]
  archive_file = File::basename(archive_url)
  if node[:download_make_install][:archive_dir]
    archive_url = "#{node[:download_make_install][:archive_dir]}/#{archive_file}"
  end

  install_prefix = params[:install_prefix]

  case params[:action]
  when :build
    script "Download #{archive_file}" do
      interpreter "ruby"
      code <<-EOH
        require 'open-uri'
        open("#{archive_url}", 'rb') do |input|
          open("#{archive_dir}/#{archive_file}", 'wb') do |output|
            while data = input.read(8192) do
              output.write(data)
            end
          end
        end
      EOH

      notifies :run, "execute[extract-source]"
    end

    execute "extract-source" do
      action :nothing
      cwd archive_dir
      command extract_command(archive_file)
      not_if "test -d #{archive_dir}/{extract_name(archive_file)}"
      notifies :run, "execute[configure-source]"
    end

    execute "configure-source" do
      action :nothing
      cwd "#{archive_dir}/{extract_name(archive_file)}"
      command "./configure --prefix=#{install_prefix}"
      not_if "test -f #{archive_dir}/{extract_name(archive_file)}/Makefile"
      notifies :run, "execute[make-source]"
    end

    execute "make-source" do
      action :nothing
      cwd "#{archive_dir}/{extract_name(archive_file)}"
      command "make"
      notifies :run, "execute[make-install-source]"
    end

    execute "make-install-source" do
      action :nothing
      cwd "#{archive_dir}/{extract_name(archive_file)}"
      command "make install"
    end

  end
end
