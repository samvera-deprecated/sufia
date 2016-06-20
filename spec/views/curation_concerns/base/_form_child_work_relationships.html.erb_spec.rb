require 'spec_helper'

describe "curation_concerns/base/_form_child_work_relationships.html.erb", type: :view do
  let(:work) do
    stub_model(GenericWork, id: '456', title: ["MyWork"])
  end

  let(:work_2) do
    stub_model(GenericWork, id: '567', title: ["Child Work"])
  end

  let(:ability) { double }

  let(:form) do
    CurationConcerns::GenericWorkForm.new(work, ability)
  end

  let(:page) do
    render
    Capybara::Node::Simple.new(rendered)
  end

  before do
    view.lookup_context.view_paths.push 'app/views/curation_concerns'
    allow(view).to receive(:curation_concern).and_return(work)
    allow(view).to receive(:params).and_return(id: work.id)
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    assign(:form, form)
  end

  context "When editing a work" do
    context "and no children works are present" do
      before do
        allow(work).to receive(:members).and_return([])
      end
      it "has 1 empty child work input" do
        expect(page).to have_selector("input[value='']", count: 1)
      end

      it "will not display the remove button in the actions" do
        expect(page).to have_selector(".btn-remove-row", visible: false)
      end

      it "will display the add button in the actions" do
        expect(page).to have_selector(".btn-add-row", visible: true, count: 1)
      end
    end
    context "When 1 child work is present" do
      let(:work_2) do
        stub_model(GenericWork, id: '567', title: ["Test Child Work"])
      end

      before do
        allow(work).to receive(:members).and_return([work_2])
      end
      it "has 1 empty child work input with add button" do
        expect(page).to have_selector("input[value='']", count: 1)
        expect(page).to have_selector(".btn-add-row", visible: true, count: 1)
      end

      it "has an input box that is filled in with the child id" do
        expect(page).to have_selector("input[value='#{work_2.id}']", count: 1)
      end

      it "generates a link for the childs first title" do
        expect(page).to have_link("Test Child Work")
      end

      it "has an edit and remove button" do
        within ".old-row" do
          expect(page).to have_selector(".btn-remove-row", visible: true, count: 1)
          expect(page).to have_selector(".btn-edit-row", visible: true, count: 1)
        end
      end
    end
    context "When multiple child works are present" do
      let(:work_2) do
        stub_model(GenericWork, id: '567', title: ["Test Child Work"])
      end
      let(:work_3) do
        stub_model(GenericWork, id: '789', title: ["Test Child Work 2"])
      end
      before do
        allow(work).to receive(:members).and_return([work_2, work_3])
      end
      it "has 1 empty child work input with add button" do
        expect(page).to have_selector("input[value='']", count: 1)
        expect(page).to have_selector(".btn-add-row", visible: true, count: 1)
      end

      it "has an input box that is filled in with the child ids" do
        expect(page).to have_selector("input[value='#{work_2.id}']", count: 1)
        expect(page).to have_selector("input[value='#{work_3.id}']", count: 1)
      end

      it "generates a link for the childs first title" do
        expect(page).to have_link("Test Child Work")
        expect(page).to have_link("Test Child Work 2")
      end

      it "has an edit and remove button" do
        within ".old-row" do
          expect(page).to have_selector(".btn-remove-row", visible: true, count: 2)
          expect(page).to have_selector(".btn-edit-row", visible: true, count: 2)
        end
      end
    end
  end
end
