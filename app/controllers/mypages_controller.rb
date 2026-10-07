class MypagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @in_progress = current_user.diagnoses.in_progress.order(:created_at).last
    @completed = current_user.diagnoses.completed.order(completed_at: :desc).includes(diagnosis_scores: :diagnosis_axis)
  end
end
