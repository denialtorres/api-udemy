require 'rails_helper'

describe UserAuthenticator::Standard do
  describe "#perform" do
    let(:authenticator) { described_clas.new('jsmith', 'password') }

    subject { authenticator.perform }

    shared_examples_for 'invalid_authentication' do
      before { user }

      it "should raise and error" do
        expect { subject }.to raise_error(UserAuthenticator::Standard::AuthenticationError)
        expect(authenticator.user).to be_nil
      end
    end

    context 'when invalid' do
      let(:user) { create :user, login: 'ddoe', password: 'password'}
      it_behaves_like 'invalid_authentication'
    end

    context 'when invalid password' do
      let(:user) { create :user, login: 'jsmith', password: 'invalidss'}
      it_behaves_like 'invalid_authentication'
    end

    context 'when successed auth' do
    end
  end
end