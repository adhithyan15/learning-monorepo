require 'fileutils'
require 'json'

# Read path from CLI
target_path = ARGV[0]
abort("Usage: ruby php_project_scaffold.rb /path/to/project_name") unless target_path

project_name = File.basename(target_path)
abort("Project already exists at #{target_path}!") if Dir.exist?(target_path)

puts "[INFO] Creating PHP project: #{project_name} at #{target_path}"
FileUtils.mkdir_p("#{target_path}/src")
FileUtils.mkdir_p("#{target_path}/.devcontainer") # Optional future use

# index.php
File.write("#{target_path}/index.php", <<~PHP)
  <?php

  require __DIR__ . '/vendor/autoload.php';

  use App\\Hello;

  $hello = new Hello();
  $hello->sayHello();
PHP

# Hello class
File.write("#{target_path}/src/Hello.php", <<~PHP)
  <?php

  namespace App;

  class Hello {
      public function sayHello(): void {
          echo "Hello from Composer-powered PHP!\\n";
      }
  }
PHP

# composer.json
composer_data = {
  "name" => "yourname/#{project_name}",
  "description" => "A simple PHP Hello World project with Composer",
  "require" => {},
  "autoload" => {
    "psr-4" => {
      "App\\" => "src/"
    }
  }
}
File.write("#{target_path}/composer.json", JSON.pretty_generate(composer_data))

# Dockerfile
File.write("#{target_path}/Dockerfile", <<~DOCKER)
  FROM php:8.2-cli

  RUN apt-get update && apt-get install -y \\
      git \\
      unzip \\
      curl \\
      && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \\
      && composer --version

  WORKDIR /workspace
  COPY . .
  RUN composer install

  CMD ["bash"]
DOCKER

# .gitignore
File.write("#{target_path}/.gitignore", <<~GITIGNORE)
  /vendor/
  *.log
  .DS_Store
GITIGNORE

puts "[✅] Project '#{project_name}' scaffolded at #{target_path}"
puts "👉 cd #{target_path} && docker build -t #{project_name} . && docker run -it --rm -v \"$PWD\":/workspace #{project_name}"
