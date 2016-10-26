describe StatsController do
  let(:user) { create(:user) }
  before do
    allow_any_instance_of(User).to receive(:groups).and_return([])
  end
  routes { Sufia::Engine.routes }
  let(:usage) { double }

  describe '#file' do
    let(:file_set) { create(:file_set, user: user) }
    context 'when user has access to file' do
      before do
        sign_in user
        request.env['HTTP_REFERER'] = 'http://test.host/foo'
      end

      it 'renders the stats view' do
        expect(Sufia::FileUsage).to receive(:new).with(file_set.id).and_return(usage)
        expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.dashboard.title'), Sufia::Engine.routes.url_helpers.dashboard_index_path(locale: 'en'))
        expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.dashboard.my.works'), Sufia::Engine.routes.url_helpers.dashboard_works_path(locale: 'en'))
        expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.file_set.browse_view'), Rails.application.routes.url_helpers.curation_concerns_file_set_path(file_set, locale: 'en'))
        get :file, params: { id: file_set }
        expect(response).to be_success
        expect(response).to render_template('stats/file')
      end
    end

    context "user is not signed in but the file is public" do
      let(:file_set) { create(:file_set, :public, user: user) }

      it 'renders the stats view' do
        get :file, params: { id: file_set }
        expect(response).to be_success
        expect(response).to render_template('stats/file')
      end
    end

    context 'when user lacks access to file' do
      let(:file_set) { create(:file_set) }
      before do
        sign_in user
      end

      it 'redirects to root_url' do
        get :file, params: { id: file_set }
        expect(response).to redirect_to(Sufia::Engine.routes.url_helpers.root_path(locale: 'en'))
      end
    end
  end

  describe 'work' do
    let(:work) { create(:generic_work, user: user) }
    before do
      sign_in user
      request.env['HTTP_REFERER'] = 'http://test.host/foo'
    end

    it 'renders the stats view' do
      expect(Sufia::WorkUsage).to receive(:new).with(work.id).and_return(usage)
      expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.dashboard.my.works'), Sufia::Engine.routes.url_helpers.dashboard_works_path(locale: 'en'))
      expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.dashboard.title'), Sufia::Engine.routes.url_helpers.dashboard_index_path(locale: 'en'))
      expect(controller).to receive(:add_breadcrumb).with(I18n.t('sufia.work.browse_view'), main_app.curation_concerns_generic_work_path(work, locale: 'en'))
      get :work, params: { id: work }
      expect(response).to be_success
      expect(response).to render_template('stats/work')
    end
  end
end
