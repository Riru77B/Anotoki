# 質問（35問）。diagnosis_axis はその質問が主に測る軸
class Question < ApplicationRecord
  belongs_to :diagnosis_axis
  has_many :choices, -> { order(:position) }, dependent: :destroy, inverse_of: :question
  has_many :answers, dependent: :restrict_with_error

  validates :content, presence: true
  validates :other_content, presence: true # 他者診断の問題文
  validates :position, presence: true, uniqueness: true

  default_scope { order(:position) }
end
