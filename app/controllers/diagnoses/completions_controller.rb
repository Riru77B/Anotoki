# 「結果を見る」: スコアを計算して保存し、診断を完了にする
module Diagnoses
  class CompletionsController < BaseController
    def create
      @diagnosis.complete!
      redirect_to diagnosis_path(@diagnosis), status: :see_other, notice: "診断が完了しました"
    rescue Diagnosis::NotAllAnsweredError
      redirect_to diagnosis_question_path(@diagnosis, @diagnosis.next_unanswered_position),
                  status: :see_other, alert: "まだ回答していない質問があります"
    end
  end
end
