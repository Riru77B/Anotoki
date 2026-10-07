# 診断軸（分析力・課題解決力など7つ）
class DiagnosisAxis < ApplicationRecord
  has_many :questions, dependent: :restrict_with_error
  has_many :choice_scores, dependent: :restrict_with_error
  has_many :diagnosis_scores, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
  validates :description, presence: true
  validates :position, presence: true, uniqueness: true

  default_scope { order(:position) }
end
