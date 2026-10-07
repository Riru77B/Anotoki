require "rails_helper"

RSpec.describe DiagnosisScore, type: :model do
  it "スコアは0〜100" do
    expect(build(:diagnosis_score, score: 0)).to be_valid
    expect(build(:diagnosis_score, score: 100)).to be_valid
    expect(build(:diagnosis_score, score: 101)).not_to be_valid
  end

  it "1回の診断で、同じ軸のスコアは1つだけ" do
    score = create(:diagnosis_score)
    expect(build(:diagnosis_score, diagnosis: score.diagnosis, diagnosis_axis: score.diagnosis_axis)).not_to be_valid
  end
end
