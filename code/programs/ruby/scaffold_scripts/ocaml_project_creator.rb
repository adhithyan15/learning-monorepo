require "fileutils"
require "optparse"

# === CLI ARGUMENTS ===

options = {
  kind: :exe
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby #{__FILE__} <relative_path> <project_name> [--lib|--exe]"

  opts.on("--lib", "Scaffold as a library") { options[:kind] = :lib }
  opts.on("--exe", "Scaffold as an executable (default)") { options[:kind] = :exe }
end.order!(ARGV)

if ARGV.length != 2
  puts "Usage: ruby #{__FILE__} <relative_path> <project_name> [--lib|--exe]"
  exit 1
end

relative_path, project_name = ARGV
project_root = File.expand_path(File.join(relative_path, project_name))

# === PATHS ===

main_ml = File.join(project_root, "#{project_name}.ml")
dune_file = File.join(project_root, "dune")
opam_file = File.join(project_root, "#{project_name}.opam")
dune_project_file = File.join(project_root, "dune-project")
readme_file = File.join(project_root, "README.md")
gitignore_file = File.join(project_root, ".gitignore")

# === CREATE DIRECTORY ===
FileUtils.mkdir_p(project_root)

# === .ml CONTENT ===
ml_content =
  if options[:kind] == :lib
    <<~OCAML
      let greet () = "Hello from #{project_name}!"
    OCAML
  else
    <<~OCAML
      let () = print_endline "Hello, World from #{project_name}!"
    OCAML
  end

File.write(main_ml, ml_content)

# === dune CONTENT ===
dune_content =
  if options[:kind] == :lib
    <<~DUNE
      (library
       (name #{project_name})
       (public_name #{project_name}))
    DUNE
  else
    <<~DUNE
      (executable
       (name #{project_name})
       (public_name #{project_name}))
    DUNE
  end

File.write(dune_file, dune_content)

# === .opam ===
File.write(opam_file, <<~OPAM)
  opam-version: "2.1"
  name: "#{project_name}"
  depends: [
    "ocaml"
    "dune"
  ]
  build: [
    ["dune" "build" "-p" name "-j" jobs]
  ]
OPAM

# === dune-project ===
File.write(dune_project_file, <<~DUNE_PROJECT)
  (lang dune 3.8)
  (name #{project_name})
DUNE_PROJECT

# === README.md ===
File.write(readme_file, "")

# === .gitignore ===
File.write(gitignore_file, <<~GITIGNORE)
  _build/
  .merlin
  *.install
  .vscode/
  .opam-switch/
  *.exe
  *.swp
GITIGNORE

# === DONE ===
kind_str = options[:kind] == :lib ? "library" : "executable"
puts "✅ Successfully scaffolded OCaml #{kind_str} '#{project_name}' at #{project_root}"