require_relative 'errors/msvc/vswhere_not_found_error'

def find_vswhere(context)
  base = context.env['ProgramFiles(x86)']
  context.logger.info("Attempting to construct vswhere path using ProgramFiles(x86): #{base}")

  vswhere_path = context.path_resolver.join_path(base, 'Microsoft Visual Studio', 'Installer', 'vswhere.exe')
  context.logger.info("Resolved vswhere path to: #{vswhere_path}")

  if context.path_resolver.path_exists?(vswhere_path)
    context.logger.info("vswhere.exe found at constructed path: #{vswhere_path}")
    return vswhere_path.to_s
  end

  context.logger.warn("vswhere.exe not found at default path. Falling back to 'where vswhere.exe'")

  result = context.command_runner.run_command('where vswhere.exe')
  if result.success? && !result.stdout.strip.empty?
    found_path = result.stdout.lines.first.strip
    context.logger.info("Found vswhere.exe via 'where': #{found_path}")
    return found_path
  end

  context.logger.error("vswhere.exe could not be found via default path or 'where' command.")
  raise VswhereNotFoundError
end