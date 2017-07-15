class CreateAuditSecurityEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :audit_security_events do |t|
      t.references :user, foreign_key: true
      t.integer :event_type
      t.string :comments
      t.timestamp :time, null: false
      t.inet :ip
      t.jsonb :geoip
      t.string :country, length: 2
      t.string :user_agent
    end

    add_index :audit_security_events, :time
  end
end
