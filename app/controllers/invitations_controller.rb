# 他者診断の依頼用 URL を開いたときの入口。ログインしていない人も開ける
class InvitationsController < ApplicationController
  def show
    @invitation = DiagnosisInvitation.includes(:user).find_by!(token: params[:token])
    @user = @invitation.user
  end
end
