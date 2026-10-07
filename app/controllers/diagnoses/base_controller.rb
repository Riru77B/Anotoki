# 回答中の自己診断を扱うコントローラーの共通処理
module Diagnoses
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_diagnosis

    private

    # 自分の診断だけを扱う（他人の診断は見つからない扱い）。完了済みなら答え直せないので結果画面へ
    def set_diagnosis
      @diagnosis = current_user.diagnoses.find(params[:diagnosis_id])
      redirect_to diagnosis_path(@diagnosis), status: :see_other if @diagnosis.completed?
    end
  end
end
