require 'minitest/autorun'
require_relative '../lib/get_context'
require_relative '../lib/find_vswhere'
require_relative '../lib/errors/msvc/vswhere_not_found_error'
require_relative 'mocks/path_resolver_mock'
require_relative 'mocks/command_runner_mock'
require_relative 'mocks/command_result_mock'
require_relative 'stubs/env_accessor_stub'
require_relative 'stubs/logger_stub'

class FindVswhereTest < Minitest::Test
  def test_returns_path_if_vswhere_exists_directly
    set_vswhere_path_exists = true # Simulate that vswhere.exe exists directly in the path
    path_resolver = PathResolverMock.new(path_exists: set_vswhere_path_exists)
    env = EnvAccessorStub.new
    vswhere_command_path = "C:\\Mocked\\vswhere.exe\n" # Mocked output of the 'where' command
    command_result_mock = CommandResultMock.new(success: false, stdout: vswhere_command_path, stderr: "")
    command_runner = CommandRunnerMock.new(command_result_mock)
    logger = LoggerStub.new

    context = get_context(
      path_resolver_to_override: path_resolver,
      env_accessor_to_override: env,
      command_runner_to_override: command_runner,
      logger_to_override: logger
    )

    result = find_vswhere(context)
    assert_equal command_runner.called, false # Ensure the command runner was not called
  end

  def test_uses_where_command_when_vswhere_not_in_path
    set_vswhere_path_exists = false # Simulate that vswhere.exe does not exist directly in the path
    path_resolver = PathResolverMock.new(path_exists: set_vswhere_path_exists)
    env = EnvAccessorStub.new
    set_vswhere_command_run_success = true # Simulate that the 'where' command runs successfully
    vswhere_command_path = "C:\\Mocked\\vswhere.exe\n" # Mocked output of the 'where' command
    command_result_mock = CommandResultMock.new(success: set_vswhere_command_run_success, stdout: vswhere_command_path, stderr: "")
    command_runner = CommandRunnerMock.new(command_result_mock)
    logger = LoggerStub.new

    context = get_context(
      path_resolver_to_override: path_resolver,
      env_accessor_to_override: env,
      command_runner_to_override: command_runner,
      logger_to_override: logger
    )

    result = find_vswhere(context)
    assert command_runner.called # Ensure the command runner was called
  end

  def test_raises_error_when_vswhere_not_found
    set_vswhere_path_exists = false # Simulate that vswhere.exe does not exist directly in the path
    path_resolver = PathResolverMock.new(path_exists: set_vswhere_path_exists)
    env = EnvAccessorStub.new
    set_vswhere_command_run_success = false # Simulate that the 'where' command fails
    vswhere_command_path = "" # Mocked output of the 'where' command
    command_result_mock = CommandResultMock.new(success: set_vswhere_command_run_success, stdout: vswhere_command_path, stderr: "Error")
    command_runner = CommandRunnerMock.new(command_result_mock)
    logger = LoggerStub.new

    context = get_context(
      path_resolver_to_override: path_resolver,
      env_accessor_to_override: env,
      command_runner_to_override: command_runner,
      logger_to_override: logger
    )

    assert_raises(VswhereNotFoundError) do
      find_vswhere(context)
    end
  end

  def test_raises_error_when_vswhere_found_but_stdout_empty
    set_vswhere_path_exists = false # Simulate that vswhere.exe does not exist directly in the path
    path_resolver = PathResolverMock.new(path_exists: set_vswhere_path_exists)
    env = EnvAccessorStub.new
    set_vswhere_command_run_success = true # Simulate that the 'where' command runs successfully
    vswhere_command_path = "" # Mocked output of the 'where' command
    stdout_contents = "" # Simulate empty stdout
    command_result_mock = CommandResultMock.new(success: set_vswhere_command_run_success, stdout: stdout_contents, stderr: "")
    command_runner = CommandRunnerMock.new(command_result_mock)
    logger = LoggerStub.new

    context = get_context(
      path_resolver_to_override: path_resolver,
      env_accessor_to_override: env,
      command_runner_to_override: command_runner,
      logger_to_override: logger
    )

    assert_raises(VswhereNotFoundError) do
      find_vswhere(context)
    end
  end
end