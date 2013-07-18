require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe GenericFile do
  before do
    subject.apply_depositor_metadata('jcoyne')
  end

  describe "terms_for_editing" do
    it "should return a list" do
      subject.terms_for_editing.should == [:resource_type, :title, :creator, :contributor, :description, :tag, 
                    :rights, :publisher, :date_created, :subject, :language, :identifier, :based_near, :related_url]
    end
  end
  describe "terms_for_display" do
    it "should return a list" do
      subject.terms_for_display.should == [:part_of, :resource_type, :title, :creator, :contributor, :description, 
        :tag, :rights, :publisher, :date_created, :date_uploaded, :date_modified, :subject, :language, :identifier, 
        :based_near, :related_url]
    end
  end

  describe "accessible_attributes" do
    it "should have a list" do
      subject.accessible_attributes.should == [:part_of, :resource_type, :title, :creator, :contributor, :description, 
        :tag, :rights, :publisher, :date_created, :date_uploaded, :date_modified, :subject, :language, :identifier, 
        :based_near, :related_url, :permissions]
    end

    it "should sanitize them" do
      subject.sanitize_attributes({'part_of' => 'A book', 'something_crazy' => "get's thrown out"}).should ==
        {'part_of' => 'A book'}
    end
  end
end
