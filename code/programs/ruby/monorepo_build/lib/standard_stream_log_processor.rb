class StandardStreamLogProcessor
  def initialize(stdout_proc, stderr_proc)
    @stdout_proc = stdout_proc
    @stderr_proc = stderr_proc
  end

  def process(level:, message:)
    formatted = "[#{level.to_s.upcase}] #{message}"

    case level
    when :info, :warn, :debug
      @stdout_proc.call(formatted)
    when :error, :fatal
      @stderr_proc.call(formatted)
    else
      @stdout_proc.call(formatted)
    end
  end
end
  