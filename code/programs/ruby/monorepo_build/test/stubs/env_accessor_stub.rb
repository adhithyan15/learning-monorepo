class EnvAccessorStub
  def [](key)
    # Simulate ENV['ProgramFiles(x86)']
    'C:/MockProgramFiles'
  end
  def key?(key)
    true
  end
end