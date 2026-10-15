# 他者診断の回答の保存（答え直しは上書き）
module Invitations
  class AnswersController < BaseController
    before_action :set_other_diagnosis

    def create
      question = Question.find_by!(position: params[:question_position])
      choice = question.choices.find(params.expect(:choice_id))
      @other_diagnosis.answers.find_or_initialize_by(question: question).update!(choice: choice)

      redirect_to next_path(question), status: :see_other
    end

    private

    def next_path(question)
      next_question = Question.find_by(position: question.position + 1)
      if next_question && !@other_diagnosis.all_answered?
        invitation_question_path(@invitation.token, next_question.position)
      else
        invitation_confirmation_path(@invitation.token)
      end
    end
  end
end
