require_relative 'command_line_arguments_provider'

class DefaultCommandLineArgumentsProvider < CommandLineArgumentsProvider
  def arguments
    ARGV.dup
  end
end