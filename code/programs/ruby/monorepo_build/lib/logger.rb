class Logger
  def initialize(processor:)
    @processor = processor
  end

  def info(message)
    @processor.process(level: :info, message: message)
  end

  def warn(message)
    @processor.process(level: :warn, message: message)
  end

  def error(message)
    @processor.process(level: :error, message: message)
  end

  def fatal(message)
    @processor.process(level: :fatal, message: message)
  end

  def debug(message)
    @processor.process(level: :debug, message: message)
  end
end
