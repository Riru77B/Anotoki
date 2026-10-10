# 他者診断の回答（ログイン不要）で共通の処理
#
# 回答中の他者診断は、ブラウザのセッション（Cookie）に「依頼用 URL のトークン → 他者診断の ID」だけを覚えておく。
# 回答した人の名前などは保存しない。
module Invitations
  class BaseController < ApplicationController
    SESSION_KEY = :other_diagnosis_ids

    before_action :set_invitation
    before_action :reject_owner

    private

    def set_invitation
      @invitation = DiagnosisInvitation.includes(:user).find_by!(token: params[:token])
      @owner = @invitation.user
    end

    # 依頼した本人は、自分について回答できない
    def reject_owner
      return unless user_signed_in? && current_user.id == @owner.id

      redirect_to invitation_path(@invitation.token), status: :see_other
    end

    def set_other_diagnosis
      @other_diagnosis = current_other_diagnosis
      redirect_to invitation_path(@invitation.token), status: :see_other unless @other_diagnosis
    end

    def current_other_diagnosis
      id = session.fetch(SESSION_KEY, {})[@invitation.token]
      id && @invitation.other_diagnoses.in_progress.find_by(id: id)
    end

    def remember_other_diagnosis(other_diagnosis)
      session[SESSION_KEY] = session.fetch(SESSION_KEY, {}).merge(@invitation.token => other_diagnosis.id)
    end

    def forget_other_diagnosis
      session[SESSION_KEY] = session.fetch(SESSION_KEY, {}).except(@invitation.token)
    end

    # まだ答えていない質問へ。全部答えていれば確認画面へ
    def resume_path(other_diagnosis)
      position = other_diagnosis.next_unanswered_position
      position ? invitation_question_path(@invitation.token, position) : invitation_confirmation_path(@invitation.token)
    end
  end
end
