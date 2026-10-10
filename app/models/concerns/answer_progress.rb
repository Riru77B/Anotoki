# 自己診断と他者診断で共通の「回答の進み具合」の処理（answers という関連を持つモデルで使う）
module AnswerProgress
  extend ActiveSupport::Concern

  def all_answered?
    answers.count == Question.count
  end

  # まだ答えていない最初の質問の番号（全部答えていれば nil）
  def next_unanswered_position
    Question.where.not(id: answers.select(:question_id)).minimum(:position)
  end
end
