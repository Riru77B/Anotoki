# 自己診断の回答（1問につき1つ）
class Answer < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :question
  belongs_to :choice

  validates :question_id, uniqueness: { scope: :diagnosis_id }
  validate :choice_belongs_to_question

  private

  # 別の質問の選択肢を選べないようにする
  def choice_belongs_to_question
    return if choice.nil? || choice.question_id == question_id

    errors.add(:choice, "はこの質問の選択肢ではありません")
  end
end
