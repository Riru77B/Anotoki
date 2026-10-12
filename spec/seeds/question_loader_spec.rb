require "rails_helper"
require Rails.root.join("db/seeds/question_loader")

RSpec.describe QuestionLoader do
  # 軸2つ・質問1問だけの小さなデータで動きを確かめる
  let(:axis_texts) do
    { "strength_scene" => "強み", "growth_hint" => "ヒント", "low_score_merit" => "低めの良さ", "flip_side" => "裏目",
      "hint_study" => "勉強", "hint_work" => "アルバイト", "hint_club" => "サークル", "hint_private" => "友人",
      "others_view" => "周りから見たあなた" }
  end
  let(:data) do
    {
      "axes" => [
        { "key" => "analysis", "name" => "分析力", "description" => "説明", "position" => 1, **axis_texts },
        { "key" => "action", "name" => "行動力", "description" => "説明", "position" => 2, **axis_texts }
      ],
      "questions" => [
        {
          "position" => 1, "axis" => "analysis", "content" => "最初の質問", "other_content" => "他者向けの質問",
          "choices" => [
            { "content" => "選択肢A", "scores" => { "analysis" => 5, "action" => 2 } },
            { "content" => "選択肢B", "scores" => { "action" => 4 } }
          ]
        }
      ]
    }
  end

  it "診断軸・質問・選択肢・配点を作る" do
    described_class.new(data).call
    expect([ DiagnosisAxis.count, Question.count, Choice.count, ChoiceScore.count ]).to eq [ 2, 1, 2, 3 ]
  end

  it "2回実行しても件数は増えず、IDも変わらない" do
    described_class.new(data).call
    choice_ids = Choice.ids
    described_class.new(data).call
    expect([ DiagnosisAxis.count, Question.count, Choice.count, ChoiceScore.count ]).to eq [ 2, 1, 2, 3 ]
    expect(Choice.ids).to eq choice_ids
  end

  it "文章や点数を変えると上書きされる" do
    described_class.new(data).call
    data["questions"][0]["content"] = "変更後の質問"
    data["questions"][0]["choices"][0]["scores"]["action"] = 3
    described_class.new(data).call

    expect(Question.first.content).to eq "変更後の質問"
    expect(ChoiceScore.find_by(diagnosis_axis: DiagnosisAxis.find_by(key: "action"), choice: Choice.find_by(content: "選択肢A")).score).to eq 3
  end

  it "YAML から消した配点は削除される" do
    described_class.new(data).call
    data["questions"][0]["choices"][0]["scores"].delete("action")
    described_class.new(data).call
    expect(Choice.find_by(content: "選択肢A").choice_scores.count).to eq 1
  end

  it "存在しない軸を書くとエラーになり、何も保存されない" do
    data["questions"][0]["choices"][1]["scores"] = { "unknown" => 3 }
    expect { described_class.new(data).call }.to raise_error(KeyError)
    expect(Question.count).to eq 0
  end
end
