class CreateOtherDiagnosisScores < ActiveRecord::Migration[8.1]
  def change
    create_table :other_diagnosis_scores do |t|
      t.references :other_diagnosis, null: false, foreign_key: true
      t.references :diagnosis_axis, null: false, foreign_key: true
      t.integer :raw_score, null: false
      t.integer :score, null: false

      t.timestamps
    end
    add_index :other_diagnosis_scores, [ :other_diagnosis_id, :diagnosis_axis_id ], unique: true
  end
end
