# 質問（35問）。diagnosis_axis はその質問が主に測る軸
class Question < ApplicationRecord
  belongs_to :diagnosis_axis
  has_many :choices, -> { order(:position) }, dependent: :destroy, inverse_of: :question

  validates :content, presence: true
  validates :position, presence: true, uniqueness: true

  default_scope { order(:position) }
end
