require "rails_helper"

RSpec.describe "自己診断の完了と結果", type: :request do
  before do
    load_seed_data
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

    it "レーダーチャート用に、軸の名前とスコアを表示順で渡す" do
      answer_all(diagnosis)
      diagnosis.complete!
      get diagnosis_path(diagnosis)

      scores = diagnosis.diagnosis_scores.includes(:diagnosis_axis).sort_by { |s| s.diagnosis_axis.position }
      html = Nokogiri::HTML(response.body)
      chart = html.at_css('[data-controller="radar-chart"]')
      expect(JSON.parse(chart["data-radar-chart-labels-value"])).to eq %w[分析力 課題解決力 行動力 協調性 学習力 継続力 発想力]
      expect(JSON.parse(chart["data-radar-chart-scores-value"])).to eq scores.map(&:score)
    end

    it "強みTOP3を、スコアの高い順に表示する" do
      answer_all(diagnosis)
      diagnosis.complete!
      get diagnosis_path(diagnosis)

      top = diagnosis.top_strengths.map { |s| s.diagnosis_axis.name }
      section = Nokogiri::HTML(response.body).css("section").find { |sec| sec.text.include?("あなたの強み TOP3") }
      expect(section.css("li").map { |li| li.at_css("div p").text }).to eq top
    end

    it "強みTOP3には、強みとして働く場面・もっと活かすヒント・振り返りの問いかけを表示する" do
      answer_all(diagnosis)
      diagnosis.complete!
      get diagnosis_path(diagnosis)

      diagnosis.top_strengths.each do |score|
        expect(response.body).to include(score.diagnosis_axis.strength_scene, score.diagnosis_axis.growth_hint, score.diagnosis_axis.reflection_prompt)
      end
    end

    it "下位2つの軸の、低めのときの良さを表示する（TOP3の軸は出さない）" do
      answer_all(diagnosis)
      diagnosis.complete!
      get diagnosis_path(diagnosis)

      section = Nokogiri::HTML(response.body).css("section").find { |sec| sec.text.include?("あなたのこんな良さ") }
      diagnosis.lower_scores.each { |score| expect(section.text).to include(score.diagnosis_axis.low_score_merit) }
      diagnosis.top_strengths.each { |score| expect(section.text).not_to include(score.diagnosis_axis.low_score_merit) }
    end

    it "総合タイプの名前と説明を表示する" do
      answer_all(diagnosis)
      diagnosis.complete!
      get diagnosis_path(diagnosis)

      type = diagnosis.reload.diagnosis_type
      text = Nokogiri::HTML(response.body).text.gsub(/\s+/, "")
      expect(text).to include("あなたのタイプ", type.name, type.description)
    end

    it "オールラウンダーなら、上位2つの軸も添える" do
      answer_all(diagnosis)
      diagnosis.complete!
      diagnosis.update!(diagnosis_type: DiagnosisType.find_by!(balanced: true))
      get diagnosis_path(diagnosis)

      top2 = diagnosis.top_strengths(2).map { |s| s.diagnosis_axis.name }
      text = Nokogiri::HTML(response.body).text.gsub(/\s+/, " ")
      expect(text.delete(" ")).to include("オールラウンダータイプ")
      expect(text).to include("中でも #{top2[0]} と #{top2[1]} が光っています")
    end

    describe "周りから見たあなた" do
      before do
        answer_all(diagnosis)
        diagnosis.complete!
      end

      def add_other_answers(choice_index)
        invitation = user.diagnosis_invitation || create(:diagnosis_invitation, user: user)
        other = create(:other_diagnosis, diagnosis_invitation: invitation)
        Question.includes(:choices).find_each { |q| other.answers.create!(question: q, choice: q.choices[choice_index]) }
        other.complete!
      end

      it "まだ誰も回答していなければ、依頼用 URL の案内を表示する" do
        get diagnosis_path(diagnosis)
        expect(response.body).to include("まだ誰も回答していません", "依頼用の URL を作る")
      end

      it "回答があれば、人数・比較表・気づいていない強みを表示する" do
        add_other_answers(2)
        add_other_answers(4)
        get diagnosis_path(diagnosis)

        comparison = ScoreComparison.new(diagnosis)
        text = Nokogiri::HTML(response.body).text.gsub(/\s+/, " ")
        expect(text).to include("2人が回答してくれました")
        comparison.rows.each { |row| expect(text).to include("#{row.diagnosis_axis.name} #{row.self_score} #{row.other_score}") }
        if comparison.hidden_strengths.any?
          expect(text).to include("周りからは #{comparison.hidden_strengths.first.other_score} と見られています")
        else
          expect(text).to include("大きなずれはありませんでした")
        end
      end

      it "「こんな良さ」の軸が気づいていない強みにも出ていれば、両方をつなげて伝える" do
        add_other_answers(3)
        comparison = ScoreComparison.new(diagnosis)
        hidden_axes = comparison.hidden_strengths.map(&:diagnosis_axis)
        get diagnosis_path(diagnosis)

        text = Nokogiri::HTML(response.body).text.gsub(/\s+/, " ")
        diagnosis.lower_scores.each do |score|
          name = score.diagnosis_axis.name
          if hidden_axes.include?(score.diagnosis_axis)
            expect(text).to include("#{name}は、自分では控えめだと思っていても…", "#{name}がある人に見られています")
          else
            expect(text).to include("#{name}が控えめなあなたは…")
          end
        end
      end

      it "回答があれば、レーダーチャートに周りのスコアも渡す" do
        add_other_answers(3)
        get diagnosis_path(diagnosis)
        chart = Nokogiri::HTML(response.body).at_css('[data-controller="radar-chart"]')
        expect(JSON.parse(chart["data-radar-chart-other-scores-value"])).to eq ScoreComparison.new(diagnosis).rows.map(&:other_score)
      end
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
