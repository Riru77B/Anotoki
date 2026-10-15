class CreateDiagnosisTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :diagnosis_types do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description, null: false
      # 上位2軸の組み合わせ（診断軸の表示順で前の軸を primary にする）。バランス型は空
      t.references :primary_axis, foreign_key: { to_table: :diagnosis_axes }
      t.references :secondary_axis, foreign_key: { to_table: :diagnosis_axes }
      t.boolean :balanced, null: false, default: false
      t.integer :position, null: false

      t.timestamps
    end
    add_index :diagnosis_types, :key, unique: true
    add_index :diagnosis_types, [ :primary_axis_id, :secondary_axis_id ], unique: true
  end
end
