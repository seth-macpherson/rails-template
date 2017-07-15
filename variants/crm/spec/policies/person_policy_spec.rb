require "rails_helper"

RSpec.describe PersonPolicy do
  let(:record) { create(:person) }
  let(:resolved_scope) { described_class::Scope.new(user, Person.all).resolve }
  subject { described_class.new(user, record) }

  it_behaves_like "fully forbidden", nil
  it_behaves_like "readonly for", :guest
  it_behaves_like "full read/write for", :admin

  context "a user on their own person record" do
    let(:user) { create(:user, person: record) }
    it { is_expected.to permit_action :show }
    it { is_expected.to permit_edit_and_update_actions }
  end
end
