class AddOtherContentToChoices < ActiveRecord::Migration[8.1]
  def change
    # 他者診断で使う選択肢の文。空なら自己診断と同じ文（content）を使う
    add_column :choices, :other_content, :string
  end
end
