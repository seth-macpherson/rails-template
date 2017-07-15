RSpec.shared_examples_for 'a repositionable model' do
  it { is_expected.to have_db_column(:position).of_type(:integer) }

  it do
    conditions = described_class.new.scope_condition
    cols = [:position]
    cols.prepend(*conditions.keys) if conditions.is_a?(Hash)
    is_expected.to have_db_index cols
  end

  it { expect(described_class.new).to respond_to :insert_at }
end
