class ReplaceReflectionPromptWithRecallHints < ActiveRecord::Migration[8.1]
  def change
    change_table :diagnosis_axes, bulk: true do |t|
      # 思い出しのヒント（強みから「そういえば…」と自分の経験を思い出すための、場面ごとの問いかけ）
      t.text :hint_study   # 勉強・ゼミ
      t.text :hint_work    # アルバイト
      t.text :hint_club    # サークル・部活
      t.text :hint_private # 友人・家族
      # 1文だけの「振り返ってみよう」は、思い出しのヒントに置き換える
      t.remove :reflection_prompt, type: :text
    end
  end
end
