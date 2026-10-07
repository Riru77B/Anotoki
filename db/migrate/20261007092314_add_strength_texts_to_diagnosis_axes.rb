class AddStrengthTextsToDiagnosisAxes < ActiveRecord::Migration[8.1]
  def change
    change_table :diagnosis_axes, bulk: true do |t|
      t.text :strength_scene  # 強みとして働く場面（TOP3 に表示）
      t.text :growth_hint     # もっと活かすヒント（TOP3 に表示）
      t.text :low_score_merit # 低めのときの良さ（下位2つに表示）
      t.text :flip_side       # 裏目に出る可能性（画面には出さない。面接用の文章づくりで使う予定）
    end
  end
end
