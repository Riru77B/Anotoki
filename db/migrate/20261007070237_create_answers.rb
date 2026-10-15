class CreateAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :answers do |t|
      t.references :diagnosis, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.references :choice, null: false, foreign_key: true

      t.timestamps
    end
    # 1回の診断で、同じ質問への回答は1つだけ
    add_index :answers, [ :diagnosis_id, :question_id ], unique: true
  end
end
