require "rails_helper"

RSpec.describe "他者診断の依頼用 URL", type: :request do
  let(:user) { create(:user, name: "たろう") }

  describe "URL を作る" do
    it "ログインしていなければログイン画面へ" do
      post diagnosis_invitation_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "URL を作ってマイページへ戻る" do
      sign_in user
      expect { post diagnosis_invitation_path }.to change(DiagnosisInvitation, :count).by(1)
      expect(response).to redirect_to(mypage_path(anchor: "other-diagnosis"))
    end

    it "すでにあれば作り直さない（送った URL が使えなくならない）" do
      invitation = create(:diagnosis_invitation, user: user)
      sign_in user
      expect { post diagnosis_invitation_path }.not_to change(DiagnosisInvitation, :count)
      expect(invitation.reload.token).to eq user.reload.diagnosis_invitation.token
    end
  end

  describe "マイページ" do
    before { sign_in user }

    it "URL がなければ「依頼用の URL を作る」ボタンを表示する" do
      get mypage_path
      expect(response.body).to include("依頼用の URL を作る")
    end

    it "URL があれば、その URL を表示する" do
      invitation = create(:diagnosis_invitation, user: user)
      get mypage_path
      expect(response.body).to include(invitation_url(invitation.token))
    end
  end

  describe "URL を開いたときの入口" do
    it "ログインしていなくても開けて、依頼した人の名前を表示する" do
      invitation = create(:diagnosis_invitation, user: user)
      get invitation_path(invitation.token)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("たろうさんについて")
    end

    it "存在しないトークンは見つからない" do
      get invitation_path("not-a-real-token")
      expect(response).to have_http_status(:not_found)
    end
  end
end
