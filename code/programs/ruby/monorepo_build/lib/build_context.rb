class BuildContext
  attr_reader :file_processing_history, :logger

  def initialize(file_processing_history:, logger:)
    @file_processing_history = file_processing_history
    @logger = logger
  end
end
