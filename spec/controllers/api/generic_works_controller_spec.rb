describe API::GenericWorksController, type: :controller do
  let(:actor) { CurationConcerns::CurationConcern.actor(default_work, user) }

  before do
    # Mock Actor
    allow(controller).to receive(:actor).and_return(actor)
  end

  let!(:user) { create(:user) }
  let!(:default_work) do
    GenericWork.create(title: ['Child Foo Bar']) do |gf|
      gf.apply_depositor_metadata(user)
    end
  end

  let!(:parent_work) do
    GenericWork.create(title: ['Parent Foo Bar']) do |gf|
      gf.apply_depositor_metadata(user)
    end
  end

  subject { response }

  context 'with an HTTP GET or HEAD' do
    context 'with an unauthorized resource' do
      before do
        allow_any_instance_of(User).to receive(:can?).with(:edit, default_work) { false }
      end

      context 'add_parent with an unauthorized resource' do
        before do
          get :add_parent, format: :json, id: default_work.id, parent_id: parent_work.id
        end
        it 'is unauthorized' do
          expect(subject).to have_http_status(401)
          expect(assigns[:work]).to eq default_work
          expect(subject.body).to include("#{user} lacks access to #{default_work}")
        end
      end

      context 'remove_parent with an unauthorized resource' do
        before do
          get :remove_parent, format: :json, id: default_work.id, parent_id: parent_work.id
        end
        it 'is unauthorized' do
          expect(subject).to have_http_status(401)
          expect(assigns[:work]).to eq default_work
          expect(subject.body).to include("#{user} lacks access to #{default_work}")
        end
      end
    end

    context 'add_parent with an authorized resource' do
      before do
        get :add_parent, format: :json, id: default_work.id, parent_id: parent_work.id
      end

      let(:results) do {
        parent: {
          title: ['Parent Foo Bar'],
          path: "/concern/generic_works/#{parent_work.id}",
          id: parent_work.id
        },
        child: {
          title: ['Child Foo Bar'],
          path: "/concern/generic_works/#{default_work.id}",
          id: default_work.id
        }
      }.to_json
      end

      specify do
        expect(subject).to have_http_status(200)
        expect(subject.body).to eq results
        expect(default_work.in_works_ids).to eq [parent_work.id]
      end
    end

    context 'add_parent with a resource not found in the repository' do
      context 'when a child is not found' do
        before do
          allow(GenericWork).to receive(:find).with(default_work.id).and_raise(ActiveFedora::ObjectNotFoundError)
          get :add_parent, format: :json, id: default_work.id, parent_id: parent_work.id
        end

        it "is not found" do
          expect(subject).to have_http_status(404)
          expect(subject.body).to include("id '#{default_work.id}' not found")
        end
      end
      context 'when a parent is not found' do
        before do
          allow(controller).to receive(:my_load_parent_resource).and_raise(ActiveFedora::ObjectNotFoundError)
          get :add_parent, format: :json, id: default_work.id, parent_id: parent_work.id
        end

        it "is not found" do
          expect(subject).to have_http_status(404)
        end
      end
    end

    context 'remove_parent with an authorized resource' do
      before do
        get :remove_parent, format: :json, id: default_work.id, parent_id: parent_work.id
      end

      specify do
        expect(subject).to have_http_status(204)
        expect(subject.body).to be_blank
        expect(default_work.in_works_ids).to eq []
      end
    end

    context 'remove_parent with a resource not found in the repository' do
      context 'when a child is not found' do
        before do
          allow(GenericWork).to receive(:find).with(default_work.id).and_raise(ActiveFedora::ObjectNotFoundError)
          get :remove_parent, format: :json, id: default_work.id, parent_id: parent_work.id
        end

        it "is not found" do
          expect(subject).to have_http_status(404)
          expect(subject.body).to include("id '#{default_work.id}' not found")
        end
      end
    end
  end
end
