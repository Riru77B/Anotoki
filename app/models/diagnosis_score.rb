# 自己診断1回分の、診断軸ごとのスコア
class DiagnosisScore < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :diagnosis_axis

  validates :raw_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :score, presence: true, inclusion: { in: 0..100 }
  validates :diagnosis_axis_id, uniqueness: { scope: :diagnosis_id }

  # 強みTOP3の前置きを変える点数の区切り
  OUTSTANDING_SCORE = 75 # これ以上なら「際立っている強み」
  CLEAR_SCORE = 60       # これ以上なら「はっきりとした強み」

  # 強みTOP3の前置き。点数が高いほど強い言い方にする（低くても「悪い」とは言わない）
  # rank: TOP3の順位（1〜3）
  def strength_lead(rank)
    name = diagnosis_axis.name
    if score >= OUTSTANDING_SCORE
      "#{name}は、あなたの中で際立っている強みです。"
    elsif score >= CLEAR_SCORE
      "#{name}は、あなたのはっきりとした強みです。"
    else
      "#{name}は、あなたの中で比べると#{"一番" if rank == 1}よく表れている力です。経験を重ねるほど、さらに伸びていく強みです。"
    end
  end
end
