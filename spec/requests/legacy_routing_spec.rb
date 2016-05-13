require 'spec_helper'

describe 'Legacy GenericFile routes' do
  it 'redirects to the work' do
    get '/files/gm80hv36p'
    expect(response).to redirect_to("/concern/works/gm80hv36p")
    expect(response.code).to eq '301' # Moved Permanently
  end
end
