class CommandResultMock
  attr_reader :stdout, :stderr, :success

  def initialize(stdout:, stderr:, success:)
    @stdout = stdout
    @stderr = stderr
    @success = success
  end

  def success?
    @success
  end
end