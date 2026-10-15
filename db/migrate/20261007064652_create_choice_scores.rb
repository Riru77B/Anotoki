class CreateChoiceScores < ActiveRecord::Migration[8.1]
  def change
    create_table :choice_scores do |t|
      t.references :choice, null: false, foreign_key: true
      t.references :diagnosis_axis, null: false, foreign_key: true
      t.integer :score, null: false

      t.timestamps
    end
    add_index :choice_scores, [ :choice_id, :diagnosis_axis_id ], unique: true
  end
end
