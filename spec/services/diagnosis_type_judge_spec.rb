require "rails_helper"

RSpec.describe DiagnosisTypeJudge do
  before { load_seed_data }

  Score = Struct.new(:diagnosis_axis, :score)

  # { "analysis" => 70, ... } の形で7軸のスコアを作る（書いていない軸は50）
  def scores(overrides)
    DiagnosisAxis.all.map { |axis| Score.new(axis, overrides.fetch(axis.key, 50)) }
  end

  def judge(overrides)
    described_class.new(scores(overrides)).call
  end

  it "差が20以下ならオールラウンダータイプ" do
    expect(judge("analysis" => 60, "action" => 40).name).to eq "オールラウンダータイプ"
  end

  it "差が21以上なら、上位2軸の組み合わせのタイプ" do
    expect(judge("analysis" => 61, "problem_solving" => 58, "action" => 40).name).to eq "名探偵タイプ"
  end

  it "上位2軸の順番が逆でも同じタイプ" do
    expect(judge("creativity" => 90, "cooperation" => 80).name).to eq "化学反応メーカータイプ"
    expect(judge("cooperation" => 90, "creativity" => 80).name).to eq "化学反応メーカータイプ"
  end

  it "同点なら診断軸の表示順が前の軸を優先する" do
    # 1位: 行動力 80、2位が 協調性・発想力 の同点 → 前にある協調性
    expect(judge("action" => 80, "cooperation" => 70, "creativity" => 70, "analysis" => 20).name).to eq "ムードメーカータイプ"
  end
end
