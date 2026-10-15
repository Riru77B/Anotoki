# 全問回答後の確認画面（答えを見直して、各質問に戻れる）
module Diagnoses
  class ConfirmationsController < BaseController
    def show
      position = @diagnosis.next_unanswered_position
      return redirect_to diagnosis_question_path(@diagnosis, position) if position

      @answers = @diagnosis.answers.includes(:question, :choice).sort_by { |a| a.question.position }
    end
  end
end
