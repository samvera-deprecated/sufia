require 'rake'

describe "Rake tasks" do
  before do
    load_rake_environment [
      File.expand_path("../../../tasks/sufia_user.rake", __FILE__),
      File.expand_path("../../../lib/tasks/default_admin_set.rake", __FILE__)
    ]
  end

  describe "sufia:user:list_emails" do
    let!(:user1) { FactoryGirl.create(:user) }
    let!(:user2) { FactoryGirl.create(:user) }

    before do
      load_rake_environment [
        File.expand_path("../../../tasks/sufia_user.rake", __FILE__),
        File.expand_path("../../../lib/tasks/default_admin_set.rake", __FILE__)
      ]
    end

    it "creates a file" do
      run_task "sufia:user:list_emails"
      expect(File.exist?("user_emails.txt")).to be_truthy
      expect(IO.read("user_emails.txt")).to include(user1.email, user2.email)
      File.delete("user_emails.txt")
    end

    it "creates a file I give it" do
      run_task "sufia:user:list_emails", "abc123.txt"
      expect(File.exist?("user_emails.txt")).not_to be_truthy
      expect(File.exist?("abc123.txt")).to be_truthy
      expect(IO.read("abc123.txt")).to include(user1.email, user2.email)
      File.delete("abc123.txt")
    end
  end

  describe 'sufia:default_admin_set:create' do
    before do
      AdminSet.find(AdminSet::DEFAULT_ID).eradicate if AdminSet.exists?(AdminSet::DEFAULT_ID)
    end

    it 'creates the default AdminSet' do
      expect { run_task 'sufia:default_admin_set:create' }.to change { AdminSet.count }.by(1)
    end
  end
end
