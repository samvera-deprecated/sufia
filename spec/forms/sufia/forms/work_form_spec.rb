describe Sufia::Forms::WorkForm, :no_clean do
  let(:work) { GenericWork.new }
  let(:form) { described_class.new(work, nil) }
  let(:works) { [GenericWork.new, FileSet.new, GenericWork.new] }
  let(:files) { [FileSet.new, GenericWork.new, FileSet.new] }

  describe "#ordered_fileset_members" do
    it "expects ordered fileset members" do
      allow(work).to receive(:ordered_members).and_return(files)
      expect(form.ordered_fileset_members.size).to eq(2)
    end
  end

  describe "#ordered_work_members" do
    it "expects ordered work members" do
      allow(work).to receive(:ordered_members).and_return(works)
      expect(form.ordered_work_members.size).to eq(2)
    end
  end

  describe "#in_work_members" do
    it "expects parent work members" do
      allow(work).to receive(:in_works).and_return(works)
      expect(form.in_work_members.size).to eq(3)
    end
  end

  describe "#version" do
    before do
      allow(work).to receive(:etag).and_return('123456')
    end
    subject { form.version }
    it { is_expected.to eq '123456' }
  end

  describe ".build_permitted_params" do
    before do
      allow(described_class).to receive(:model_class).and_return(GenericWork)
    end
    subject { described_class.build_permitted_params }
    context "without mediated deposit" do
      it do
        is_expected.to include(:version,
                               permissions_attributes: [:type, :name, :access, :id, :_destroy])
      end
    end
  end

  describe ".model_attributes" do
    before do
      allow(described_class).to receive(:model_class).and_return(GenericWork)
    end
    subject { described_class.model_attributes(ActionController::Parameters.new(attributes)) }

    context "with metadata" do
      let(:attributes) do
        { "title" => ["Test", "second title"],
          "creator" => ["foo", ""],
          "keyword" => ["bar", ""],
          "rights" => ["http://www.europeana.eu/portal/rights/rr-r.html", ""],
          "representative_id" => "pz50gw130",
          "thumbnail_id" => "pz50gw130",
          "admin_set_id" => "hm50tr726",
          "ordered_member_ids" => ["pz50gw130", ""],
          "visibility" => "open",
          "visibility_during_embargo" => "restricted",
          "embargo_release_date" => "2017-02-04",
          "visibility_after_embargo" => "open",
          "visibility_during_lease" => "open",
          "lease_expiration_date" => "2017-02-04",
          "visibility_after_lease" => "restricted",
          "version" => "W/\"7fca5692a270f8d92228cf2ff3af1a6bf2095b48\"" }
      end

      let(:expected_results) do
        {
          "title" => ["Test", "second title"],
          "creator" => ["foo"],
          "keyword" => ["bar"],
          "rights" => ["http://www.europeana.eu/portal/rights/rr-r.html"],
          "representative_id" => "pz50gw130",
          "thumbnail_id" => "pz50gw130",
          "visibility_during_embargo" => "restricted",
          "embargo_release_date" => "2017-02-04",
          "visibility_after_embargo" => "open",
          "visibility_during_lease" => "open",
          "lease_expiration_date" => "2017-02-04",
          "visibility_after_lease" => "restricted",
          "visibility" => "open",
          "ordered_member_ids" => ["pz50gw130"],
          "admin_set_id" => "hm50tr726",
          "version" => "W/\"7fca5692a270f8d92228cf2ff3af1a6bf2095b48\""
        }
      end
      it do
        is_expected.to eq ActionController::Parameters.new(expected_results).permit!
      end
    end

    context "when a user is granted edit access" do
      let(:attributes) { { permissions_attributes: [{ type: 'person', name: 'justin', access: 'edit' }] } }
      it { is_expected.to eq ActionController::Parameters.new(permissions_attributes: [ActionController::Parameters.new(type: 'person', name: 'justin', access: 'edit')]).permit! }
    end

    context "when a user is granted edit access" do
      let(:attributes) { { permissions_attributes: [{ type: 'person', name: 'justin', access: 'edit' }] } }
      it { is_expected.to eq ActionController::Parameters.new(permissions_attributes: [ActionController::Parameters.new(type: 'person', name: 'justin', access: 'edit')]).permit! }
    end

    context "without permssions being set" do
      let(:attributes) { {} }
      it { is_expected.to eq ActionController::Parameters.new.permit! }
    end
  end
end
