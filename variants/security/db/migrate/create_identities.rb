class CreateIdentities < ActiveRecord::Migration[5.1]
  def change
    create_table :identities do |t|
      t.references :user
      t.string :provider
      t.string :uid
      t.jsonb :info
      t.timestamps null: false
      t.datetime :deleted_at
    end

    add_index :identities, :deleted_at
    add_index :identities, [:provider, :uid], unique: true
  end
end
