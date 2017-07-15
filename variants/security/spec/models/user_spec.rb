require "rails_helper"

RSpec.describe User, type: :model do
  describe "Concerns" do
    it_behaves_like "a paranoid model"
    it { is_expected.to be_versioned }
  end

  describe "Associations" do
    it { is_expected.to belong_to :person }
    it { is_expected.to have_many(:identities).dependent(:destroy) }
    it { is_expected.to have_many(:security_events) }
  end

  describe "Validations" do
    subject { build(:user) }
    it { is_expected.to validate_presence_of :person }
    it { is_expected.to validate_uniqueness_of :person }
  end

  describe "#find_or_create_identity!" do
    context "with new identity" do
      before(:all) do
        @oauth = build(:oauth)
        @user = create(described_class.model_name.element.to_sym)
        @ident = @user.find_or_create_identity! @oauth
      end

      describe "identity" do
        subject { @ident }
        it { is_expected.to be_an Identity }
        it { is_expected.to be_persisted }
      end

      describe "ident.user" do
        subject { @ident.user }
        it { is_expected.to eq @user }
      end

      after(:all) do
        @ident.destroy!
      end
    end
  end

  describe "#active_for_authentication?" do
    let(:user) { build :user, disabled: disabled }
    subject { user.active_for_authentication? }

    context "an active user" do
      let(:disabled) { false }
      it { is_expected.to be true }
    end

    context "a disabled user" do
      let(:disabled) { true }
      it { is_expected.to be false }
    end
  end

  describe ".find_for_authentication" do
    let(:user) { create :user, disabled: disabled }
    subject { described_class.find_for_authentication(email: user.email) }

    context "a normal user" do
      let(:disabled) { false }
      it { is_expected.to eq user }
    end

    context "a disabled user" do
      let(:disabled) { true }
      it { is_expected.to eq nil }
    end
  end

  describe "#any_role?" do
    subject { user.any_role? roles }
    context "an admin" do
      let(:user) { create(:user, :admin) }
      context ":admin" do
        let(:roles) { :admin }
        it { is_expected.to be true }
      end

      context ":admin, :bogus" do
        let(:roles) { %i(admin bogus) }
        it { is_expected.to be true }
      end

      context ":bogus" do
        let(:roles) { :bogus }
        it { is_expected.to be false }
      end
    end
  end

  describe "#to_s" do
    let(:user) { create(described_class.model_name.element.to_sym) }
    subject { user.to_s }
    it { is_expected.to include user.person.email }
    it { is_expected.to include user.roles.pluck(:name).map(&:titleize).join(", ") }
  end

  describe "auto-elevation based on email" do
    let(:user) { create(:user, email: email) }
    subject { user.has_role? :superuser }

    context "a webgents email" do
      let(:email) { "#{Faker::Internet.unique.user_name}@webgents.dk" }
      it { is_expected.to be true }
    end

    context "a non-webgents email" do
      let(:email) { Faker::Internet.unique.free_email }
      it { is_expected.to be false }
    end
  end
end
