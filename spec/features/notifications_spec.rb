describe "Notifications page", type: :feature do
  before do
    sign_in FactoryGirl.create(:user_with_mail)
    visit "/notifications"
  end

  it "lists notifications with date, subject and message" do
    expect(page).to have_content "User Notifications"
    expect(page.find(:xpath, '//thead/tr')).to have_content "Date"
    expect(page.find(:xpath, '//thead/tr')).to have_content "Subject"
    expect(page.find(:xpath, '//thead/tr')).to have_content "Message"
    expect(page).to have_content "These files could not be updated. You do not have sufficient privileges to edit them. "
    expect(page).to have_content "These files have been saved"
    expect(page).to have_content "File 1 could not be updated. You do not have sufficient privileges to edit it."
    expect(page).to have_content "File 1 has been saved"
    expect(page).to have_content "Batch upload permission denied  "
    expect(page).to have_content "Batch upload complete"
  end
end
