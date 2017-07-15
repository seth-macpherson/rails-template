require 'rails_helper'

RSpec.describe Person, type: :model do
  describe 'Concerns' do
    it_behaves_like 'a paranoid model'
    it { is_expected.to be_versioned }
  end

  describe 'Associations' do
    it { is_expected.to have_one(:user) }
  end

  describe 'Validations' do
    subject { create(:person) }
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive.allow_nil }
  end

  describe '#valid?' do
    subject { build(:person) }

    it 'is valid when duplicating email address on a deleted record' do
      person = create(:person)
      person.destroy!
      expect(person).to be_deleted

      expect(build(:person, email: person.email)).to be_valid
    end
  end

  describe '#age' do
    let(:person) { build :person, born_on: born_on }
    subject { person.age }

    context 'no born_on' do
      let(:born_on) { nil }
      it { is_expected.to be nil }
    end

    context 'born 18 years ago' do
      let(:born_on) { 18.years.ago }
      it { is_expected.to eq 18 }
    end

    context 'birthday is tomorrow' do
      let(:born_on) { 18.years.ago + 1.day }
      it { is_expected.to eq 17 }
    end

    context 'birthday was yesterday' do
      let(:born_on) { 18.years.ago - 1.day }
      it { is_expected.to eq 18 }
    end
  end

  describe '#birthday_today?' do
    let(:person) { build :person, born_on: born_on }
    subject { person.birthday_today? }

    context 'birthday is blank' do
      let(:born_on) { nil }
      it { is_expected.to be false }
    end

    context 'birthday was yesterday' do
      let(:born_on) { 30.years.ago - 1.day }
      it { is_expected.to be false }
    end

    context 'birthday is today' do
      let(:born_on) { 30.years.ago }
      it { is_expected.to be true }
    end

    context 'birthday is tomorrow' do
      let(:born_on) { 30.years.ago + 1.day }
      it { is_expected.to be false }
    end
  end

  describe '#email=' do
    context 'when sending mixed case value' do
      it 'downcases email' do
        person = build(:person, email: 'USER1@example.org')
        expect(person.email).to eq 'user1@example.org'
      end
    end
    context 'when sending value with extraneous whitespace' do
      it 'strips' do
        person = build(:person, email: 'user1@example.org ')
        expect(person.email).to eq 'user1@example.org'
      end
    end
    context 'when sending nil' do
      it 'saves nil' do
        person = build(:person)
        person.email = nil
        expect(person.email).to be_nil
      end
    end

    it 'updates the email on the user'
  end

  describe '#name' do
    context 'with first and last name' do
      let(:person) { build(:person) }
      subject { person.name }

      it { is_expected.not_to be_blank }
      it { is_expected.to include person.first_name }
      it { is_expected.to include person.last_name }
    end

    context 'with last name only' do
      it 'has last name and no whitespace' do
        person = build(:person, first_name: nil)
        expect(person.name).not_to match(/^\s+/)
        expect(person.name).to eq person.last_name
      end
    end

    context 'with nil' do
      it 'sets first_name and last_name to nil' do
        person = build(:person)
        person.name = nil
        expect(person.first_name).to be nil
        expect(person.last_name).to be nil
      end
    end
  end

  describe '#name=' do
    context 'with a single word first and last name' do
      it 'splits into first_name and last_name' do
        p = Person.new name: 'Kathryn Janeway'
        expect(p.first_name).to eq 'Kathryn'
        expect(p.last_name).to eq 'Janeway'
      end
    end

    context 'with just a single part name' do
      it 'leaves last_name blank and populates first_name' do
        p = Person.new name: 'Robert'
        expect(p.first_name).to eq 'Robert'
        expect(p.last_name).to be_nil
      end
    end

    context 'with a multi-word name' do
      it 'assigns first and last name' do
        p = Person.new name: 'Serena van der Woodsen'
        expect(p.first_name).to eq 'Serena'
        expect(p.last_name).to eq 'van der Woodsen'
      end
    end
  end

  describe '#to_s' do
    let(:person) { build(:person) }
    subject { person.to_s }

    it { is_expected.to include person.name }
  end

  describe '#destroy' do
    context 'when person has a user account' do
      let(:user) { create(:user) }
      let(:person) { user.person }
      it 'does not set deleted_at' do
        expect { person.destroy }.not_to change(person, :deleted_at)
      end
      it 'raises errors' do
        expect { person.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
      end
      it 'adds to errors' do
        person.destroy
        expect(person.errors.messages[:base].first).to include 'has a user'
      end
    end
  end
end
