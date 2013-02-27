require 'bundler/setup'
require 'rake'
require 'rake/clean'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'ffi'
require 'ffi-compiler/compile_task'

task :default => [:clean, :compile_ffi, :spec]

desc "clean, make and run specs"
task :spec  do
  RSpec::Core::RakeTask.new
end

desc "FFI compiler"
namespace "ffi-compiler" do
  FFI::Compiler::CompileTask.new('ffi/bloombroom/hash/ffi_fnv')
end
task :compile_ffi => ["ffi-compiler:default"]

CLEAN.include('ffi/**/*{.o,.log,.so,.bundle}')
CLEAN.include('lib/**/*{.o,.log,.so,.bundle}')
