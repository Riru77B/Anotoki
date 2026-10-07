require "rails_helper"
require Rails.root.join("db/seeds/question_loader")

# 期待値は企画段階（Next.js 版）の計算結果と照合済みの値
RSpec.describe DiagnosisScoreCalculator do
  before { QuestionLoader.call }

  let(:questions) { Question.includes(choices: :choice_scores).to_a }

  def scores_for(choice_ids)
    described_class.new(choice_ids).call.to_h { |r| [ r.diagnosis_axis.key, r.score ] }
  end

  # 各問で、指定した軸の点が一番高い選択肢を選ぶ
  def choices_maximizing(axis_key)
    axis = DiagnosisAxis.find_by!(key: axis_key)
    questions.map do |q|
      q.choices.max_by { |c| [ c.choice_scores.find { |s| s.diagnosis_axis_id == axis.id }&.score || 0, -c.position ] }.id
    end
  end

  it "行動力の選択肢ばかり選ぶと、行動力が100になり、ほかは低くなる（最低10）" do
    expect(scores_for(choices_maximizing("action"))).to eq(
      "analysis" => 10, "problem_solving" => 20, "action" => 100, "cooperation" => 10,
      "learning" => 22, "persistence" => 18, "creativity" => 90
    )
  end

  it "全問でAを選んだときのスコア" do
    expect(scores_for(questions.map { |q| q.choices.first.id })).to eq(
      "analysis" => 76, "problem_solving" => 57, "action" => 59, "cooperation" => 18,
      "learning" => 49, "persistence" => 47, "creativity" => 64
    )
  end

  it "合計点（raw_score）は選んだ選択肢の点数の合計" do
    first = questions.first.choices.first # 分析5・学習1
    results = described_class.new([ first.id ]).call.to_h { |r| [ r.diagnosis_axis.key, r.raw_score ] }
    expect(results).to include("analysis" => 5, "learning" => 1, "action" => 0)
  end

  it "スコアは必ず10〜100に収まる" do
    10.times do
      results = described_class.new(questions.map { |q| q.choices.sample.id }).call
      expect(results.map(&:score)).to all(be_between(10, 100))
    end
  end
end
