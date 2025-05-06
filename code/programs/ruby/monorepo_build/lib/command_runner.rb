require 'open3'
require_relative 'command_result'
require_relative 'fake_failure_status'

class CommandRunner
  def initialize(logger)
    @logger = logger
  end

  def run_command(command, chdir: nil)
    location_info = chdir ? " in #{chdir}" : ""
    @logger.info("Executing command: #{command}#{location_info}")

    begin
      stdout, stderr, status = Open3.capture3(command, chdir: chdir)
    rescue => e
      @logger.warn("Exception while executing command: #{e.message}")
      stdout = ''
      stderr = e.message
      status = FakeFailureStatus.new
    end

    unless status.success?
      @logger.error("Command failed with status #{status.exitstatus}: #{command}")
      @logger.error("Stderr: #{stderr}") unless stderr.to_s.strip.empty?
    end

    CommandResult.new(stdout: stdout, stderr: stderr, status: status)
  end
end