# frozen_string_literal: true
require "rails_helper"

RSpec.describe "omniauth callbacks", type: :feature do
  let(:provider) { :facebook }

  describe "/users/auth/:provider" do
    context "with failing authentication" do
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[provider] = :invalid_credentials
      end

      it "redirects to login path" do
        visit "/users/auth/#{provider}"
        expect(current_path).to eq new_user_session_path
      end
    end

    context "with a valid and enabled configuration" do
      let(:oauth) { build(:oauth) }

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[provider] = oauth
      end

      let(:user) { create(:user) }

      context "with a valid, known user and identity" do
        before do
          # Ensure the user has an identity record
          # Use the oauth info from the mock so that we find it successfully
          user.find_or_create_identity! oauth
        end

        it "signs-in and redirects" do
          visit "/users/auth/#{provider}"
          expect(current_path).to eq root_path
        end

        it "creates a logged security event", audit_security_events: true do
          ClimateControl.modify AUDIT_SECURITY_EVENTS: "true" do
            user.find_or_create_identity! oauth
            expect {
              visit "/users/auth/#{provider}"
            }.to change(Audit::SecurityEvent, :count).by(1)
          end
        end

        it "uses the 'remember me' feature" do
          expect_any_instance_of(Users::OmniauthCallbacksController)
            .to receive(:remember_me).with(any_args)

          visit "/users/auth/#{provider}"
        end
      end

      context "when receiving a new, unknown user" do
        describe "record creation" do
          subject { -> { visit "/users/auth/#{provider}" } }

          it { is_expected.to change(Identity, :count).by 1 }
          it { is_expected.to change(Person, :count).by 1 }
          it { is_expected.to change(User, :count).by 1 }
        end

        describe "the created user" do
          before { visit "/users/auth/#{provider}" }
          subject { Identity.from_oauth(oauth).user }

          it "has a random password" do
            expect(subject.encrypted_password).not_to be_blank
          end

          it "has the oauth email" do
            expect(subject.email).not_to be_blank
            expect(subject.email).to eq oauth.info.email
          end

          it { is_expected.to have_role :guest }
        end

        describe "the created person" do
          before { visit "/users/auth/#{provider}" }
          subject { Identity.from_oauth(oauth).user.person }

          %w(email name).each do |f|
            it "has the #{f} from oauth" do
              expect(subject.send(f)).to eq oauth.info.send(f)
            end
          end
        end

        describe "the http result" do
          it "directs to the home page" do
            visit "/users/auth/#{provider}"
            expect(page).to have_current_path root_path
          end
        end
      end

      context "a new oauth for a known email" do
        let!(:person) { create(:person, email: oauth.info.email) }

        describe "record creation" do
          subject { -> { visit "/users/auth/#{provider}" } }
          it { is_expected.to change(Identity, :count).by 1 }
          it { is_expected.not_to change(Person, :count) }
          it { is_expected.to change(User, :count).by 1 }
        end

        it "used the existing person record" do
          visit "/users/auth/#{provider}"
          expect(Identity.last.user.person).to eq person
        end
      end
    end
  end
end
