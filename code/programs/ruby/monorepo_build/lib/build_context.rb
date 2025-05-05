class BuildContext
  attr_reader :file_processing_history, :logger, :exit_handler, :env, :command_runner

  def initialize(file_processing_history:, logger:, exit_handler:, env:, command_runner:)
    @file_processing_history = file_processing_history
    @logger = logger
    @exit_handler = exit_handler
    @env = env
    @command_runner = command_runner
  end
end
