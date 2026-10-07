require "rails_helper"

RSpec.describe Diagnosis, type: :model do
  it "作ったときは回答中" do
    expect(create(:diagnosis)).to be_in_progress
  end

  it "完了にするときは完了日時が必要" do
    diagnosis = build(:diagnosis, status: :completed, completed_at: nil)
    expect(diagnosis).not_to be_valid
    expect(build(:diagnosis, :completed)).to be_valid
  end

  it "ユーザーを削除すると、診断・回答・スコアも削除される" do
    diagnosis = create(:diagnosis)
    create(:answer, diagnosis: diagnosis)
    create(:diagnosis_score, diagnosis: diagnosis)
    expect { diagnosis.user.destroy }
      .to change(Diagnosis, :count).by(-1)
      .and change(Answer, :count).by(-1)
      .and change(DiagnosisScore, :count).by(-1)
  end
end
