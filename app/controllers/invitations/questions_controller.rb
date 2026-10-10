# 他者診断の1問ずつの回答画面
module Invitations
  class QuestionsController < BaseController
    before_action :set_other_diagnosis

    def show
      @question = Question.includes(:choices).find_by!(position: params[:position])
      @answer = @other_diagnosis.answers.find_by(question: @question)
      @total = Question.count
    end
  end
end
