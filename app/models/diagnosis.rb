# 自己診断1回分
class Diagnosis < ApplicationRecord
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :diagnosis_scores, dependent: :destroy

  enum :status, { in_progress: 0, completed: 1 }

  validates :completed_at, presence: true, if: :completed?
end
