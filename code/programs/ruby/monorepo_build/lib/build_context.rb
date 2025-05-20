class BuildContext
  attr_reader :file_processing_history, :logger, :exit_handler, :env, :command_runner, :path_resolver, :command_line_arguments_provider

  def initialize(file_processing_history:, logger:, exit_handler:, env:, command_runner:, path_resolver:, command_line_arguments_provider:)
    @file_processing_history = file_processing_history
    @logger = logger
    @exit_handler = exit_handler
    @env = env
    @command_runner = command_runner
    @path_resolver = path_resolver
    @command_line_arguments_provider = command_line_arguments_provider
  end
end
