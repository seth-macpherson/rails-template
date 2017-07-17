class CreateReports < ActiveRecord::Migration[5.1]
  def change
    create_table :reports do |t|
      t.string     :title, null: false
      t.string     :description
      t.string     :query
      t.jsonb      :settings
      t.string     :chart_type, null: false
      t.integer    :hits, null: false, default: 0
      t.boolean    :published, null: false, default: false
      t.timestamps null: false
      t.datetime   :deleted_at
    end

    add_index :reports, :deleted_at
  end
end
