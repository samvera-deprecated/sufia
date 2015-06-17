module Locations
  def go_to_dashboard_files
    visit '/dashboard/files'
    expect(page).to have_selector('li.active', text: "My Files")
  end

  def go_to_user_profile
    first(".dropdown-toggle").click
    click_link "my profile"
  end
end

RSpec.configure do |config|
  config.include Locations
end
