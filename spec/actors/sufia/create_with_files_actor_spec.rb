describe Sufia::CreateWithFilesActor do
  let(:create_actor) { double('create actor', create: true,
                                              curation_concern: work,
                                              update: true,
                                              user: user) }
  let(:actor) do
    CurationConcerns::Actors::ActorStack.new(work, user, [described_class])
  end
  let(:user) { create(:user) }
  let(:uploaded_file1) { Sufia::UploadedFile.create(user: user) }
  let(:uploaded_file2) { Sufia::UploadedFile.create(user: user) }
  let(:work) { create(:generic_work, user: user) }
  let(:uploaded_file_ids) { [uploaded_file1.id, uploaded_file2.id] }
  let(:attributes) { { uploaded_files: uploaded_file_ids } }

  [:create, :update].each do |mode|
    context "on #{mode}" do
      before do
        allow(CurationConcerns::Actors::RootActor).to receive(:new).and_return(create_actor)
        allow(create_actor).to receive(mode).and_return(true)
      end
      context "when uploaded_file_ids include nil" do
        let(:uploaded_file_ids) { [nil, uploaded_file1.id, nil] }
        it "will discard those nil values when attempting to find the associated UploadedFile" do
          expect(AttachFilesToWorkJob).to receive(:perform_later)
          expect(Sufia::UploadedFile).to receive(:find).with([uploaded_file1.id]).and_return([uploaded_file1])
          actor.public_send(mode, attributes)
        end
      end

      context "when uploaded_file_ids belong to me" do
        it "attaches files" do
          expect(AttachFilesToWorkJob).to receive(:perform_later).with(GenericWork, [uploaded_file1, uploaded_file2])
          expect(actor.public_send(mode, attributes)).to be true
        end
      end

      context "when uploaded_file_ids don't belong to me" do
        let(:uploaded_file2) { Sufia::UploadedFile.create }
        it "doesn't attach files" do
          expect(AttachFilesToWorkJob).not_to receive(:perform_later)
          expect(actor.public_send(mode, attributes)).to be false
        end
      end
    end
  end

  describe "mediated deposit" do
    subject { actor.curation_concern.state }
    let(:inactive_uri) { RDF::URI('http://fedora.info/definitions/1/0/access/ObjState#inactive') }
    let!(:admin) { create(:user) }
    let!(:non_admin) { create(:user) }
    let(:admin_inbox) { admin.mailbox.inbox }
    let(:non_admin_inbox) { non_admin.mailbox.inbox }
    before do
      allow(Flipflop).to receive(:enable_mediated_deposit?).and_return(mediation_enabled)
      allow(AttachFilesToWorkJob).to receive(:perform_later).with(GenericWork, [uploaded_file1, uploaded_file2])
      actor.create(attributes)
    end
    context "when enabled" do
      let(:mediation_enabled) { true }
      it { is_expected.to eq inactive_uri }
      context "non-admin users" do
        it "do not receive a new work notification" do
          expect(non_admin_inbox.count).to eq(0)
        end
      end
      context "admin users" do
        before do
          allow_any_instance_of(User).to receive(:admin?).and_return(true)
          actor.create(attributes)
        end
        it "receive a new work notification" do
          expect(admin_inbox.count).to eq(1)
        end
      end
    end
    context "when disabled" do
      let(:mediation_enabled) { false }
      it { is_expected.to be nil }
      it "does not deliver a notification to admins" do
        expect(admin_inbox.count).to eq(0)
      end
    end
  end
end
