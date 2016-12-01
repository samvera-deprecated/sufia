describe GenericWork do
  describe ".properties" do
    subject { described_class.properties.keys }
    it { is_expected.to include("has_model", "create_date", "modified_date") }
  end

  describe "basic metadata" do
    before do
      allow(subject).to receive(:title).and_return(['foo', 'bar'])
    end
    it "has dc properties" do
      expect(subject.title).to eq ['foo', 'bar']
    end
  end

  describe "suppressed?" do
    let(:work) { described_class.new(title: ['demoname']) { |gw| gw.apply_depositor_metadata("user") } }
    before do
      allow(work).to receive(:state).and_return(::RDF::URI(activity_uri))
    end
    context "When a work's state is inactive" do
      let(:activity_uri) { 'http://fedora.info/definitions/1/0/access/ObjState#inactive' }
      it "is suppressed" do
        expect(work).to be_suppressed
      end
    end

    context "When a work's state is active" do
      let(:activity_uri) { 'http://fedora.info/definitions/1/0/access/ObjState#active' }
      it "is not suppressed" do
        expect(work).not_to be_suppressed
      end
    end
  end

  describe "created for someone (proxy)" do
    let(:work) { described_class.new(title: ['demoname']) { |gw| gw.apply_depositor_metadata("user") } }
    let(:transfer_to) { create(:user) }

    it "transfers the request" do
      work.on_behalf_of = transfer_to.user_key
      expect(ContentDepositorChangeEventJob).to receive(:perform_later).once
      work.save!
    end
  end

  describe "delegations" do
    let(:work) { described_class.new { |gw| gw.apply_depositor_metadata("user") } }
    let(:proxy_depositor) { create(:user) }
    before do
      work.proxy_depositor = proxy_depositor.user_key
    end
    it "includes proxies" do
      expect(work).to respond_to(:relative_path)
      expect(work).to respond_to(:depositor)
      expect(work.proxy_depositor).to eq proxy_depositor.user_key
    end
  end

  describe "trophies" do
    let(:user) { create(:user) }
    let(:w) { create(:work, user: user) }
    let!(:t) { Trophy.create(user_id: user.id, work_id: w.id) }

    it "has a trophy" do
      expect(Trophy.where(work_id: w.id).count).to eq 1
    end
    it "removes all trophies when work is deleted" do
      w.destroy
      expect(Trophy.where(work_id: w.id).count).to eq 0
    end
  end

  describe "featured works" do
    let(:work) { create(:public_work) }
    before { FeaturedWork.create(work_id: work.id) }

    subject { work }
    it { is_expected.to be_featured }

    context "when a previously featured work is deleted" do
      it "deletes the featured work as well" do
        expect { work.destroy }.to change { FeaturedWork.all.count }.from(1).to(0)
      end
    end

    context "when the work becomes private" do
      it "deletes the featured work" do
        expect do
          work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          work.save!
        end.to change { FeaturedWork.all.count }.from(1).to(0)
        expect(work).not_to be_featured
      end
    end
  end

  describe "metadata" do
    it "has descriptive metadata" do
      expect(subject).to respond_to(:relative_path)
      expect(subject).to respond_to(:depositor)
      expect(subject).to respond_to(:related_url)
      expect(subject).to respond_to(:based_near)
      expect(subject).to respond_to(:part_of)
      expect(subject).to respond_to(:contributor)
      expect(subject).to respond_to(:creator)
      expect(subject).to respond_to(:title)
      expect(subject).to respond_to(:description)
      expect(subject).to respond_to(:publisher)
      expect(subject).to respond_to(:date_created)
      expect(subject).to respond_to(:date_uploaded)
      expect(subject).to respond_to(:date_modified)
      expect(subject).to respond_to(:subject)
      expect(subject).to respond_to(:language)
      expect(subject).to respond_to(:rights)
      expect(subject).to respond_to(:resource_type)
      expect(subject).to respond_to(:identifier)
    end
  end
end
