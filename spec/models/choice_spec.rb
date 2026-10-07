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
end
