require 'spec_helper'

describe "proxy deposit and transfers routing" do
  routes { Sufia::Engine.routes }

  it "lists transfers" do
    expect(transfers_path).to eq '/dashboard/transfers'
    expect(get: '/dashboard/transfers').to route_to(controller: 'transfers', action: 'index')
  end

  it "creates a transfer" do
    expect(generic_file_transfers_path('7')).to eq '/files/7/transfers'
    expect(post: '/files/7/transfers').to route_to(controller: 'transfers', action: 'create', id: '7')
  end

  it "shows a form for a new transfer" do
    expect(new_generic_file_transfer_path('7')).to eq '/files/7/transfers/new'
    expect(get: '/files/7/transfers/new').to route_to(controller: 'transfers', action: 'new', id: '7')
  end

  it "cancels a transfer" do
    expect(transfer_path('7')).to eq '/dashboard/transfers/7'
    expect(delete: '/dashboard/transfers/7').to route_to(controller: 'transfers', action: 'destroy', id: '7')
  end

  it "accepts a transfers" do
    expect(accept_transfer_path('7')).to eq '/dashboard/transfers/7/accept'
    expect(put: '/dashboard/transfers/7/accept').to route_to(controller: 'transfers', action: 'accept', id: '7')
  end

  it "rejects a transfer" do
    expect(reject_transfer_path('7')).to eq '/dashboard/transfers/7/reject'
    expect(put: '/dashboard/transfers/7/reject').to route_to(controller: 'transfers', action: 'reject', id: '7')
  end

  it "adds a proxy depositor" do
    expect(user_depositors_path('xxx666@example-dot-org')).to eq '/users/xxx666@example-dot-org/depositors'
    expect(post: '/users/xxx666@example-dot-org/depositors').to route_to(controller: 'depositors', action: 'create', user_id: 'xxx666@example-dot-org')
  end

  it "removes a proxy depositor" do
    expect(user_depositor_path('xxx666', '33')).to eq '/users/xxx666/depositors/33'
    expect(delete: '/users/xxx666/depositors/33').to route_to(controller: 'depositors', action: 'destroy', user_id: 'xxx666', id: '33')
  end
end
