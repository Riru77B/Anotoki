require "rails_helper"
require Rails.root.join("db/seeds/question_loader")

# db/seeds/questions.yml の中身が診断のルールを守っているかを確かめる
RSpec.describe "自己診断の初期データ（questions.yml）" do
  before { QuestionLoader.call }

  it "診断軸は7つ" do
    expect(DiagnosisAxis.pluck(:key)).to eq %w[analysis problem_solving action cooperation learning persistence creativity]
  end

  it "どの診断軸にも、強み・ヒント・低めのときの良さ・裏目に出る可能性・思い出しのヒント（4場面）・周りから見たあなた・この強みを持つあなたの文章がある" do
    DiagnosisAxis.find_each do |axis|
      expect([ axis.strength_scene, axis.growth_hint, axis.low_score_merit, axis.flip_side, axis.others_view, axis.strength_portrait ] + axis.recall_hints.map(&:last)).to all(be_present), axis.name
    end
  end

  it "質問は35問で、番号は1〜35" do
    expect(Question.pluck(:position)).to eq (1..35).to_a
  end

  it "各診断軸の質問はちょうど5問ずつ" do
    expect(Question.unscope(:order).group(:diagnosis_axis_id).count.values).to all(eq 5)
  end

  it "どの質問にも、他者診断の問題文がある" do
    expect(Question.pluck(:other_content)).to all(be_present)
  end

  it "どの質問にも選択肢が5つある" do
    expect(Question.includes(:choices).map { |q| q.choices.size }).to all(eq 5)
  end

  it "どの選択肢も、点が入る軸は1〜3つで、点数は1〜5点" do
    Choice.includes(:choice_scores, :question).find_each do |choice|
      scores = choice.choice_scores.map(&:score)
      label = "Q#{choice.question.position}-#{choice.position}"
      expect(scores.size).to be_between(1, 3), "#{label} の軸の数が #{scores.size}"
      expect(scores).to all(be_between(1, 5)), "#{label} の点数が #{scores}"
    end
  end

  it "どの質問にも、その質問の軸で5点が入る選択肢がある" do
    Question.includes(choices: :choice_scores).find_each do |question|
      own_scores = question.choices.flat_map(&:choice_scores).select { |s| s.diagnosis_axis_id == question.diagnosis_axis_id }
      expect(own_scores.map(&:score)).to include(5), "Q#{question.position} に5点の選択肢がない"
    end
  end
end
