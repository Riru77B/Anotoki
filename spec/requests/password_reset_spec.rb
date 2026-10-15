require "rails_helper"

RSpec.describe "パスワード再設定", type: :request do
  let!(:user) { create(:user, email: "taro@example.com", password: "password123", password_confirmation: "password123") }

  before { ActionMailer::Base.deliveries.clear }

  it "ログイン画面に再設定画面へのリンクがある" do
    get new_user_session_path
    expect(response.body).to include("パスワードを忘れた方はこちら")
    expect(response.body).to include(new_user_password_path)
  end

  it "登録済みのメールアドレスなら再設定メールが届く" do
    post user_password_path, params: { user: { email: user.email } }

    expect(response).to redirect_to(new_user_session_path)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([ user.email ])
    expect(mail.body.encoded).to include("新しいパスワードを設定する")
  end

  it "登録されていないメールアドレスでも、同じ案内を出してメールは送らない" do
    post user_password_path, params: { user: { email: "nobody@example.com" } }

    expect(response).to redirect_to(new_user_session_path)
    expect(ActionMailer::Base.deliveries).to be_empty
    follow_redirect!
    expect(response.body).to include("メールアドレスが登録済みの場合、パスワード再設定用のメールが数分以内に送信されます。")
  end

  describe "新しいパスワードの設定" do
    let(:token) { user.send_reset_password_instructions }

    it "メールのリンクから新しいパスワードに変更でき、そのパスワードでログインできる" do
      get edit_user_password_path(reset_password_token: token)
      expect(response).to have_http_status(:ok)

      put user_password_path, params: { user: { reset_password_token: token, password: "newpass456", password_confirmation: "newpass456" } }
      expect(response).to redirect_to(mypage_path)
      expect(user.reload.valid_password?("newpass456")).to be true
    end

    it "トークンが正しくなければ変更できない" do
      put user_password_path, params: { user: { reset_password_token: "wrong", password: "newpass456", password_confirmation: "newpass456" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.valid_password?("password123")).to be true
    end
  end
end
