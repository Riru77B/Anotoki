# 自己診断1回分
class Diagnosis < ApplicationRecord
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :diagnosis_scores, dependent: :destroy

  enum :status, { in_progress: 0, completed: 1 }

  validates :completed_at, presence: true, if: :completed?

  class NotAllAnsweredError < StandardError; end

  def all_answered?
    answers.count == Question.count
  end

  # スコアの高い順に n 個（同点なら診断軸の表示順）
  # （一覧などで diagnosis_scores を先に読み込んでいれば、それをそのまま使う）
  def top_strengths(count = 3)
    scores = diagnosis_scores.loaded? ? diagnosis_scores : diagnosis_scores.includes(:diagnosis_axis)
    scores.sort_by { |s| [ -s.score, s.diagnosis_axis.position ] }.first(count)
  end

  # まだ答えていない最初の質問の番号（全部答えていれば nil）
  def next_unanswered_position
    Question.where.not(id: answers.select(:question_id)).minimum(:position)
  end

  # 35問すべて答えていれば、スコアを計算して保存し、診断を完了にする
  def complete!
    raise NotAllAnsweredError, "すべての質問に回答していません" unless all_answered?

    results = DiagnosisScoreCalculator.new(answers.pluck(:choice_id)).call
    transaction do
      diagnosis_scores.destroy_all
      results.each do |result|
        diagnosis_scores.create!(diagnosis_axis: result.diagnosis_axis, raw_score: result.raw_score, score: result.score)
      end
      update!(status: :completed, completed_at: Time.current)
    end
  end
end
