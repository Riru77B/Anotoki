require "rails_helper"

RSpec.describe ChoiceScore, type: :model do
  it "点数は0〜5" do
    expect(build(:choice_score, score: 0)).to be_valid
    expect(build(:choice_score, score: 5)).to be_valid
    expect(build(:choice_score, score: 6)).not_to be_valid
    expect(build(:choice_score, score: -1)).not_to be_valid
  end

  it "1つの選択肢に同じ軸の点数は1つだけ" do
    score = create(:choice_score)
    expect(build(:choice_score, choice: score.choice, diagnosis_axis: score.diagnosis_axis)).not_to be_valid
  end
end
