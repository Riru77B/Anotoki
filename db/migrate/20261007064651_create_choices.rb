class CreateChoices < ActiveRecord::Migration[8.1]
  def change
    create_table :choices do |t|
      t.references :question, null: false, foreign_key: true
      t.string :content, null: false
      t.integer :position, null: false

      t.timestamps
    end
    add_index :choices, [ :question_id, :position ], unique: true
  end
end
