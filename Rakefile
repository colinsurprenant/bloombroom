require 'rake'
require 'rake/clean'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

task :default => :spec

task :spec do
  RSpec::Core::RakeTask.new
end

task :make do
  Dir.chdir("ext/bloombroom/hash/cext") do
    ruby "extconf.rb"
    sh "make"
  end
  cp "ext/bloombroom/hash/cext/cext_fnv.bundle", "lib/bloombroom/hash"

  Dir.chdir("ext/bloombroom/hash/ffi") do
    ruby "extconf.rb"
    sh "make"
  end
  cp "ext/bloombroom/hash/ffi/ffi_fnv.bundle", "lib/bloombroom/hash"
end

CLEAN.include('ext/**/*{.o,.log,.so,.bundle}')
CLEAN.include('lib/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ext/**/Makefile')
