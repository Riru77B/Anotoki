# 他者診断1回分。依頼用 URL から、ログインなしで回答される（回答した人の情報は保存しない）
class OtherDiagnosis < ApplicationRecord
  include AnswerProgress

  belongs_to :diagnosis_invitation
  has_many :answers, class_name: "OtherAnswer", dependent: :destroy
  has_many :scores, class_name: "OtherDiagnosisScore", dependent: :destroy

  enum :status, { in_progress: 0, completed: 1 }

  validates :completed_at, presence: true, if: :completed?

  class NotAllAnsweredError < StandardError; end

  # 35問すべて答えていれば、自己診断と同じ計算でスコアを保存し、完了にする
  def complete!
    raise NotAllAnsweredError, "すべての質問に回答していません" unless all_answered?

    results = DiagnosisScoreCalculator.new(answers.pluck(:choice_id)).call
    transaction do
      scores.destroy_all
      results.each do |result|
        scores.create!(diagnosis_axis: result.diagnosis_axis, raw_score: result.raw_score, score: result.score)
      end
      update!(status: :completed, completed_at: Time.current)
    end
  end
end
