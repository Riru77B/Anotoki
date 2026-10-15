class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.references :diagnosis_axis, null: false, foreign_key: true
      t.text :content, null: false
      t.text :other_content # 他者診断用の質問文（本リリースで使う）
      t.integer :position, null: false

      t.timestamps
    end
    add_index :questions, :position, unique: true
  end
end
