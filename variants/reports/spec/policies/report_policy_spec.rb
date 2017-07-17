require 'rails_helper'

RSpec.describe ReportPolicy do
  let(:record) { create(:report, published: true) }
  let(:resolved_scope) { described_class::Scope.new(user, Report.all).resolve }
  subject { described_class.new(user, record) }

  it_behaves_like 'fully forbidden', nil
  it_behaves_like 'readonly for', :guest
  it_behaves_like 'full read/write for', :admin

  context 'unpublished report' do
    let(:record) { build :report, published: false }

    context 'guest user' do
      let(:user) { build :user, :guest }
      it { is_expected.not_to permit_action :show }
      it 'is not included in scope' do
        expect(resolved_scope).not_to include record
      end
    end
  end
end
