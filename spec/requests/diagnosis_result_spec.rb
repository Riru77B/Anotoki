require "rails_helper"
require Rails.root.join("db/seeds/question_loader")

RSpec.describe "自己診断の完了と結果", type: :request do
  before do
    QuestionLoader.call
    sign_in user
  end

  let(:user) { create(:user) }
  let(:diagnosis) { create(:diagnosis, user: user) }
  let(:q1) { Question.find_by!(position: 1) }

  def answer_all(diagnosis)
    Question.includes(:choices).find_each { |q| diagnosis.answers.create!(question: q, choice: q.choices.first) }
  end

  describe "結果を見る" do
    it "全問答えていれば、スコアを保存して結果画面へ移動する" do
      answer_all(diagnosis)
      post diagnosis_completion_path(diagnosis)

      expect(response).to redirect_to(diagnosis_path(diagnosis))
      expect(diagnosis.reload).to be_completed
      expect(diagnosis.diagnosis_scores.count).to eq 7
    end

    it "まだ答えていない質問があれば、その質問へ戻す" do
      diagnosis.answers.create!(question: q1, choice: q1.choices.first)
      post diagnosis_completion_path(diagnosis)

      expect(response).to redirect_to(diagnosis_question_path(diagnosis, 2))
      expect(diagnosis.reload).to be_in_progress
    end
  end

  describe "結果画面" do
    it "7つの診断軸のスコアを表示する" do
      answer_all(diagnosis)
      diagnosis.complete!
      get diagnosis_path(diagnosis)

      expect(response).to have_http_status(:ok)
      DiagnosisAxis.find_each { |axis| expect(response.body).to include(axis.name) }
      expect(response.body).to include("#{diagnosis.diagnosis_scores.first.score}</span>")
    end

    it "他人の結果は見られない" do
      other = create(:diagnosis, :completed)
      get diagnosis_path(other)
      expect(response).to have_http_status(:not_found)
    end

    it "回答中の診断なら確認画面へ移動する" do
      get diagnosis_path(diagnosis)
      expect(response).to redirect_to(diagnosis_confirmation_path(diagnosis))
    end
  end

  describe "完了した診断" do
    before do
      answer_all(diagnosis)
      diagnosis.complete!
    end

    it "回答画面を開くと結果画面へ移動する" do
      get diagnosis_question_path(diagnosis, 1)
      expect(response).to redirect_to(diagnosis_path(diagnosis))
    end

    it "答え直しても保存されない" do
      post diagnosis_question_answer_path(diagnosis, 1), params: { choice_id: q1.choices.last.id }
      expect(response).to redirect_to(diagnosis_path(diagnosis))
      expect(diagnosis.answers.find_by(question: q1).choice).to eq q1.choices.first
    end
  end
end
