require 'spec_helper'

describe Collection, type: :model do
  let(:user1) { FactoryGirl.create(:user) }
  let(:public_collection) { create(:public_collection, title: "public collection", creator: ["creator1"], user: user1) }
  let(:private_collection) { create(:private_collection, title: "private collection", creator: ["creator1"], user: user1) }

  it "has open visibility for public collection" do
    public_collection.save
    expect(public_collection.read_groups).to eq ['public']
  end

  it "has no read visibility for private collection" do
    private_collection.save
    expect(private_collection.read_groups).to eq []
  end

  it "does not allow a collection to be saved without a title" do
    public_collection.title = nil
    expect { public_collection.save! }.to raise_error(ActiveFedora::RecordInvalid)
  end

  describe "::bytes" do
    let(:unsaved_collection) { create(:public_collection, title: "unsaved collection", creator: ["creator1"], user: user1) }
    subject { unsaved_collection.bytes }
    context "with no items" do
      it "gets zero without querying solr" do
        expect(ActiveFedora::SolrService).not_to receive(:query)
        is_expected.to eq 0
      end
    end

    context "with three 33 byte files" do
      let(:bitstream) { double("content", size: "33") }
      let(:file) { mock_model GenericFile, content: bitstream }
      let(:documents) do
        [{ 'id' => 'file-1', 'file_size_is' => 33 },
         { 'id' => 'file-2', 'file_size_is' => 33 },
         { 'id' => 'file-3', 'file_size_is' => 33 }]
      end
      let(:query) { ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: ::GenericFile.to_class_uri) }
      let(:args) do
        { fq: "{!join from=hasCollectionMember_ssim to=id}id:#{unsaved_collection.id}",
          fl: "id, file_size_is",
          rows: 3 }
      end

      before do
        allow(unsaved_collection).to receive(:members).and_return([file, file, file])
        allow(ActiveFedora::SolrService).to receive(:query).with(query, args).and_return(documents)
      end

      context "when saved" do
        before do
          allow(unsaved_collection).to receive(:new_record?).and_return(false)
        end
        it { is_expected.to eq 99 }
      end

      context "when not saved" do
        before do
          allow(unsaved_collection).to receive(:new_record?).and_return(true)
        end
        it "raises an error" do
          expect { subject }.to raise_error "Collection must be saved to query for bytes"
        end
      end
    end
  end

  describe "attributes" do
    it "has a set of permissions" do
      private_collection.read_groups = ['group1', 'group2']
      private_collection.edit_users = ['user1']
      private_collection.read_users = ['user2', 'user3']
      expect(private_collection.permissions.map(&:to_hash)).to match_array [
        { type: "group", access: "read", name: "group1" },
        { type: "group", access: "read", name: "group2" },
        { type: "person", access: "read", name: "user2" },
        { type: "person", access: "read", name: "user3" },
        { type: "person", access: "edit", name: "user1" }]
    end
  end

  context "with access control metadata" do
    subject do
      described_class.new do |m|
        m.apply_depositor_metadata('jcoyne')
        m.permissions_attributes = [{ type: 'person', access: 'read', name: "person1" },
                                    { type: 'person', access: 'read', name: "person2" },
                                    { type: 'group', access: 'read', name: "group-6" },
                                    { type: 'group', access: 'read', name: "group-7" },
                                    { type: 'group', access: 'edit', name: "group-8" }]
      end
    end

    it "has read groups accessor" do
      expect(subject.read_groups).to eq ['group-6', 'group-7']
    end

    it "has read groups string accessor" do
      expect(subject.read_groups_string).to eq 'group-6, group-7'
    end

    it "has read groups writer" do
      subject.read_groups = ['group-2', 'group-3']
      expect(subject.read_groups).to eq ['group-2', 'group-3']
    end

    it "has read groups string writer" do
      subject.read_groups_string = 'umg/up.dlt.staff, group-3'
      expect(subject.read_groups).to eq ['umg/up.dlt.staff', 'group-3']
      expect(subject.edit_groups).to eq ['group-8']
      expect(subject.read_users).to eq ['person1', 'person2']
      expect(subject.edit_users).to eq ['jcoyne']
    end

    it "only revokes eligible groups" do
      subject.set_read_groups(['group-2', 'group-3'], ['group-6'])
      # 'group-7' is not eligible to be revoked
      expect(subject.read_groups).to match_array ['group-2', 'group-3', 'group-7']
      expect(subject.edit_groups).to eq ['group-8']
      expect(subject.read_users).to match_array ['person1', 'person2']
      expect(subject.edit_users).to eq ['jcoyne']
    end
  end

  describe "permissions validation" do
    before do
      subject.apply_depositor_metadata('mjg36')
      subject.title = 'Test Title'
    end

    describe "overriding" do
      let(:asset) { SampleKlass.new }
      before do
        class SampleKlass < GenericFile
          def paranoid_edit_permissions
            []
          end
        end
        asset.apply_depositor_metadata('mjg36')
      end
      after do
        Object.send(:remove_const, :SampleKlass)
      end
      context "when public has edit access" do
        before { asset.edit_groups = ['public'] }
        it "is valid" do
          expect(asset).to be_valid
        end
      end
    end

    context "when the depositor does not have edit access" do
      before do
        subject.permissions = [Hydra::AccessControls::Permission.new(type: 'person', name: 'mjg36', access: 'read')]
      end
      it "is invalid" do
        expect(subject).to_not be_valid
        expect(subject.errors[:edit_users]).to include('Depositor must have edit access')
      end
    end

    context "when the public has edit access" do
      before { subject.edit_groups = ['public'] }

      it "is invalid" do
        expect(subject).to_not be_valid
        expect(subject.errors[:edit_groups]).to include('Public cannot have edit access')
      end
    end

    context "when registered has edit access" do
      before { subject.edit_groups = ['registered'] }

      it "is invalid" do
        expect(subject).to_not be_valid
        expect(subject.errors[:edit_groups]).to include('Registered cannot have edit access')
      end
    end

    context "everything is copacetic" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
