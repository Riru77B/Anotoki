require "rails_helper"

RSpec.describe DiagnosisAxis, type: :model do
  it "key・名前・説明・表示順があれば有効" do
    expect(build(:diagnosis_axis)).to be_valid
  end

  it "key は重複できない" do
    create(:diagnosis_axis, key: "analysis")
    expect(build(:diagnosis_axis, key: "analysis")).not_to be_valid
  end

  it "質問がある軸は削除できない" do
    axis = create(:diagnosis_axis)
    create(:question, diagnosis_axis: axis)
    expect(axis.destroy).to be false
  end
end
