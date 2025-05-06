class PathResolverMock
  def initialize(path_exists:)
    @path_exists = path_exists
  end

  def join_path(*segments)
    File.join(*segments)
  end

  def path_exists?(path)
    @path_exists
  end
end