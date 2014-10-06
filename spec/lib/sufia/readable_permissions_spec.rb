require 'spec_helper'

describe Sufia::Permissions::Readable do

  class SubjectClass
    include Sufia::Permissions::Readable
    attr_accessor :read_groups 
  end
  let(:subject) { SubjectClass.new }

  describe "#public?" do
    it "should return true for public items" do
      subject.read_groups = ["public","othergroup"]
      expect(subject).to be_public
    end
    it "should return fale for non-public items" do
      subject.read_groups = ["notpublic","othergroup"]
      expect(subject).to_not be_public
    end
  end

  describe "#registered?" do
    it "should return true for registered items" do
      subject.read_groups = ["registered","othergroup"]
      expect(subject).to be_registered
    end
    it "should return fale for non-registered items" do
      subject.read_groups = ["othergroup"]
      expect(subject).to_not be_registered
    end
  end

  describe "#private?" do
    context "is true" do
      specify "when there are no groups defined" do
        subject.read_groups = []
        expect(subject).to be_private
      end
      specify "when groups do not include 'public' or 'registered'" do
        subject.read_groups = ["othergroup"]
        expect(subject).to be_private
      end
    end
    context "is false" do
      specify "when 'registered' group is present" do
        subject.read_groups = ["registered"]
        expect(subject).to_not be_private
      end
      specify "when 'public' group is present" do
        subject.read_groups = ["public"]
        expect(subject).to_not be_private
      end
    end
  end

end
