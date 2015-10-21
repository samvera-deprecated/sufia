require 'spec_helper'

describe API::ItemsController, type: :controller do
  before do
    # Don't test characterization on these items; it breaks TravisCI
    allow_any_instance_of(GenericFile).to receive(:characterize)
  end

  let(:user) { FactoryGirl.find_or_create(:jill) }
  let!(:default_file) do
    GenericFile.create(title: ['Foo Bar']) do |gf|
      gf.apply_depositor_metadata(user)
      gf.arkivo_checksum = '6872d21557992f6ad1d07375f19fbfaf'
    end
  end

  context 'with an HTTP GET or HEAD' do
    before do
      post :create, item, format: :json
    end

    let(:token) { user.arkivo_token }
    let(:item) { FactoryGirl.json(:post_item, token: token) }
    let(:item_hash) { JSON.parse(item) }

    context 'with a missing token' do
      before do
        get :show, format: :json, id: default_file.id
      end

      subject { response }

      it { is_expected.to have_http_status(401) }

      it 'describes the error' do
        expect(subject.body).to include('invalid user token:')
      end
    end

    context 'with an unfamiliar token' do
      before do
        get :show, format: :json, id: default_file.id, token: get_token
      end

      let(:get_token) { 'foobar' }

      subject { response }

      it { is_expected.to have_http_status(401) }

      it 'describes the error' do
        expect(subject.body).to include("invalid user token: #{get_token}")
      end
    end

    context 'with an unauthorized resource' do
      before do
        allow_any_instance_of(User).to receive(:can?).with(:edit, default_file) { false }
        get :show, format: :json, id: default_file.id, token: token
      end

      subject { response }

      it { is_expected.to have_http_status(401) }

      it 'loads the file' do
        expect(assigns[:file]).to eq default_file
      end

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("#{user} lacks access to #{default_file}")
      end
    end

    context 'with a resource not deposited via Arkivo' do
      before do
        allow_any_instance_of(GenericFile).to receive(:arkivo_checksum) { nil }
        get :show, format: :json, id: default_file.id, token: token
      end

      subject { response }

      it { is_expected.to have_http_status(403) }

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("Forbidden: #{default_file} not deposited via Arkivo")
      end
    end

    context 'with a resource not found in the repository' do
      before do
        allow(GenericFile).to receive(:find).with(default_file.id).and_raise(ActiveFedora::ObjectNotFoundError)
        get :show, format: :json, id: default_file.id, token: token
      end

      subject { response }

      it { is_expected.to have_http_status(404) }

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("id '#{default_file.id}' not found")
      end
    end

    context 'with an authorized Arkivo-deposited resource' do
      before do
        get :show, format: :json, id: default_file.id, token: token
      end

      subject { response }

      it { is_expected.to have_http_status(204) }

      it 'responds with no body' do
        expect(subject.body).to be_blank
      end
    end
  end

  context 'with an HTTP POST' do
    context 'without an item' do
      before do
        post :create, format: :json
      end

      subject { response }

      it { is_expected.to have_http_status(400) }

      it 'describes the error' do
        expect(subject.body).to include('no item parameter')
      end
    end

    context 'with an invalid item' do
      before do
        post :create, item, format: :json
      end

      let(:item) { { foo: 'bar' }.to_json }

      subject { response }

      it { is_expected.to have_http_status(400) }

      it 'describes the error' do
        expect(subject.body).to include('The property \'#/\' did not contain a required property of \'token\'')
      end
    end

    context 'with a valid item and matching token' do
      before do
        expect { post :create, item, format: :json }.to change { GenericFile.count }.by(1)
      end

      let!(:deposited_file) { GenericFile.where(label: item_hash['file']['filename']).take }
      let(:token) { user.arkivo_token }
      let(:item) { FactoryGirl.json(:post_item, token: token) }
      let(:item_hash) { JSON.parse(item) }

      subject { response }

      it { is_expected.to be_success }

      it 'responds with HTTP 201' do
        expect(response.status).to eq 201
      end

      it 'provides a URI in the Location header' do
        expect(response.headers['Location']).to match %r{/api/items/.{9}}
      end

      it 'creates a new item via POST' do
        expect(deposited_file).not_to be_nil
      end

      it 'writes metadata to allow flagging Arkivo-deposited items' do
        expect(deposited_file.arkivo_checksum).to eq item_hash['file']['md5']
      end

      it 'writes content' do
        expect(deposited_file.content.content).to eq "arkivo\n"
      end

      it 'batch applies specified metadata' do
        expect(deposited_file.resource_type).to eq [item_hash['metadata']['resourceType']]
        expect(deposited_file.title).to eq [item_hash['metadata']['title']]
        expect(deposited_file.description).to eq [item_hash['metadata']['description']]
        expect(deposited_file.publisher).to eq [item_hash['metadata']['publisher']]
        expect(deposited_file.date_created).to eq [item_hash['metadata']['dateCreated']]
        expect(deposited_file.based_near).to eq [item_hash['metadata']['basedNear']]
        expect(deposited_file.identifier).to eq [item_hash['metadata']['identifier']]
        expect(deposited_file.related_url).to eq [item_hash['metadata']['url']]
        expect(deposited_file.language).to eq [item_hash['metadata']['language']]
        expect(deposited_file.rights).to eq [item_hash['metadata']['rights']]
        expect(deposited_file.tag).to eq item_hash['metadata']['tags']
        expect(deposited_file.creator).to eq ['Doe, John', 'Babs McGee']
        expect(deposited_file.contributor).to eq ['Nadal, Rafael', 'Jane Doeski']
      end
    end

    context 'with a valid item and unfamiliar token' do
      before do
        post :create, item, format: :json
      end

      let(:token) { 'unfamiliar_token' }
      let(:item) { FactoryGirl.json(:post_item, token: token) }

      subject { response }

      it { is_expected.not_to be_success }

      it 'responds with HTTP 401' do
        expect(subject.status).to eq 401
      end

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("invalid user token: #{token}")
      end
    end
  end

  context 'with an HTTP PUT' do
    let(:post_deposited_file) { GenericFile.where(label: post_item_hash['file']['filename']).take }
    let(:post_token) { user.arkivo_token }
    let(:post_item) { FactoryGirl.json(:post_item, token: post_token) }
    let(:post_item_hash) { JSON.parse(post_item) }

    before do
      expect { post :create, post_item, format: :json }.to change { GenericFile.count }.by(1)
    end

    context 'with a valid item, matching token, and authorized resource' do
      before do
        put :update, put_item, id: post_deposited_file.id, format: :json
      end

      let(:put_deposited_file) { post_deposited_file.reload }
      let(:put_token) { user.arkivo_token }
      let(:put_item) { FactoryGirl.json(:put_item, token: put_token) }
      let(:put_item_hash) { JSON.parse(put_item) }

      subject { response }

      it { is_expected.to be_success }

      it 'responds with HTTP 204 and no body' do
        expect(subject.status).to eq 204
        expect(subject.body).to be_blank
      end

      it 'updates metadata to allow flagging Arkivo-deposited items' do
        expect(put_deposited_file.arkivo_checksum).to eq put_item_hash['file']['md5']
      end

      it 'changes the file content' do
        expect(put_deposited_file.content.content).to eq "# HEADER\n\nThis is a paragraph!\n"
      end

      it 'changes the metadata' do
        expect(put_deposited_file.resource_type).to eq [put_item_hash['metadata']['resourceType']]
        expect(put_deposited_file.title).to eq [put_item_hash['metadata']['title']]
        expect(put_deposited_file.rights).to eq [put_item_hash['metadata']['rights']]
        expect(put_deposited_file.tag).to eq put_item_hash['metadata']['tags']
        expect(put_deposited_file.creator).to eq ['Doe, John', 'Babs McGee']
        expect(put_deposited_file.description).to eq []
        expect(put_deposited_file.publisher).to eq []
        expect(put_deposited_file.date_created).to eq []
        expect(put_deposited_file.based_near).to eq []
        expect(put_deposited_file.identifier).to eq []
        expect(put_deposited_file.related_url).to eq []
        expect(put_deposited_file.language).to eq []
        expect(put_deposited_file.contributor).to eq []
      end
    end

    context 'with a valid item, matching token, authorized resource, but not Arkivo-deposited' do
      before do
        allow_any_instance_of(GenericFile).to receive(:arkivo_checksum) { nil }
        put :update, item, id: post_deposited_file.id, format: :json
      end

      let(:item) { FactoryGirl.json(:put_item, token: post_token) }

      subject { response }

      it { is_expected.not_to be_success }

      it 'responds with HTTP 403' do
        expect(subject.status).to eq 403
      end

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("Forbidden: #{post_deposited_file} not deposited via Arkivo")
      end
    end

    context 'with a valid item, matching token, missing resource' do
      before do
        allow(GenericFile).to receive(:find).with(post_deposited_file.id) do
          raise(ActiveFedora::ObjectNotFoundError)
        end
        put :update, item, id: post_deposited_file.id, format: :json
      end

      subject { response }
      let(:item) { FactoryGirl.json(:put_item, token: post_token) }

      it { is_expected.to have_http_status(404) }

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("id '#{post_deposited_file.id}' not found")
      end
    end

    context 'with a valid item, matching token, and unauthorized resource' do
      before do
        allow_any_instance_of(User).to receive(:can?).with(:edit, post_deposited_file) { false }
        put :update, item, id: post_deposited_file.id, format: :json
      end

      let(:item) { FactoryGirl.json(:put_item, token: post_token) }

      subject { response }

      it { is_expected.not_to be_success }

      it 'loads the file' do
        expect(assigns[:file]).to eq post_deposited_file
      end

      it 'responds with HTTP 401' do
        expect(subject.status).to eq 401
      end

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("#{user} lacks access to #{post_deposited_file}")
      end
    end

    context 'with a valid item and unfamiliar token' do
      before do
        put :update, item, id: post_deposited_file.id, format: :json
      end

      let(:token) { 'unfamiliar_token' }
      let(:item) { FactoryGirl.json(:put_item, token: token) }

      subject { response }

      it { is_expected.not_to be_success }

      it 'responds with HTTP 401' do
        expect(subject.status).to eq 401
      end

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("invalid user token: #{token}")
      end
    end

    context 'with an invalid item' do
      before do
        put :update, item, id: post_deposited_file.id, format: :json
      end

      let(:item) { { foo: 'bar' }.to_json }

      subject { response }

      it { is_expected.to have_http_status(400) }

      it 'describes the error' do
        expect(subject.body).to include('The property \'#/\' did not contain a required property of \'token\'')
      end
    end
  end

  context 'with an HTTP DELETE' do
    before do
      post :create, item, format: :json
    end

    let(:token) { user.arkivo_token }
    let(:item) { FactoryGirl.json(:post_item, token: token) }
    let(:item_hash) { JSON.parse(item) }

    context 'with a missing token' do
      before do
        delete :destroy, format: :json, id: default_file.id
      end

      subject { response }

      it { is_expected.to have_http_status(401) }

      it 'describes the error' do
        expect(subject.body).to include('invalid user token:')
      end
    end

    context 'with an unfamiliar token' do
      before do
        delete :destroy, format: :json, id: default_file.id, token: delete_token
      end

      let(:delete_token) { 'foobar' }

      subject { response }

      it { is_expected.to have_http_status(401) }

      it 'describes the error' do
        expect(subject.body).to include("invalid user token: #{delete_token}")
      end
    end

    context 'with an unauthorized resource' do
      before do
        allow_any_instance_of(User).to receive(:can?).with(:edit, default_file) { false }
        delete :destroy, format: :json, id: default_file.id, token: token
      end

      subject { response }

      it { is_expected.to have_http_status(401) }

      it 'loads the file' do
        expect(assigns[:file]).to eq default_file
      end

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("#{user} lacks access to #{default_file}")
      end
    end

    context 'with a resource not deposited via Arkivo' do
      before do
        allow_any_instance_of(GenericFile).to receive(:arkivo_checksum) { nil }
        delete :destroy, format: :json, id: default_file.id, token: token
      end

      subject { response }

      it { is_expected.to have_http_status(403) }

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("Forbidden: #{default_file} not deposited via Arkivo")
      end
    end

    context 'with a resource not found in the repository' do
      before do
        allow(GenericFile).to receive(:find).with(default_file.id).and_raise(ActiveFedora::ObjectNotFoundError)
        delete :destroy, format: :json, id: default_file.id, token: token
      end

      subject { response }

      it { is_expected.to have_http_status(404) }

      it 'provides a reason for refusing to act' do
        expect(subject.body).to include("id '#{default_file.id}' not found")
      end
    end

    context 'with an authorized Arkivo-deposited resource' do
      before do
        expect { delete :destroy, format: :json, id: default_file.id, token: token }.to change { GenericFile.count }.by(-1)
      end

      subject { response }

      it { is_expected.to have_http_status(204) }

      it 'responds with no body' do
        expect(subject.body).to be_blank
      end
    end
  end
end
