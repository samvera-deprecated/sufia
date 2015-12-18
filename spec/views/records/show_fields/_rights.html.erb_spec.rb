require 'spec_helper'

describe "records/show_fields/_rights.html.erb" do
  let(:file) { object_double(GenericFile.new) }

  it 'displays links as icons' do
    allow(file).to receive(:[]).with(:rights).and_return(['http://example.org/rights/1'])
    record = Sufia::GenericFilePresenter.new(file)
    render partial: "records/show_fields/rights", locals: { record: record }
    expect(rendered).to include('<a href="http://example.org/rights/1"><i class="glyphicon glyphicon-new-window"></i><br></a>')
  end

  it 'does not display a link for non-urls' do
    allow(file).to receive(:[]).with(:rights).and_return(['all rights reserved'])
    record = Sufia::GenericFilePresenter.new(file)
    render partial: "records/show_fields/rights", locals: { record: record }
    expect(rendered).not_to include('<i class="glyphicon glyphicon-new-window">')
  end
end
