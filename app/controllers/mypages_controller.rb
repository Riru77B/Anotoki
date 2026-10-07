class MypagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @in_progress = current_user.diagnoses.in_progress.order(:created_at).last
  end
end
