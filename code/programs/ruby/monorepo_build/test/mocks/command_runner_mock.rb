class CommandRunnerMock
  attr_reader :called
  def initialize(mock_result)
    @mock_result = mock_result
    @called = false
  end

  def run_command(command)
    @called = true
    @mock_result
  end
end