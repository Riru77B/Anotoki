# 他者診断の依頼用 URL を開いたときの入口。ログインしていない人も開ける
class InvitationsController < Invitations::BaseController
  skip_before_action :reject_owner

  def show
    @own_invitation = user_signed_in? && current_user.id == @owner.id
    @in_progress = current_other_diagnosis unless @own_invitation
  end
end
