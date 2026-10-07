require "rails_helper"

RSpec.describe Diagnosis, type: :model do
  it "作ったときは回答中" do
    expect(create(:diagnosis)).to be_in_progress
  end

  it "完了にするときは完了日時が必要" do
    diagnosis = build(:diagnosis, status: :completed, completed_at: nil)
    expect(diagnosis).not_to be_valid
    expect(build(:diagnosis, :completed)).to be_valid
  end

  it "ユーザーを削除すると、診断・回答・スコアも削除される" do
    diagnosis = create(:diagnosis)
    create(:answer, diagnosis: diagnosis)
    create(:diagnosis_score, diagnosis: diagnosis)
    expect { diagnosis.user.destroy }
      .to change(Diagnosis, :count).by(-1)
      .and change(Answer, :count).by(-1)
      .and change(DiagnosisScore, :count).by(-1)
  end
end

RSpec.describe Diagnosis, "#complete!", type: :model do
  before { load_seed_data }

  let(:diagnosis) { create(:diagnosis) }

  def answer_all(diagnosis)
    Question.includes(:choices).find_each do |question|
      diagnosis.answers.create!(question: question, choice: question.choices.first)
    end
  end

  it "全問答えていなければエラーになり、完了にならない" do
    diagnosis.answers.create!(question: Question.first, choice: Question.first.choices.first)
    expect { diagnosis.complete! }.to raise_error(Diagnosis::NotAllAnsweredError)
    expect(diagnosis.reload).to be_in_progress
  end

  it "全問答えると、7軸のスコアを保存して完了にする" do
    answer_all(diagnosis)
    diagnosis.complete!
    expect(diagnosis.reload).to be_completed
    expect(diagnosis.completed_at).to be_present
    expect(diagnosis.diagnosis_scores.count).to eq 7
    expect(diagnosis.diagnosis_type).to eq DiagnosisTypeJudge.new(diagnosis.diagnosis_scores.includes(:diagnosis_axis)).call
  end

  it "もう一度実行してもスコアは重複しない" do
    answer_all(diagnosis)
    diagnosis.complete!
    expect { diagnosis.complete! }.not_to change(DiagnosisScore, :count)
  end
end

RSpec.describe Diagnosis, "#top_strengths", type: :model do
  let(:diagnosis) { create(:diagnosis, :completed) }
  let(:axes) { (1..4).map { |i| create(:diagnosis_axis, position: i, name: "軸#{i}") } }

  it "スコアの高い順に3つ返す。同点なら診断軸の表示順" do
    { 0 => 60, 1 => 80, 2 => 60, 3 => 40 }.each { |i, score| create(:diagnosis_score, diagnosis: diagnosis, diagnosis_axis: axes[i], score: score) }
    expect(diagnosis.top_strengths.map { |s| s.diagnosis_axis.name }).to eq %w[軸2 軸1 軸3]
  end

  it "lower_scores はスコアの低い順に2つ返す" do
    { 0 => 60, 1 => 80, 2 => 30, 3 => 40 }.each { |i, score| create(:diagnosis_score, diagnosis: diagnosis, diagnosis_axis: axes[i], score: score) }
    expect(diagnosis.lower_scores.map { |s| s.diagnosis_axis.name }).to eq %w[軸3 軸4]
  end
end
