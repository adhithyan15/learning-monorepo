require 'open3'
require_relative 'command_result'

class CommandRunner
  def run_command(command, chdir: nil)
    stdout, stderr, status = Open3.capture3(command, chdir: chdir)
    CommandResult.new(stdout: stdout, stderr: stderr, status: status)
  end
end