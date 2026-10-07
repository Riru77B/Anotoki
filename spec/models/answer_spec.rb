require "rails_helper"

RSpec.describe Answer, type: :model do
  it "質問とその質問の選択肢があれば有効" do
    expect(build(:answer)).to be_valid
  end

  it "別の質問の選択肢は選べない" do
    answer = build(:answer, choice: create(:choice))
    expect(answer).not_to be_valid
    expect(answer.errors[:choice]).to include("はこの質問の選択肢ではありません")
  end

  it "1回の診断で、同じ質問には1つしか回答できない" do
    answer = create(:answer)
    other_choice = create(:choice, question: answer.question)
    expect(build(:answer, diagnosis: answer.diagnosis, question: answer.question, choice: other_choice)).not_to be_valid
  end

  it "回答で使われている選択肢は削除できない" do
    answer = create(:answer)
    expect(answer.choice.destroy).to be false
  end
end
