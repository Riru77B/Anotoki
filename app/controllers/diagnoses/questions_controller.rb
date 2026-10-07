# 1問ずつの回答画面
module Diagnoses
  class QuestionsController < BaseController
    def show
      @question = Question.includes(:choices).find_by!(position: params[:position])
      @answer = @diagnosis.answers.find_by(question: @question)
      @total = Question.count
    end
  end
end
