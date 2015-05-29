require 'spec_helper'

# Run the jasmine tests by running the jasmine:ci rake command and capturing the output
#   The spec will fail if any jasmine tests fails
#
#   If you have a jasmine syntax error the test will fail since there will not be zero failures
#
#   If you add a new jasmine test by adding a file to spec/javascripts/*spec.js* make sure the
#   number of test run increments or you may have a syntax error inside your jasmine test
#
describe "Jasmine" do
  it "expects all jasmine tests to pass" do
    load_rake_environment ["#{jasmine_path}/lib/jasmine/tasks/jasmine.rake"]
    jasmine_out = run_task 'jasmine:ci'
    unless jasmine_out.include?  "0 failures"
      puts "\n\n************************  Jasmine Output *************"
      puts jasmine_out
      puts "************************  Jasmine Output *************\n\n"
    else
      js_specs_count = Dir['spec/javascripts/**/*_spec.js*'].count
      puts "#{jasmine_out.match(/\n(.+) specs/)[1]} jasmine specs run (in #{js_specs_count} jasmine test files)"
    end
    expect(jasmine_out).to include "0 failures"
    expect(jasmine_out).to_not include "\n0 specs"
  end

end

def jasmine_path
  Gem.loaded_specs['jasmine'].full_gem_path
end
