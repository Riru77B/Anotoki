# 質問の選択肢（1問につき5つ）
class Choice < ApplicationRecord
  belongs_to :question
  has_many :choice_scores, dependent: :destroy
  has_many :answers, dependent: :restrict_with_error
  has_many :other_answers, dependent: :restrict_with_error

  validates :content, presence: true
  validates :position, presence: true, uniqueness: { scope: :question_id }

  # 他者診断で表示する文（言い換えがなければ自己診断と同じ文）
  def other_text
    other_content.presence || content
  end
end
