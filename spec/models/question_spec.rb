require "rails_helper"

RSpec.describe Question, type: :model do
  it "質問文と番号があれば有効" do
    expect(build(:question)).to be_valid
  end

  it "質問文がなければ無効" do
    expect(build(:question, content: "")).not_to be_valid
  end

  it "選択肢は表示順に並ぶ" do
    question = create(:question)
    second = create(:choice, question: question, position: 2)
    first = create(:choice, question: question, position: 1)
    expect(question.choices).to eq [ first, second ]
  end

  it "質問を消すと選択肢と配点も消える" do
    question = create(:question)
    choice = create(:choice, question: question)
    create(:choice_score, choice: choice)
    expect { question.destroy }.to change(Choice, :count).by(-1).and change(ChoiceScore, :count).by(-1)
  end
end
