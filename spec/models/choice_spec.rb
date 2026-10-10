require "rails_helper"

RSpec.describe Choice, type: :model do
  it "同じ質問の中で表示順は重複できない" do
    question = create(:question)
    create(:choice, question: question, position: 1)
    expect(build(:choice, question: question, position: 1)).not_to be_valid
  end

  it "別の質問なら同じ表示順でもよい" do
    create(:choice, position: 1)
    expect(build(:choice, position: 1)).to be_valid
  end

  describe "#other_text" do
    it "他者向けの文があればそれを返す" do
      expect(build(:choice, content: "自分が調べる", other_content: "調べる").other_text).to eq "調べる"
    end

    it "他者向けの文がなければ自己診断の文を返す" do
      expect(build(:choice, content: "調べる", other_content: nil).other_text).to eq "調べる"
    end
  end
end
