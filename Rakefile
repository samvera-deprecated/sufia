#!/usr/bin/env rake

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

Dir.glob('tasks/*.rake').each { |r| import r }
import 'sufia-models/lib/tasks/sufia-models_tasks.rake'

task default: :ci
