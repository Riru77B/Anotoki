# 回答中の自己診断を扱うコントローラーの共通処理
module Diagnoses
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_diagnosis

    private

    # 自分の、回答中の診断だけを扱う（他人の診断や完了済みの診断は見つからない扱い）
    def set_diagnosis
      @diagnosis = current_user.diagnoses.in_progress.find(params[:diagnosis_id])
    end
  end
end
