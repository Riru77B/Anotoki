# 自己診断1回分の、診断軸ごとのスコア
class DiagnosisScore < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :diagnosis_axis

  validates :raw_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :score, presence: true, inclusion: { in: 0..100 }
  validates :diagnosis_axis_id, uniqueness: { scope: :diagnosis_id }
end
