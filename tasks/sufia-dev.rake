require 'rspec/core'
require 'rspec/core/rake_task'
require 'jettywrapper'
require 'engine_cart/rake_task'
require 'rubocop/rake_task'

Jettywrapper.hydra_jetty_version = "v8.5.0"

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

desc 'Run specs and style checker'
task :spec do
  Rake::Task['rubocop'].invoke
  RSpec::Core::RakeTask.new(:spec)
end

desc 'Spin up hydra-jetty and run specs'
task ci: ['engine_cart:generate', 'jetty:clean', 'sufia:jetty:config'] do
  puts 'running continuous integration'
  # No need to maintain minter state on Travis
  reset_statefile! if ENV['TRAVIS'] == 'true'
  jetty_params = Jettywrapper.load_config
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end

 def reset_statefile!
   FileUtils.rm_f('/tmp/minter-state')
 end
