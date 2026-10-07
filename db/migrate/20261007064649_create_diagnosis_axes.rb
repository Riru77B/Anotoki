class CreateDiagnosisAxes < ActiveRecord::Migration[8.1]
  def change
    create_table :diagnosis_axes do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.integer :position, null: false

      t.timestamps
    end
    add_index :diagnosis_axes, :key, unique: true
    add_index :diagnosis_axes, :position, unique: true
  end
end
