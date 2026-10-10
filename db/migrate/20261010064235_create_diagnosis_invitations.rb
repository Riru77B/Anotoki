class CreateDiagnosisInvitations < ActiveRecord::Migration[8.1]
  def change
    # 他者診断の依頼用 URL（ユーザーごとに1つ。同じ URL を何人にでも送れる）
    create_table :diagnosis_invitations do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :token, null: false

      t.timestamps
    end
    add_index :diagnosis_invitations, :token, unique: true
  end
end
