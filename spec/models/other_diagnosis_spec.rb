require "rails_helper"

RSpec.describe OtherDiagnosis, type: :model do
  it "作ったときは回答中" do
    expect(create(:other_diagnosis)).to be_in_progress
  end

  it "依頼用 URL（ユーザー）を削除すると、他者診断・回答・スコアも削除される" do
    other = create(:other_diagnosis)
    create(:other_answer, other_diagnosis: other)
    create(:other_diagnosis_score, other_diagnosis: other)
    expect { other.diagnosis_invitation.user.destroy }
      .to change(described_class, :count).by(-1)
      .and change(OtherAnswer, :count).by(-1)
      .and change(OtherDiagnosisScore, :count).by(-1)
  end

  describe "#complete!" do
    before { load_seed_data }

    let(:other) { create(:other_diagnosis) }

    def answer_all(other)
      Question.includes(:choices).find_each { |q| other.answers.create!(question: q, choice: q.choices.first) }
    end

    it "全問答えていなければエラーになり、完了にならない" do
      q1 = Question.first
      other.answers.create!(question: q1, choice: q1.choices.first)
      expect { other.complete! }.to raise_error(OtherDiagnosis::NotAllAnsweredError)
      expect(other.reload).to be_in_progress
    end

    it "全問答えると、自己診断と同じ計算で7軸のスコアを保存して完了にする" do
      answer_all(other)
      other.complete!

      expected = DiagnosisScoreCalculator.new(other.answers.pluck(:choice_id)).call.to_h { |r| [ r.diagnosis_axis.id, r.score ] }
      expect(other.reload).to be_completed
      expect(other.scores.to_h { |s| [ s.diagnosis_axis_id, s.score ] }).to eq expected
    end

    it "もう一度実行してもスコアは重複しない" do
      answer_all(other)
      other.complete!
      expect { other.complete! }.not_to change(OtherDiagnosisScore, :count)
    end
  end
end
