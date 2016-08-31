describe BatchEditsController, type: :controller do
  let(:user) { create(:user) }
  before do
    sign_in user
    allow_any_instance_of(User).to receive(:groups).and_return([])
    request.env["HTTP_REFERER"] = 'test.host/original_page'
  end

  routes { Internal::Application.routes }

  describe "#edit" do
    let(:one) { create(:work, creator: ["Fred"], title: ["abc"], language: ['en']) }
    let(:two) { create(:work, creator: ["Wilma"], title: ["abc2"], publisher: ['Rand McNally'], language: ['en'], resource_type: ['bar']) }
    before do
      controller.batch = [one.id, two.id]
      expect(controller).to receive(:can?).with(:edit, one.id).and_return(true)
      expect(controller).to receive(:can?).with(:edit, two.id).and_return(true)
    end

    it "is successful" do
      expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.dashboard.title'), Sufia::Engine.routes.url_helpers.dashboard_index_path)
      expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.dashboard.my.works'), Sufia::Engine.routes.url_helpers.dashboard_works_path)
      get :edit
      expect(response).to be_successful
      expect(assigns[:form].model.creator).to match_array ["Fred", "Wilma"]
    end

    it "sets the breadcrumb trail" do
      expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.dashboard.title'), Sufia::Engine.routes.url_helpers.dashboard_index_path)
      expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.dashboard.my.works'), Sufia::Engine.routes.url_helpers.dashboard_works_path)
      get :edit
    end
  end

  describe "update" do
    let!(:one) do
      GenericWork.create(creator: ["Fred"], title: ["abc"], language: ['en']) do |gw|
        gw.apply_depositor_metadata('mjg36')
      end
    end

    let!(:two) do
      GenericWork.create(creator: ["Fred"], title: ["abc"], language: ['en']) do |gw|
        gw.apply_depositor_metadata('mjg36')
      end
    end

    before do
      controller.batch = [one.id, two.id]
      expect(controller).to receive(:can?).with(:edit, one.id).and_return(true)
      expect(controller).to receive(:can?).with(:edit, two.id).and_return(true)
    end

    let(:mycontroller) { "sufia/my/works" }

    it "is successful" do
      put :update, params: { update_type: "delete_all" }
      expect(response).to redirect_to(Sufia::Engine.routes.url_helpers.dashboard_index_path)
      expect { GenericWork.find(one.id) }.to raise_error(Ldp::Gone)
      expect { GenericWork.find(two.id) }.to raise_error(Ldp::Gone)
    end

    it "redirects to the return controller" do
      put :update, params: { update_type: "delete_all", return_controller: mycontroller }
      expect(response).to redirect_to(Sufia::Engine.routes.url_for(controller: mycontroller, only_path: true))
    end

    it "updates the records" do
      put :update, params: { update_type: "update", generic_work: { subject: ["zzz"] } }
      expect(response).to be_redirect
      expect(GenericWork.find(one.id).subject).to eq ["zzz"]
      expect(GenericWork.find(two.id).subject).to eq ["zzz"]
    end

    it "updates permissions" do
      put :update, params: { update_type: "update", visibility: "authenticated" }
      expect(response).to be_redirect
      expect(GenericWork.find(one.id).visibility).to eq "authenticated"
      expect(GenericWork.find(two.id).visibility).to eq "authenticated"
    end
  end
end
