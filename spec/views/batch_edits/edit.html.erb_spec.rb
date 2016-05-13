require 'spec_helper'

describe 'batch_edits/edit.html.erb' do
  let(:work) { stub_model(Work, id: nil, depositor: 'bob', rights: ['']) }

  before do
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    assign :names, ['title 1', 'title 2']
    assign :terms, [:description, :rights]
    assign :work, work
    view.lookup_context.view_paths.push "#{CurationConcerns::Engine.root}/app/views/curation_concerns/base"
    render
  end

  it "draws tooltip for description" do
    expect(rendered).to have_selector ".work_description a i.help-icon"
  end
end
