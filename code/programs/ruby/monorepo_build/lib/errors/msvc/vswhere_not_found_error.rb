class VSWhereNotFoundError < StandardError
  def initialize
    super('vswhere.exe not found at standard location or in PATH. Cannot locate Visual Studio.')
  end
end