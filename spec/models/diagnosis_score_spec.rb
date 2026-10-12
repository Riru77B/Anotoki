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

  describe "#strength_lead（強みTOP3の前置き）" do
    let(:axis) { build(:diagnosis_axis, name: "分析力") }

    def lead(score, rank = 1)
      build(:diagnosis_score, diagnosis_axis: axis, score: score).strength_lead(rank)
    end

    it "75点以上なら「際立っている強み」" do
      expect(lead(75)).to eq "分析力は、あなたの中で際立っている強みです。"
    end

    it "60〜74点なら「はっきりとした強み」" do
      expect(lead(60)).to eq "分析力は、あなたのはっきりとした強みです。"
      expect(lead(74)).to eq "分析力は、あなたのはっきりとした強みです。"
    end

    it "59点以下なら「比べるとよく表れている力」。1位だけ「一番」を付ける" do
      expect(lead(59, 1)).to start_with "分析力は、あなたの中で比べると一番よく表れている力です。"
      expect(lead(40, 2)).to start_with "分析力は、あなたの中で比べるとよく表れている力です。"
    end
  end
end
