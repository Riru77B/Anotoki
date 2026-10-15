# 選択肢を選んだときに、各診断軸へ入る点数（0〜5）
class ChoiceScore < ApplicationRecord
  belongs_to :choice
  belongs_to :diagnosis_axis

  validates :score, presence: true, inclusion: { in: 0..5 }
  validates :diagnosis_axis_id, uniqueness: { scope: :choice_id }
end
