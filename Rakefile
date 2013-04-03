require 'rake/testtask'
require_relative 'version'

name = "#{$gem_name}-#{$version}.gem"

rule '.class' => '.java' do |t|
  sh "javac #{t.source}"
end

desc 'default task'
task :default => [:install_gem]

desc 'Makes a Gem'
task :make_gem => 'mdarray-0.4.0.gem' do
  sh "gem build #{$gem_name}.gemspec"
end

desc 'Install the gem in the standard location'
task :install_gem => [:make_gem] do
  sh "gem install #{$gem_name}-#{$version}.gem"
end

desc 'Make documentation'
task :make_doc do
  sh "yard doc lib/*.rb lib/**/*.rb"
end


=begin
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_complete.rb']
  t.verbose = true
  t.warning = true
end
=end
