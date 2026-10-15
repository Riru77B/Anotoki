class CreateOtherDiagnoses < ActiveRecord::Migration[8.1]
  def change
    # 他者診断1回分（回答した人の名前などは保存しない）
    create_table :other_diagnoses do |t|
      t.references :diagnosis_invitation, null: false, foreign_key: true
      t.integer :status, null: false, default: 0 # 0: 回答中 / 1: 完了
      t.datetime :completed_at

      t.timestamps
    end
  end
end
