require "rails_helper"
require Rails.root.join("db/seeds/question_loader")

RSpec.describe "マイページ", type: :request do
  before do
    QuestionLoader.call
    sign_in user
  end

  let(:user) { create(:user) }

  it "診断したことがなければ「自己診断をはじめる」と表示する" do
    get mypage_path
    expect(response.body).to include("自己診断をはじめる", "まだ診断結果はありません。")
  end

  it "回答中の診断があれば「続きから」と「最初からやり直す」を表示する" do
    create(:diagnosis, user: user)
    get mypage_path
    expect(response.body).to include("続きから診断する（0 / 35 問回答済み）", "最初からやり直す")
  end

  it "完了した診断を新しい順に一覧表示し、「もう一度診断する」と表示する" do
    old = create(:diagnosis, :completed, user: user, completed_at: Time.zone.local(2026, 9, 1, 10, 0))
    new = create(:diagnosis, :completed, user: user, completed_at: Time.zone.local(2026, 10, 1, 10, 0))
    create(:diagnosis, :completed) # 他人の結果は出ない

    get mypage_path
    body = response.body
    expect(body).to include("もう一度診断する")
    expect(body).to include("強み：")
    expect(body.scan(%r{/diagnoses/\d+"}).uniq).to eq [ "/diagnoses/#{new.id}\"", "/diagnoses/#{old.id}\"" ]
  end

  it "過去の結果一覧に総合タイプの名前を表示する" do
    load_seed_data
    create(:diagnosis, :completed, user: user, diagnosis_type: DiagnosisType.find_by!(key: "analysis_creativity"))
    get mypage_path
    expect(response.body).to include("設計士タイプ")
  end

  describe "最初からやり直す" do
    it "回答中の診断を削除して、新しい診断の1問目へ移動する" do
      in_progress = create(:diagnosis, user: user)
      q1 = Question.find_by!(position: 1)
      in_progress.answers.create!(question: q1, choice: q1.choices.first)

      delete diagnosis_path(in_progress)

      new_diagnosis = user.diagnoses.last
      expect(Diagnosis.exists?(in_progress.id)).to be false
      expect(new_diagnosis.answers).to be_empty
      expect(response).to redirect_to(diagnosis_question_path(new_diagnosis, 1))
    end

    it "完了した診断は削除できない" do
      completed = create(:diagnosis, :completed, user: user)
      delete diagnosis_path(completed)
      expect(response).to have_http_status(:not_found)
      expect(Diagnosis.exists?(completed.id)).to be true
    end

    it "他人の診断は削除できない" do
      other = create(:diagnosis)
      delete diagnosis_path(other)
      expect(response).to have_http_status(:not_found)
      expect(Diagnosis.exists?(other.id)).to be true
    end
  end
end
