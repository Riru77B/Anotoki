# 質問の選択肢（1問につき5つ）
class Choice < ApplicationRecord
  belongs_to :question
  has_many :choice_scores, dependent: :destroy
  has_many :answers, dependent: :restrict_with_error

  validates :content, presence: true
  validates :position, presence: true, uniqueness: { scope: :question_id }
end
