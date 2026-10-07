class DiagnosesController < ApplicationController
  before_action :authenticate_user!

  # 診断をはじめる。回答中の診断があれば、その続きから
  def create
    diagnosis = current_user.diagnoses.in_progress.order(:created_at).last || current_user.diagnoses.create!
    position = diagnosis.next_unanswered_position

    if position
      redirect_to diagnosis_question_path(diagnosis, position), status: :see_other
    else
      redirect_to diagnosis_confirmation_path(diagnosis), status: :see_other
    end
  end
end
