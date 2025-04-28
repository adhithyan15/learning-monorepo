class Logger
    def info(message)
        puts "[INFO] #{message}"
    end

    def warn(message)
        puts "[WARN] #{message}"
    end

    def error(message)
        puts "[ERR] #{message}"
    end

    def fatal(message)
        puts "[FATAL ERR] #{message}"
    end

    def debug(message)
        puts "[DEBUG] #{message}"
    end
end
  