class EnvAccessor
  def [](key)
    ENV[key]
  end

  def key?(key)
    ENV.key?(key)
  end
end