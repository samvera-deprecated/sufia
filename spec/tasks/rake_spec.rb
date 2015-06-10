require 'spec_helper'
require 'rake'

describe "Rake tasks" do

  describe "sufia:empty_batches" do
    before do
      load_rake_environment [File.expand_path("../../../sufia-models/lib/tasks/batch_cleanup.rake", __FILE__)]
    end
    subject { run_task "sufia:empty_batches" }
    
    context "without an empty batch" do
      it { is_expected.to eq "Output: \n Errors:" }
    end
    
    context "with an empty batch" do
      before { Batch.create("empty-batch") }
      it { is_expected.to start_with("Output: empty-batch contains no files - to delete, rerun with the remove option") }
      
      describe "removing the empty batch" do
        subject { run_task "sufia:empty_batches", "remove" }
        it { is_expected.to start_with("Output: empty-batch contains no files - deleted") }
      end
    end
  end

  describe "sufia:migrate" do
    let(:namespaced_id) { "sufia:123" }
    let(:corrected_id)  { "123" }
    before do
      load_rake_environment [File.expand_path("../../../sufia-models/lib/tasks/migrate.rake", __FILE__)]
    end

    describe "deleting the namespace from ProxyDepositRequest#generic_file_id" do
      let(:sender) { FactoryGirl.find_or_create(:jill) }
      let(:receiver) { FactoryGirl.find_or_create(:archivist) }
      before do
        ProxyDepositRequest.create(generic_file_id: namespaced_id, sending_user: sender, receiving_user: receiver, sender_comment: "please take this")
        run_task "sufia:migrate:proxy_deposits"
      end
      subject { ProxyDepositRequest.first.generic_file_id }
      it { is_expected.to eql corrected_id }
    end

    describe "deleting the namespace from ChecksumAuditLog#generic_file_id" do
      before do
        ChecksumAuditLog.create(generic_file_id: namespaced_id)
        run_task "sufia:migrate:audit_logs"
      end
      subject { ChecksumAuditLog.first.generic_file_id }
      it { is_expected.to eql corrected_id }
    end
  end

  describe "sufia:user:list_emails" do
    let!(:user1) { FactoryGirl.create(:user) }
    let!(:user2) { FactoryGirl.create(:user) }

    before do
      load_rake_environment [File.expand_path("../../../tasks/sufia-user.rake", __FILE__)]
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

end
