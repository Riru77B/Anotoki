class CreateDiagnosisScores < ActiveRecord::Migration[8.1]
  def change
    create_table :diagnosis_scores do |t|
      t.references :diagnosis, null: false, foreign_key: true
      t.references :diagnosis_axis, null: false, foreign_key: true
      t.integer :raw_score, null: false # 選んだ選択肢の点数の合計
      t.integer :score, null: false     # 画面に出すスコア（0〜100、平均的な答え方で50）

      t.timestamps
    end
    # 1回の診断で、各軸のスコアは1つだけ
    add_index :diagnosis_scores, [ :diagnosis_id, :diagnosis_axis_id ], unique: true
  end
end
