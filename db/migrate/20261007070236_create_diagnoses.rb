class CreateDiagnoses < ActiveRecord::Migration[8.1]
  def change
    create_table :diagnoses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0 # 0: 回答中 / 1: 完了
      t.datetime :completed_at

      t.timestamps
    end
  end
end
