class CreateRefreshSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :refresh_sessions do |t|
      t.references :user, null: false, foreign_key: true

      t.string :token_digest, null: false
      t.uuid :family_id, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.datetime :rotated_at

      t.timestamps
    end

    add_index :refresh_sessions, :token_digest, unique: true
    add_index :refresh_sessions, :family_id
  end
end
