require 'rake'
require 'rake/clean'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :default => :spec

task :spec do
  RSpec::Core::RakeTask.new
end

task :make do
  Dir.chdir("ext/bloombroom/hash") do
    ruby "extconf.rb"
    sh "make"
  end

  Dir.chdir("ffi/bloombroom/hash") do
    ruby "extconf.rb"
    sh "make"
  end
end

CLEAN.include('ext/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ext/**/Makefile')
CLEAN.include('ffi/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ffi/**/Makefile')
