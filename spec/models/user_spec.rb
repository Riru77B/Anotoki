require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "名前・メールアドレス・パスワードがあれば有効" do
      expect(build(:user)).to be_valid
    end

    it "名前がなければ無効" do
      user = build(:user, name: "")
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("を入力してください")
    end

    it "名前は30文字まで" do
      expect(build(:user, name: "あ" * 30)).to be_valid
      expect(build(:user, name: "あ" * 31)).not_to be_valid
    end

    it "メールアドレスは重複できない" do
      create(:user, email: "same@example.com")
      user = build(:user, email: "same@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("はすでに存在します")
    end

    it "パスワードは8文字以上" do
      expect(build(:user, password: "abc1234", password_confirmation: "abc1234")).not_to be_valid
      expect(build(:user, password: "abc12345", password_confirmation: "abc12345")).to be_valid
    end
  end
end
