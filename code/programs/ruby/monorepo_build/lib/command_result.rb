class CommandResult
  attr_reader :stdout, :stderr, :status

  def initialize(stdout:, status:, stderr: nil)
    @stdout = stdout
    @stderr = stderr
    @status = status
  end

  def success?
    status.success?
  end
end