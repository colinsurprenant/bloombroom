require 'bundler/setup'
require 'rake'
require 'rake/clean'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'ffi-compiler/compile_task'


task :default => (RUBY_PLATFORM =~ /java/) ? [:clean, :compile_ffi] : [:clean, :compile_ffi, :compile_cext]

desc "clean, make and run specsrkae"
task :spec  do
  RSpec::Core::RakeTask.new
end

desc "compile C ext and FFI ext and copy objects into lib"
task :compile_cext do
  Dir.chdir("ext/bloombroom/") do
    ruby "extconf.rb"
    sh "make"
  end
  cp "ext/bloombroom/cext_fnv.bundle", "lib/bloombroom/hash"
end

desc "compiler tasks"
namespace "ffi-compiler" do
  FFI::Compiler::CompileTask.new('ffi/bloombroom/ffi_fnv')
end
task :compile_ffi => ["ffi-compiler:default"]

CLEAN.include('ext/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ffi/**/*{.o,.log,.so,.bundle}')
CLEAN.include('lib/**/*{.o,.log,.so,.bundle}')
CLEAN.include('ext/**/Makefile')
