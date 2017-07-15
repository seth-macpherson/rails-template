class CreatePeople < ActiveRecord::Migration[5.1]
  def change
    create_table :people do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :email
      t.string :phone
      t.date :born_on
      t.timestamps
      t.datetime :deleted_at
    end

    add_index :people, :email
    add_index :people, :deleted_at
  end
end
