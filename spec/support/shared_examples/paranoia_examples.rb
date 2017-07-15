RSpec.shared_examples_for 'a paranoid model' do
  it { is_expected.to be_paranoid }
  it { is_expected.to have_db_column(:deleted_at).of_type(:datetime) }
  it { is_expected.to have_db_index :deleted_at }

  it 'adds a deleted_at WHERE clause' do
    expect(described_class.all.where_sql).to include '"deleted_at" IS NULL'
  end

  it 'skips adding deleted_at WHERE clause when unscoped' do
    # to_s handles nil gracefully
    expect(described_class.unscoped.where_sql.to_s).not_to include '"deleted_at" IS NULL'
  end
end
