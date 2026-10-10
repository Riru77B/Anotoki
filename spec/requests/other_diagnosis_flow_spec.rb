require "rails_helper"

RSpec.describe "他者診断の回答（ログインなし）", type: :request do
  before { load_seed_data }

  let(:owner) { create(:user, name: "たろう") }
  let(:invitation) { create(:diagnosis_invitation, user: owner) }
  let(:token) { invitation.token }
  let(:q1) { Question.find_by!(position: 1) }

  def start!
    post invitation_other_diagnosis_path(token)
  end

  def answer!(question, choice = question.choices.first)
    post invitation_question_answer_path(token, question.position), params: { choice_id: choice.id }
  end

  def answer_all!
    Question.includes(:choices).find_each { |q| answer!(q) }
  end

  describe "回答をはじめる" do
    it "ログインしていなくても、他者診断を作って1問目へ移動する" do
      expect { start! }.to change(invitation.other_diagnoses, :count).by(1)
      expect(response).to redirect_to(invitation_question_path(token, 1))
    end

    it "同じブラウザで続けて押すと、新しく作らずに続きから再開する" do
      start!
      answer!(q1)
      expect { start! }.not_to change(OtherDiagnosis, :count)
      expect(response).to redirect_to(invitation_question_path(token, 2))
    end

    it "入口ページに「続きから回答する」と表示する" do
      start!
      answer!(q1)
      get invitation_path(token)
      expect(response.body).to include("続きから回答する（1 / 35 問回答済み）")
    end
  end

  describe "回答画面" do
    it "一番上に「〇〇さんは」と、他者向けの問題文と選択肢を表示する" do
      start!
      q4 = Question.find_by!(position: 4)
      get invitation_question_path(token, 4)
      expect(response.body).to include("たろうさんは", q4.other_content, "前に行って良かったお店から選ぶ")
      expect(response.body).not_to include("自分が前に行って良かったお店から選ぶ")
    end

    it "回答をはじめていないブラウザでは、入口ページに戻す" do
      create(:other_diagnosis, diagnosis_invitation: invitation) # 別の人の回答中の他者診断
      get invitation_question_path(token, 1)
      expect(response).to redirect_to(invitation_path(token))
    end
  end

  describe "回答の保存" do
    before { start! }

    it "保存して次の質問へ。答え直しは上書きされる" do
      answer!(q1, q1.choices.first)
      expect(response).to redirect_to(invitation_question_path(token, 2))
      expect { answer!(q1, q1.choices.last) }.not_to change(OtherAnswer, :count)
      expect(OtherAnswer.find_by(question: q1).choice).to eq q1.choices.last
    end

    it "別の質問の選択肢は選べない" do
      expect { answer!(q1, Question.find_by!(position: 2).choices.first) }.not_to change(OtherAnswer, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "確認と送信" do
    before { start! }

    it "まだ答えていない質問があれば、確認画面からその質問へ戻す" do
      answer!(q1)
      get invitation_confirmation_path(token)
      expect(response).to redirect_to(invitation_question_path(token, 2))
    end

    it "全問答えて送信すると、スコアを保存してありがとう画面へ移動する" do
      answer_all!
      expect(response).to redirect_to(invitation_confirmation_path(token))

      post invitation_completion_path(token)
      other = invitation.other_diagnoses.last
      expect(other).to be_completed
      expect(other.scores.count).to eq 7
      expect(response).to redirect_to(invitation_thanks_path(token))
    end

    it "送信したあとにもう一度はじめると、新しい回答になる" do
      answer_all!
      post invitation_completion_path(token)
      expect { start! }.to change(OtherDiagnosis, :count).by(1)
      expect(response).to redirect_to(invitation_question_path(token, 1))
    end
  end

  describe "ありがとう画面" do
    it "ログインしていない人には、新規登録への案内を表示する" do
      get invitation_thanks_path(token)
      expect(response.body).to include("回答ありがとうございました", "あなたも自己診断してみませんか？")
    end
  end

  describe "依頼した本人" do
    before { sign_in owner }

    it "入口ページでは、自分の依頼用 URL だと表示し、回答をはじめるボタンを出さない" do
      get invitation_path(token)
      expect(response.body).to include("これはあなたの依頼用 URL です")
      expect(response.body).not_to include("回答をはじめる")
    end

    it "回答をはじめようとしても、他者診断は作られない" do
      expect { start! }.not_to change(OtherDiagnosis, :count)
      expect(response).to redirect_to(invitation_path(token))
    end
  end
end
