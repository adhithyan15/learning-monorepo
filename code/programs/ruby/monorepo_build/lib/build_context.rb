class BuildContext
  attr_reader :file_processing_history, :logger, :exit_handler, :env, :command_runner, :path_resolver

  def initialize(file_processing_history:, logger:, exit_handler:, env:, command_runner:, path_resolver: nil)
    @file_processing_history = file_processing_history
    @logger = logger
    @exit_handler = exit_handler
    @env = env
    @command_runner = command_runner
    @path_resolver = path_resolver
  end
end
