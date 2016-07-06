require 'spec_helper'

describe Sufia::Migration::Survey::Item, type: :model do
  it { is_expected.to respond_to(:object_id) }
  it { is_expected.to respond_to(:object_class) }
  it { is_expected.to respond_to(:object_title) }
  it { is_expected.to respond_to(:migration_status) }

  context "with specific values" do
    let(:item) { described_class.create(object_id: "myid", object_class: "MyClass", object_title: "My Title", migration_status: :successful) }
    subject { described_class.find(item.id) }
    it "stores the attributes" do
      expect(subject.object_id).to eq "myid"
      expect(subject.object_class).to eq "MyClass"
      expect(subject.object_title).to eq "My Title"
      expect(subject.successful?).to be_truthy
    end
  end
end
