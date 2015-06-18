require 'spec_helper'

describe "featuring items" do
  context "when viewing a featured item" do
    let(:user) do
      u = FactoryGirl.build(:user)
      u.group_list = "admin"
      u.save
      u
    end
    it "should have a working unfeature link", :js => true do
      sign_in user
      file = create(:public_file)
      create(:featured_work, generic_file_id: file.id)
      visit sufia.generic_file_path(id: file.id)

      expect(page).to have_link "Unfeature"
      click_link "Unfeature"

      expect(page).to have_link("Feature")
      expect(GenericFile.find(file.id)).not_to be_featured
      click_link "Feature"
      expect(page).to have_link "Unfeature"
    end
  end
end
