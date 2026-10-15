# 他者診断の確認画面（答えを見直して、各質問に戻れる）
module Invitations
  class ConfirmationsController < BaseController
    before_action :set_other_diagnosis

    def show
      position = @other_diagnosis.next_unanswered_position
      return redirect_to invitation_question_path(@invitation.token, position) if position

      @answers = @other_diagnosis.answers.includes(:question, :choice).sort_by { |a| a.question.position }
    end
  end
end
