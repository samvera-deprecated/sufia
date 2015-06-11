require 'spec_helper'

describe "Jasmine" do
  it "expects all jasmine tests to pass" do
    load_rake_environment ["#{jasmine_path}/lib/jasmine/tasks/jasmine.rake"]
    jasmine_out = run_task 'jasmine:ci'
    unless jasmine_out.include?  "0 failures"
      puts "************************  Jasmine Output *************\n\n"
      puts jasmine_out
      puts "************************  Jasmine Output *************\n\n"
    end
    expect(jasmine_out).to include "0 failures"
    expect(jasmine_out).to_not include "0 specs"
  end

end

def jasmine_path
  Gem.loaded_specs['jasmine'].full_gem_path
end
