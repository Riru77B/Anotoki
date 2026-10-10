# 他者診断の回答をはじめる（このブラウザで回答中のものがあれば続きから）
module Invitations
  class OtherDiagnosesController < BaseController
    def create
      other_diagnosis = current_other_diagnosis || @invitation.other_diagnoses.create!
      remember_other_diagnosis(other_diagnosis)
      redirect_to resume_path(other_diagnosis), status: :see_other
    end
  end
end
