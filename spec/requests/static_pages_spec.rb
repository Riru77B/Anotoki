require "rails_helper"

RSpec.describe "利用規約・プライバシーポリシー", type: :request do
  it "利用規約はログインしていなくても見られる" do
    get terms_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("利用規約", "運営者：Riru", "https://x.com/00077bw")
  end

  it "プライバシーポリシーはログインしていなくても見られる" do
    get privacy_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("プライバシーポリシー", "回答者を特定する情報は取得しません")
  end

  it "どのページのフッターにも、利用規約とプライバシーポリシーへのリンクがある" do
    get root_path
    footer = Nokogiri::HTML(response.body).at_css("footer")
    expect(footer.css("a").map { |a| a["href"] }).to include(terms_path, privacy_path)
  end

  it "新規登録の画面に、同意の案内を表示する" do
    get new_user_registration_path
    expect(response.body).to include("に同意したものとみなします")
  end
end
