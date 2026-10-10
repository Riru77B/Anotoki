class CreateOtherAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :other_answers do |t|
      t.references :other_diagnosis, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.references :choice, null: false, foreign_key: true

      t.timestamps
    end
    add_index :other_answers, [ :other_diagnosis_id, :question_id ], unique: true
  end
end
