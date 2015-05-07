require 'spec_helper'

describe Sufia::Works::GenericWork do
  describe "basic metadata" do
    it "should have dc properties" do
      subject.title = ['foo', 'bar']
      expect(subject.title).to eq ['foo', 'bar']
    end
  end

  describe "associations" do
    let(:file) { GenericFile.new.tap {|gf| gf.apply_depositor_metadata("user")} }
    context "base model" do
      subject { Sufia::Works::GenericWork.create(title: ['test'], files: [file]) }

      it "should have many generic files" do
        expect(subject.files).to eq [file]
      end
    end

    context "sub-class" do
      before do
        class TestWork < Sufia::Works::GenericWork
        end
      end

      subject { TestWork.create(title: ['test'], files: [file]) }

      it "should have many generic files" do
        expect(subject.files).to eq [file]
      end
    end
  end

  describe "trophies" do
    before do
      u = FactoryGirl.find_or_create(:jill)
      @w = Sufia::Works::GenericWork.new.tap do |gw|
        gw.apply_depositor_metadata(u)
        gw.save!
      end
      @t = Trophy.create(user_id: u.id, generic_work_id: @w.id)
    end
    it "should have a trophy" do
      expect(Trophy.where(generic_work_id: @w.id).count).to eq 1
    end
    it "should remove all trophies when work is deleted" do
      @w.destroy
      expect(Trophy.where(generic_work_id: @w.id).count).to eq 0
    end
  end

  describe "#destroy", skip: "Is this behavior we need? Could other works be pointing at the file?" do
    let(:file1) { GenericFile.new.tap {|gf| gf.apply_depositor_metadata("user")} }
    let(:file2) { GenericFile.new.tap {|gf| gf.apply_depositor_metadata("user")} }
    let!(:work) { Sufia::Works::GenericWork.create(files: [file1, file2]) }

    it "should destroy the files" do
      expect { work.destroy }.to change{ GenericFile.count }.by(-2)
    end
  end
end

