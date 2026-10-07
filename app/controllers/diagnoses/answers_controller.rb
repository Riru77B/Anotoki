# 回答の保存（答え直しは上書き）
module Diagnoses
  class AnswersController < BaseController
    def create
      question = Question.find_by!(position: params[:question_position])
      choice = question.choices.find(params.expect(:choice_id))

      answer = @diagnosis.answers.find_or_initialize_by(question: question)
      answer.update!(choice: choice)

      redirect_to next_path(question), status: :see_other
    end

    private

    # 次の質問へ。最後の質問、またはすべて答え終わっていれば確認画面へ
    def next_path(question)
      next_question = Question.find_by(position: question.position + 1)
      if next_question && !@diagnosis.all_answered?
        diagnosis_question_path(@diagnosis, next_question.position)
      else
        diagnosis_confirmation_path(@diagnosis)
      end
    end
  end
end
