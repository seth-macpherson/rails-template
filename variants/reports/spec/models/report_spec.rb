require 'rails_helper'

RSpec.describe Report, type: :model do
  describe 'Concerns' do
    it_behaves_like 'a paranoid model'
    it { is_expected.to be_versioned }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :chart_type }
  end

  describe 'settings=' do
    subject { record.tap { |r| r.settings = value }.settings }
    let(:record) { build :report }
    context 'with valid json in string format' do
      let(:value) { '{ "name": "Report", "hits": 3 }' }
      it 'has no errors' do
        expect(record).to be_valid
      end
      it { is_expected.to be_a Hash }
      it { is_expected.to eq({ name: 'Report', hits: 3 }.stringify_keys) }
    end

    context 'with blank value' do
      let(:value) { '' }
      it { is_expected.to be nil }
      it 'has no errors' do
        expect(record).to be_valid
      end
    end

    context 'with bad json' do
      it 'has errors' do
        record.settings = 'fasdasda'
        expect(record).not_to be_valid
        expect(record.errors.messages).to have_key :settings
        expect(record.errors.full_messages.join).to include "JSON can't be parsed"
      end
    end
  end
end
