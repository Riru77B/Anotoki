require "rails_helper"

RSpec.describe DiagnosisType, type: :model do
  let(:first_axis) { create(:diagnosis_axis, position: 1) }
  let(:second_axis) { create(:diagnosis_axis, position: 2) }

  it "2つの診断軸の組み合わせで有効" do
    expect(build(:diagnosis_type, primary_axis: first_axis, secondary_axis: second_axis)).to be_valid
  end

  it "バランス型は診断軸がなくても有効" do
    expect(build(:diagnosis_type, :balanced)).to be_valid
  end

  it "バランス型でなければ2つの診断軸が必要" do
    expect(build(:diagnosis_type, primary_axis: first_axis, secondary_axis: nil)).not_to be_valid
  end

  it "同じ組み合わせは登録できない" do
    create(:diagnosis_type, primary_axis: first_axis, secondary_axis: second_axis)
    expect(build(:diagnosis_type, primary_axis: first_axis, secondary_axis: second_axis)).not_to be_valid
  end

  it "primary は表示順で前の診断軸にする" do
    type = build(:diagnosis_type, primary_axis: second_axis, secondary_axis: first_axis)
    expect(type).not_to be_valid
    expect(type.errors[:secondary_axis]).to be_present
  end
end
