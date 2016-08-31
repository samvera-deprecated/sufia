describe 'Routes', type: :routing do
  routes { Sufia::Engine.routes }

  describe "ResourceSync" do
    it 'routes the well-known uri' do
      expect(get: '/.well-known/resourcesync').to route_to(controller: 'sufia/resource_sync', action: 'source_description')
    end

    it 'routes the capability list' do
      expect(get: '/capabilitylist').to route_to(controller: 'sufia/resource_sync', action: 'capability_list')
    end

    it 'routes the resource list' do
      expect(get: '/resourcelist').to route_to(controller: 'sufia/resource_sync', action: 'resource_list')
    end
  end

  describe "Features" do
    it "routes to the features controller" do
      expect(get: '/admin/features').to route_to(controller: 'sufia/admin/features', action: 'index')
    end

    it "routes to the strategies controller" do
      expect(patch: '/admin/features/foo/strategies/bar').to route_to(controller: 'sufia/admin/strategies', action: 'update', id: 'bar', feature_id: 'foo')
    end
  end

  describe 'Homepage' do
    it 'routes the root url to the homepage controller' do
      expect(get: '/').to route_to(controller: 'sufia/homepage', action: 'index')
    end
  end

  describe 'Admin' do
    it 'routes the admin dashboard' do
      expect(get: '/admin').to route_to(controller: 'sufia/admin', action: 'show')
    end
    it 'routes the statistics page' do
      expect(get: '/admin/stats').to route_to(controller: 'sufia/admin/stats', action: 'show')
    end
  end

  describe "Audit" do
    it 'routes to audit' do
      expect(post: '/concern/file_sets/7/audit').to route_to(controller: 'sufia/audits', action: 'create', file_set_id: '7')
    end
  end

  describe "BatchUpload" do
    context "without a batch" do
      routes { Sufia::Engine.routes }
      it 'routes to create' do
        expect(post: '/batch_uploads').to route_to(controller: 'sufia/batch_uploads', action: 'create')
      end

      it "routes to new" do
        expect(get: '/batch_uploads/new').to route_to(controller: 'sufia/batch_uploads', action: 'new')
      end
    end
  end

  describe 'FileSet' do
    context "main app routes" do
      routes { Rails.application.routes }

      context "with a file_set" do
        it 'routes to create' do
          expect(post: '/concern/container/12/file_sets').to route_to(controller: 'curation_concerns/file_sets', action: 'create', parent_id: '12')
        end

        it 'routes to new' do
          expect(get: '/concern/container/12/file_sets/new').to route_to(controller: 'curation_concerns/file_sets', action: 'new', parent_id: '12')
        end
      end

      it 'routes to edit' do
        expect(get: '/concern/file_sets/3/edit').to route_to(controller: 'curation_concerns/file_sets', action: 'edit', id: '3')
      end

      it "routes to show" do
        expect(get: '/concern/file_sets/4').to route_to(controller: 'curation_concerns/file_sets', action: 'show', id: '4')
      end

      it "routes to update" do
        expect(put: '/concern/file_sets/5').to route_to(controller: 'curation_concerns/file_sets', action: 'update', id: '5')
      end

      it "routes to destroy" do
        expect(delete: '/concern/file_sets/6').to route_to(controller: 'curation_concerns/file_sets', action: 'destroy', id: '6')
      end

      it "doesn't route to index" do
        expect(get: '/concern/file_sets').not_to route_to(controller: 'curation_concerns/file_sets', action: 'index')
      end
    end
  end

  describe 'Download' do
    routes { Rails.application.routes }
    it "routes to show" do
      expect(get: '/downloads/9').to route_to(controller: 'downloads', action: 'show', id: '9')
    end
  end

  describe 'Dashboard' do
    it "routes to dashboard" do
      expect(get: '/dashboard').to route_to(controller: 'sufia/dashboard', action: 'index')
    end

    it "routes to dashboard activity" do
      expect(get: '/dashboard/activity').to route_to(controller: 'sufia/dashboard', action: 'activity')
    end

    it "routes to my works tab" do
      expect(get: '/dashboard/works').to route_to(controller: 'sufia/my/works', action: 'index')
    end

    it "routes to my collections tab" do
      expect(get: '/dashboard/collections').to route_to(controller: 'sufia/my/collections', action: 'index')
    end

    it "routes to my highlighted tab" do
      expect(get: '/dashboard/highlights').to route_to(controller: 'sufia/my/highlights', action: 'index')
    end

    it "routes to my shared tab" do
      expect(get: '/dashboard/shares').to route_to(controller: 'sufia/my/shares', action: 'index')
    end
  end

  describe 'Trophies' do
    it 'routes to user trophies' do
      expect(post: '/works/1234abc/trophy').to route_to(controller: 'sufia/trophies', action: 'toggle_trophy', id: '1234abc')
    end
  end

  describe 'Users' do
    it 'routes to user profile' do
      expect(get: '/users/bob135').to route_to(controller: 'sufia/users', action: 'show', id: 'bob135')
    end

    it "routes to edit profile" do
      expect(get: '/users/bob135/edit').to route_to(controller: 'sufia/users', action: 'edit', id: 'bob135')
    end

    it "routes to update profile" do
      expect(put: '/users/bob135').to route_to(controller: 'sufia/users', action: 'update', id: 'bob135')
    end

    it "routes to user follow" do
      expect(post: '/users/bob135/follow').to route_to(controller: 'sufia/users', action: 'follow', id: 'bob135')
    end

    it "routes to user unfollow" do
      expect(post: '/users/bob135/unfollow').to route_to(controller: 'sufia/users', action: 'unfollow', id: 'bob135')
    end
  end

  describe "Notifications" do
    it "has index" do
      expect(get: '/notifications').to route_to(controller: 'sufia/mailbox', action: 'index')
      expect(notifications_path).to eq '/notifications'
    end
    it "allows deleting" do
      expect(delete: '/notifications/123').to route_to(controller: 'sufia/mailbox', action: 'destroy', id: '123')
      expect(notification_path(123)).to eq '/notifications/123'
    end
    it "allows deleting all of them" do
      expect(delete: '/notifications/delete_all').to route_to(controller: 'sufia/mailbox', action: 'delete_all')
      expect(delete_all_notifications_path).to eq '/notifications/delete_all'
    end
  end

  describe "Contact Form" do
    it "routes to new" do
      expect(get: '/contact').to route_to(controller: 'sufia/contact_form', action: 'new')
    end

    it "routes to create" do
      expect(post: '/contact').to route_to(controller: 'sufia/contact_form', action: 'create')
    end
  end

  describe "Dynamically edited pages" do
    it "routes to about" do
      expect(get: '/about').to route_to(controller: 'sufia/pages', action: 'show', id: 'about_page')
    end
  end

  describe "Static Pages" do
    it "routes to help" do
      expect(get: '/help').to route_to(controller: 'sufia/static', action: 'help')
    end

    it "routes to terms" do
      expect(get: '/terms').to route_to(controller: 'sufia/static', action: 'terms')
    end

    it "routes to zotero" do
      expect(get: '/zotero').to route_to(controller: 'sufia/static', action: 'zotero')
    end

    it "routes to mendeley" do
      expect(get: '/mendeley').to route_to(controller: 'sufia/static', action: 'mendeley')
    end

    it "routes to versions" do
      expect(get: '/versions').to route_to(controller: 'sufia/static', action: 'versions')
    end

    it "*not*s route a bogus static page" do
      expect(get: '/awesome').not_to route_to(controller: 'sufia/static', action: 'awesome')
    end
  end

  describe 'main app routes' do
    routes { Rails.application.routes }

    describe 'GenericWork' do
      it "routes to show" do
        expect(get: '/concern/generic_works/4').to route_to(controller: 'curation_concerns/generic_works', action: 'show', id: '4')
      end
    end
  end
end
