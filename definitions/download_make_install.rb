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

define :download_make_install, :action => :build, :install_prefix => '/usr/local', :configure_options => nil, :target => nil do

  def make_extract_command(path)
    lpath = path.downcase
    EXT_TYPES.each do |ext|
      if lpath[-ext.length..-1] == ext
        cmd, opt = EXT_TYPE_CMD[ext]
        return [cmd, opt, path].join(' ')
      end
    end
    "tar zxf #{path}"  #fall-back for unknown extension.
  end

  def extract_name(path)
    lpath = path.downcase
    EXT_TYPES.each do |ext|
      if lpath[-ext.length..-1] == ext
        return path[0...-ext.length]
      end
    end
    path[0..-File::extname(path).length]  #fall-back for unknown extension.
  end

  archive_url = params[:name]
  archive_dir = Chef::Config[:file_cache_path]
  archive_file = File::basename(archive_url)
  if node[:download_make_install][:archive_dir]
    archive_url = "#{node[:download_make_install][:archive_dir]}/#{archive_file}"
  end

  install_prefix = params[:install_prefix]
  configure_options = params[:configure_options]
  target = params[:target]

  extract_command = make_extract_command(archive_file)
  extract_path = "#{archive_dir}/#{extract_name(archive_file)}"

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

      not_if {File.exists?("#{archive_dir}/#{archive_file}") or (target and File.exists?(target))}
    end

    execute "extract #{archive_file}" do
      cwd archive_dir
      command extract_command
      not_if {File.exists?(extract_path) or (target and File.exists?(target))}
    end

    execute "configure #{archive_file}" do
      cwd extract_path
      command "./configure --prefix=#{install_prefix} #{configure_options}"
      not_if {File.exists?("#{extract_path}/Makefile") or (target and File.exists?(target))}
    end

    execute "make #{archive_file}" do
      cwd extract_path
      command "make"
      not_if {(target and File.exists?(target))}
    end

    execute "make install #{archive_file}" do
      cwd extract_path
      command "make install"
      not_if {(target and File.exists?(target))}
      notifies :run, "execute[ldconfig #{archive_file}]", :immediately
    end

    execute "ldconfig #{archive_file}" do
      action :nothing
      command "ldconfig"
    end

  end
end
