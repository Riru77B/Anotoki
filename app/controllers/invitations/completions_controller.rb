# 他者診断の回答を送信する（スコアを計算して完了にする）
module Invitations
  class CompletionsController < BaseController
    before_action :set_other_diagnosis

    def create
      @other_diagnosis.complete!
      forget_other_diagnosis
      redirect_to invitation_thanks_path(@invitation.token), status: :see_other
    rescue OtherDiagnosis::NotAllAnsweredError
      redirect_to resume_path(@other_diagnosis), status: :see_other, alert: "まだ回答していない質問があります"
    end
  end
end
