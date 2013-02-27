require 'bundler/setup'
require 'rake'
require 'rake/clean'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'ffi-compiler/compile_task'

task :default => [:clean, :compile_ffi] + ((RUBY_PLATFORM =~ /java/) ? [] : [:compile_cext]) + [:spec]

desc "clean, make and run specsrkae"
task :spec  do
  RSpec::Core::RakeTask.new
end

desc "C ext compiler"
task :compile_cext do
  Dir.chdir("ext/bloombroom/") do
    ruby "extconf.rb"
    sh "make"
  end
  cp "ext/bloombroom/cext_fnv.bundle", "lib/bloombroom/hash"
end

desc "FFI compiler"
namespace "ffi-compiler" do
  FFI::Compiler::CompileTask.new('ffi/bloombroom/ffi_fnv')
end
task :compile_ffi => ["ffi-compiler:default"]

CLEAN.include('ext/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ffi/**/*{.o,.log,.so,.bundle}')
CLEAN.include('lib/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ext/**/Makefile')
