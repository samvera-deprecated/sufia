module ProxiesHelper
  def create_proxy_using_partial(*users)
    users.each do |user|
      first('a.select2-choice').click
      find(".select2-input").set  user.user_key
      page.should have_css "div.select2-result-label"
      first("div.select2-result-label").click
      within("#authorizedProxies") do
        page.should have_content(user.display_name)
      end
    end
  end

  RSpec.configure do |config|
    config.include ProxiesHelper
  end
end
