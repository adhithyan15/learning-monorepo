require 'pathname'

class PathResolver
  def join_path(*parts)
    Pathname.new(File.join(*parts))
  end

  def path_exists?(path)
    Pathname.new(path).exist?
  end
end