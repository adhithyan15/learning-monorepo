class BuildContext
  attr_reader :file_processing_history, :logger, :exit_handler

  def initialize(file_processing_history:, logger:, exit_handler:)
    @file_processing_history = file_processing_history
    @logger = logger
    @exit_handler = exit_handler
  end
end
