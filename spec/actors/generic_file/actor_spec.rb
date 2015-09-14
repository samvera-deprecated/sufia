require 'spec_helper'

describe Sufia::GenericFile::Actor do
  include ActionDispatch::TestProcess # for fixture_file_upload

  let(:user) { FactoryGirl.create(:user) }
  let(:generic_file) { FactoryGirl.create(:generic_file) }
  let(:actor) { described_class.new(generic_file, user) }
  let(:uploaded_file) { fixture_file_upload('/world.png', 'image/png') }

  describe "#create_content" do
    let(:deposit_message) { double('deposit message') }
    let(:characterize_message) { double('characterize message') }

    it "enqueues deposit and characterize messages" do
      allow(ContentDepositEventJob).to receive(:new).with(generic_file.id, user.user_key).and_return(deposit_message)
      allow(CharacterizeJob).to receive(:new).with(generic_file.id).and_return(characterize_message)
      expect(Sufia.queue).to receive(:push).with(deposit_message)
      expect(Sufia.queue).to receive(:push).with(characterize_message)
      actor.create_content(uploaded_file, 'world.png', 'content', 'image/png')
    end

    context "when generic_file.title is empty and generic_file.label is not" do
      let(:file)       { "world.png" }
      let(:long_name)  { "an absurdly long title that goes on way to long and messes up the display of the page which should not need to be this big in order to show this impossibly long, long, long, oh so long string" }
      let(:short_name) { "Nice Short Name" }
      let(:actor)      { described_class.new(generic_file, user) }
      before do
        allow(generic_file).to receive(:label).and_return(short_name)
        allow(Sufia.queue).to receive(:push)
        actor.create_content(fixture_file_upload(file), long_name, 'content', 'image/png')
      end
      subject { generic_file.title }
      it { is_expected.to eql [short_name] }
    end

    context "with two existing versions from different users" do
      let(:file1)       { "world.png" }
      let(:file2)       { "image.jpg" }
      let(:actor1)      { described_class.new(generic_file, user) }
      let(:actor2)      { described_class.new(generic_file, second_user) }

      let(:second_user) { FactoryGirl.find_or_create(:archivist) }
      let(:versions) { generic_file.content.versions }

      before do
        allow(Sufia.queue).to receive(:push)
        actor1.create_content(fixture_file_upload(file1), file1, 'content', 'image/png')
        actor2.create_content(fixture_file_upload(file2), file2, 'content', 'image/jpeg')
      end

      it "has two versions" do
        expect(versions.all.count).to eq 2
      end

      it "has the current version" do
        expect(generic_file.content.latest_version.label).to eq 'version2'
        expect(generic_file.content.mime_type).to eq "image/jpeg"
        expect(generic_file.content.original_name).to eq file2
      end

      it "uses the first version for the object's title and label" do
        expect(generic_file.label).to eql(file1)
        expect(generic_file.title.first).to eql(file1)
      end

      it "notes the user for each version" do
        expect(VersionCommitter.where(version_id: versions.first.uri).pluck(:committer_login)).to eq [user.user_key]
        expect(VersionCommitter.where(version_id: versions.last.uri).pluck(:committer_login)).to eq [second_user.user_key]
      end
    end

    context "with collection" do
      let(:file)       { "world.png" }
      let(:actor)      { described_class.new(generic_file, user) }
      let(:col_editable) do
        Collection.new(title: 'editable', description: 'user can edit this collection') do |c|
          c.apply_depositor_metadata(user)
        end
      end
      let(:col_editable_id) { col_editable.id }
      let(:col_not_editable) { Collection.new(title: 'not editable', description: 'user cannot edit this collection') }
      let(:col_not_editable_id) { col_not_editable.id }
      before do
        allow(generic_file).to receive(:label).and_return(file)
        allow(col_editable).to receive(:id).and_return('ce')
        allow(Collection).to receive(:find).with(col_editable_id).and_return(col_editable)
        allow(user).to receive(:can?).with(:edit, col_editable).and_return(true)
        allow(col_not_editable).to receive(:id).and_return('cne')
        allow(Collection).to receive(:find).with(col_not_editable_id).and_return(col_not_editable)
        allow(user).to receive(:can?).with(:edit, col_not_editable).and_return(false)
        allow(Sufia.queue).to receive(:push)
      end

      it "adds file to collection when user can edit the collection" do
        actor.create_content(fixture_file_upload(file), file, 'content', 'image/png', col_editable_id)
        updated_collection = Collection.find(col_editable_id)
        expect(updated_collection.member_ids).to eq [generic_file.id]
      end

      it "does not add file to collection when user can NOT edit the collection" do
        actor.create_content(fixture_file_upload(file), file, 'content', 'image/png', col_not_editable_id)
        updated_collection = Collection.find(col_not_editable_id)
        expect(updated_collection.member_ids).to eq []
      end
    end
  end

  describe "#virus_check" do
    it "returns the results of running ClamAV scanfile method" do
      expect(ClamAV.instance).to receive(:scanfile).and_return(1)
      expect { described_class.virus_check(File.new(fixture_path + '/world.png')) }.to raise_error(Sufia::VirusFoundError)
    end
  end

  describe "#featured_work" do
    let(:gf) { FactoryGirl.create(:generic_file, visibility: 'open') }
    let(:actor) { described_class.new(gf, user) }

    before { FeaturedWork.create(generic_file_id: gf.id) }

    it "is removed if document is not public" do
      # Switch document from public to restricted
      expect { actor.update_metadata({}, 'restricted') }.to change { FeaturedWork.count }.by(-1)
    end
  end

  context "when a label is already specified" do
    let(:label)    { "test_file.png" }
    let(:new_file) { "foo.jpg" }
    let(:generic_file_with_label) do
      GenericFile.new.tap do |f|
        f.apply_depositor_metadata(user.user_key)
        f.label = label
      end
    end
    let(:actor) { described_class.new(generic_file_with_label, user) }

    before do
      allow(actor).to receive(:save_characterize_and_record_committer).and_return("true")
      actor.create_content(Tempfile.new(new_file), new_file, "content", 'image/jpg')
    end

    it "will retain the object's original label" do
      expect(generic_file_with_label.label).to eql(label)
    end

    it "will use the new file's name" do
      expect(generic_file_with_label.content.original_name).to eql(new_file)
    end
  end
end
