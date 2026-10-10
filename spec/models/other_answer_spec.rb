require "rails_helper"

RSpec.describe OtherAnswer, type: :model do
  it "別の質問の選択肢は選べない" do
    answer = build(:other_answer, choice: create(:choice))
    expect(answer).not_to be_valid
  end

  it "1回の他者診断で、同じ質問には1つしか回答できない" do
    answer = create(:other_answer)
    other_choice = create(:choice, question: answer.question)
    expect(build(:other_answer, other_diagnosis: answer.other_diagnosis, question: answer.question, choice: other_choice)).not_to be_valid
  end
end
