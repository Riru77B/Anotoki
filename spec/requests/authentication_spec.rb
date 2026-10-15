require "rails_helper"

RSpec.describe "ユーザー登録・ログイン", type: :request do
  let(:password) { "password123" }
  let!(:user) { create(:user, email: "taro@example.com", password: password, password_confirmation: password) }

  describe "マイページ" do
    it "ログインしていなければログイン画面へ移動する" do
      get mypage_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログインしていれば表示される" do
      sign_in user
      get mypage_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("#{user.name} さんのマイページ")
    end
  end

  describe "新規登録" do
    let(:params) do
      { user: { name: "花子", email: "hanako@example.com", password: password, password_confirmation: password } }
    end

    it "正しい内容なら登録してマイページへ移動する" do
      expect { post user_registration_path, params: params }.to change(User, :count).by(1)
      expect(response).to redirect_to(mypage_path)
      expect(User.last.name).to eq("花子")
    end

    it "名前がなければ登録できずエラーを表示する" do
      params[:user][:name] = ""
      expect { post user_registration_path, params: params }.not_to change(User, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("名前を入力してください")
    end
  end

  describe "ログイン" do
    it "正しいパスワードならマイページへ移動する" do
      post user_session_path, params: { user: { email: user.email, password: password } }
      expect(response).to redirect_to(mypage_path)
    end

    it "パスワードが違えばエラーを表示する" do
      post user_session_path, params: { user: { email: user.email, password: "wrongpass1" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("メールアドレスまたはパスワードが違います。")
    end
  end

  describe "ログアウト" do
    it "トップページへ移動し、マイページは見られなくなる" do
      sign_in user
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)

      get mypage_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
