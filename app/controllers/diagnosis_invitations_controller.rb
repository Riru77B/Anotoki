class DiagnosisInvitationsController < ApplicationController
  before_action :authenticate_user!

  # 依頼用 URL を作る。すでにあれば作り直さない（送った URL が使えなくならないように）
  # 押した画面（マイページ・結果画面）に戻る
  def create
    current_user.diagnosis_invitation || current_user.create_diagnosis_invitation!
    redirect_back_or_to mypage_path(anchor: "other-diagnosis"), status: :see_other, notice: "他者診断の依頼用 URL を作りました"
  end
end
