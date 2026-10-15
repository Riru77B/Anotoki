# 総合タイプ。スコア上位2軸の組み合わせ（21通り）か、バランス型で決まる
class DiagnosisType < ApplicationRecord
  belongs_to :primary_axis, class_name: "DiagnosisAxis", optional: true
  belongs_to :secondary_axis, class_name: "DiagnosisAxis", optional: true
  has_many :diagnoses, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
  validates :description, presence: true
  validates :position, presence: true
  validates :primary_axis, :secondary_axis, presence: true, unless: :balanced?
  validates :secondary_axis_id, uniqueness: { scope: :primary_axis_id }, unless: :balanced?
  validate :axes_in_display_order, unless: :balanced?

  default_scope { order(:position) }

  private

  # 同じ組み合わせが2通りに登録されないよう、primary は表示順で前の軸にする
  def axes_in_display_order
    return if primary_axis.nil? || secondary_axis.nil?
    return if primary_axis.position < secondary_axis.position

    errors.add(:secondary_axis, "は primary_axis より後の診断軸にしてください")
  end
end
