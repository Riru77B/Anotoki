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

  # 結果画面（完了した自分の診断だけ）
  def show
    diagnosis = current_user.diagnoses.find(params[:id])
    return redirect_to diagnosis_confirmation_path(diagnosis) if diagnosis.in_progress?

    @diagnosis = diagnosis
    @scores = diagnosis.diagnosis_scores.includes(:diagnosis_axis).sort_by { |s| s.diagnosis_axis.position }
    @comparison = ScoreComparison.new(diagnosis)
  end

  # 最初からやり直す: 回答中の診断を削除して、新しい診断の1問目へ（完了した結果は消せない）
  def destroy
    current_user.diagnoses.in_progress.find(params[:id]).destroy!
    diagnosis = current_user.diagnoses.create!
    redirect_to diagnosis_question_path(diagnosis, 1), status: :see_other
  end
end
