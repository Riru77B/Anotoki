require "rails_helper"

RSpec.describe ScoreComparison do
  let(:user) { create(:user) }
  let(:axes) { (1..3).map { |i| create(:diagnosis_axis, position: i, name: "軸#{i}") } }
  let(:diagnosis) { create(:diagnosis, :completed, user: user) }
  let(:invitation) { create(:diagnosis_invitation, user: user) }

  def set_self_scores(values)
    axes.zip(values).each { |axis, v| create(:diagnosis_score, diagnosis: diagnosis, diagnosis_axis: axis, score: v) }
  end

  def add_other(values, completed: true)
    other = create(:other_diagnosis, (completed ? :completed : :in_progress), diagnosis_invitation: invitation)
    axes.zip(values).each { |axis, v| create(:other_diagnosis_score, other_diagnosis: other, diagnosis_axis: axis, score: v) }
  end

  it "まだ誰も回答していなければ、比較はない" do
    set_self_scores([ 50, 50, 50 ])
    comparison = described_class.new(diagnosis)
    expect(comparison.any_respondents?).to be false
    expect(comparison.rows).to be_empty
  end

  it "依頼用 URL がなくても、比較なしとして扱える" do
    set_self_scores([ 50, 50, 50 ])
    expect(described_class.new(diagnosis).respondent_count).to eq 0
  end

  it "回答してくれた全員の平均と、自分のスコアを軸ごとに並べる" do
    set_self_scores([ 60, 40, 50 ])
    add_other([ 50, 70, 50 ])
    add_other([ 70, 80, 51 ])
    comparison = described_class.new(diagnosis)

    expect(comparison.respondent_count).to eq 2
    expect(comparison.rows.map { |r| [ r.diagnosis_axis.name, r.self_score, r.other_score, r.gap ] }).to eq [
      [ "軸1", 60, 60, 0 ], [ "軸2", 40, 75, 35 ], [ "軸3", 50, 51, 1 ]
    ]
  end

  it "回答中（送信前）の他者診断は数えない" do
    set_self_scores([ 50, 50, 50 ])
    add_other([ 90, 90, 90 ], completed: false)
    expect(described_class.new(diagnosis).respondent_count).to eq 0
  end

  it "周りが自分より10点以上高い軸を、差の大きい順に「気づいていない強み」とする" do
    set_self_scores([ 40, 50, 60 ])
    add_other([ 50, 59, 85 ]) # 差: +10, +9, +25
    names = described_class.new(diagnosis).hidden_strengths.map { |r| r.diagnosis_axis.name }
    expect(names).to eq %w[軸3 軸1]
  end

  describe "Row#praise_lead（気づいていない強みの前置き）" do
    let(:axis) { build(:diagnosis_axis, name: "協調性") }

    def lead(gap)
      ScoreComparison::Row.new(diagnosis_axis: axis, self_score: 40, other_score: 40 + gap).praise_lead
    end

    it "差が10〜19なら「思っている以上に」" do
      expect(lead(10)).to include("思っている以上に協調性がある")
      expect(lead(19)).to include("思っている以上に協調性がある")
    end

    it "差が20〜29なら「はっきりとした強み」" do
      expect(lead(20)).to include("協調性がはっきりとした強み")
      expect(lead(29)).to include("協調性がはっきりとした強み")
    end

    it "差が30以上なら「大きな魅力」" do
      expect(lead(30)).to include("協調性があなたの大きな魅力")
    end
  end
end
