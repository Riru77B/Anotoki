require "rails_helper"
require Rails.root.join("db/seeds/question_loader")
require Rails.root.join("db/seeds/diagnosis_type_loader")

# db/seeds/diagnosis_types.yml の中身を確かめる
RSpec.describe "総合タイプの初期データ（diagnosis_types.yml）" do
  before do
    QuestionLoader.call
    DiagnosisTypeLoader.call
  end

  it "7軸から2つを選ぶ21通りの組み合わせが、すべて1つずつある" do
    expected = DiagnosisAxis.all.to_a.combination(2).map { |a, b| [ a.id, b.id ] }
    actual = DiagnosisType.where(balanced: false).pluck(:primary_axis_id, :secondary_axis_id)
    expect(actual).to match_array(expected)
  end

  it "バランス型がちょうど1つある" do
    expect(DiagnosisType.where(balanced: true).pluck(:key)).to eq [ "balanced" ]
  end

  it "2回読み込んでも件数は増えない" do
    expect { DiagnosisTypeLoader.call }.not_to change(DiagnosisType, :count)
  end
end
