require "rails_helper"
require Rails.root.join("db/seeds/question_loader")

RSpec.describe "自己診断の回答の流れ", type: :request do
  before { QuestionLoader.call }

  let(:user) { create(:user) }
  let(:q1) { Question.find_by!(position: 1) }

  def answer!(diagnosis, question, choice = question.choices.first)
    post diagnosis_question_answer_path(diagnosis, question.position), params: { choice_id: choice.id }
  end

  describe "診断をはじめる" do
    it "ログインしていなければログイン画面へ" do
      post diagnoses_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "新しく診断を作って1問目へ移動する" do
      sign_in user
      expect { post diagnoses_path }.to change(user.diagnoses, :count).by(1)
      expect(response).to redirect_to(diagnosis_question_path(user.diagnoses.last, 1))
    end

    it "回答中の診断があれば、まだ答えていない質問から再開する" do
      sign_in user
      diagnosis = create(:diagnosis, user: user)
      diagnosis.answers.create!(question: q1, choice: q1.choices.first)

      expect { post diagnoses_path }.not_to change(Diagnosis, :count)
      expect(response).to redirect_to(diagnosis_question_path(diagnosis, 2))
    end
  end

  describe "回答画面" do
    let(:diagnosis) { create(:diagnosis, user: user) }

    before { sign_in user }

    it "質問と選択肢を表示する" do
      get diagnosis_question_path(diagnosis, 1)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(q1.content, q1.choices.first.content)
    end

    it "他人の診断は開けない" do
      other = create(:diagnosis)
      get diagnosis_question_path(other, 1)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "回答の保存" do
    let(:diagnosis) { create(:diagnosis, user: user) }

    before { sign_in user }

    it "回答を保存して次の質問へ移動する" do
      expect { answer!(diagnosis, q1) }.to change(diagnosis.answers, :count).by(1)
      expect(response).to redirect_to(diagnosis_question_path(diagnosis, 2))
    end

    it "答え直すと上書きされ、回答は増えない" do
      answer!(diagnosis, q1, q1.choices.first)
      expect { answer!(diagnosis, q1, q1.choices.last) }.not_to change(Answer, :count)
      expect(diagnosis.answers.find_by(question: q1).choice).to eq q1.choices.last
    end

    it "別の質問の選択肢は選べない" do
      other_choice = Question.find_by!(position: 2).choices.first
      expect { answer!(diagnosis, q1, other_choice) }.not_to change(Answer, :count)
      expect(response).to have_http_status(:not_found)
    end

    it "最後の質問に答えると確認画面へ移動する" do
      Question.where.not(position: 35).find_each { |q| diagnosis.answers.create!(question: q, choice: q.choices.first) }
      answer!(diagnosis, Question.find_by!(position: 35))
      expect(response).to redirect_to(diagnosis_confirmation_path(diagnosis))
    end
  end

  describe "確認画面" do
    let(:diagnosis) { create(:diagnosis, user: user) }

    before { sign_in user }

    it "まだ答えていない質問があれば、その質問へ戻す" do
      diagnosis.answers.create!(question: q1, choice: q1.choices.first)
      get diagnosis_confirmation_path(diagnosis)
      expect(response).to redirect_to(diagnosis_question_path(diagnosis, 2))
    end

    it "全問答えていれば、回答の一覧を表示する" do
      Question.find_each { |q| diagnosis.answers.create!(question: q, choice: q.choices.first) }
      get diagnosis_confirmation_path(diagnosis)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("すべての質問に回答しました", q1.choices.first.content)
    end
  end
end
