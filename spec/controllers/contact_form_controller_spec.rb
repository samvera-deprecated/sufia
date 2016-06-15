require 'spec_helper'

describe ContactFormController do
  let(:user) { create(:user) }
  before     { sign_in(user) }

  describe "#new" do
    subject { response }
    before { get :new }
    it { is_expected.to be_success }
  end

  describe "#create" do
    let(:required_params) do
      {
        category: "Depositing content",
        name: "Rose Tyler",
        email: "rose@timetraveler.org",
        subject: "The Doctor",
        message: "Run."
      }
    end

    subject { flash }
    before { post :create, contact_form: params }
    context "with the required parameters" do
      let(:params) { required_params }
      its(:notice) { is_expected.to eq("Thank you for your message!") }
    end

    context "without a category" do
      let(:params)  { required_params.except(:category) }
      its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. Category can't be blank") }
    end

    context "without a name" do
      let(:params)  { required_params.except(:name) }
      its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. Name can't be blank") }
    end

    context "without an email" do
      let(:params)  { required_params.except(:email) }
      its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. Email can't be blank") }
    end

    context "without a subject" do
      let(:params)  { required_params.except(:subject) }
      its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. Subject can't be blank") }
    end

    context "without a message" do
      let(:params)  { required_params.except(:message) }
      its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. Message can't be blank") }
    end

    context "with an invalid email" do
      let(:params)  { required_params.merge(email: "bad-wolf") }
      its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. Email is invalid") }
    end
  end
end
