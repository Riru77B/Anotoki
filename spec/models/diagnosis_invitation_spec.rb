require "rails_helper"

RSpec.describe DiagnosisInvitation, type: :model do
  it "作るとランダムなトークン（24文字）が付く" do
    invitation = create(:diagnosis_invitation)
    expect(invitation.token).to match(/\A[a-zA-Z0-9]{24}\z/)
  end

  it "トークンは毎回違う" do
    expect(create(:diagnosis_invitation).token).not_to eq create(:diagnosis_invitation).token
  end

  it "1人のユーザーにつき1つだけ" do
    invitation = create(:diagnosis_invitation)
    expect(build(:diagnosis_invitation, user: invitation.user)).not_to be_valid
  end

  it "ユーザーを削除すると依頼用 URL も削除される" do
    invitation = create(:diagnosis_invitation)
    expect { invitation.user.destroy }.to change(described_class, :count).by(-1)
  end
end
