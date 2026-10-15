require "rails_helper"

RSpec.describe OtherDiagnosisScore, type: :model do
  it "スコアは0〜100" do
    expect(build(:other_diagnosis_score, score: 100)).to be_valid
    expect(build(:other_diagnosis_score, score: 101)).not_to be_valid
  end
end
