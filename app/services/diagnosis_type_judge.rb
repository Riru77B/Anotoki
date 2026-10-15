# 7軸のスコアから総合タイプを決める
#
# - 一番高いスコアと一番低いスコアの差が BALANCE_SPREAD 以下なら、バランス型（オールラウンダー）
# - それ以外は、スコア上位2軸の組み合わせのタイプ（同点なら診断軸の表示順が前の軸を優先）
class DiagnosisTypeJudge
  # バランス型にする差の上限。ランダムに答えた人のうち約3%がバランス型になる値（企画時のシミュレーション）
  BALANCE_SPREAD = 20

  # scores: スコア（diagnosis_axis と score を持つもの。DiagnosisScore や DiagnosisScoreCalculator::Result）
  def initialize(scores)
    @scores = scores
  end

  def call
    values = @scores.map(&:score)
    return DiagnosisType.find_by!(balanced: true) if values.max - values.min <= BALANCE_SPREAD

    first, second = @scores.sort_by { |s| [ -s.score, s.diagnosis_axis.position ] }.first(2).map(&:diagnosis_axis)
    primary, secondary = [ first, second ].sort_by(&:position)
    DiagnosisType.find_by!(primary_axis: primary, secondary_axis: secondary)
  end
end
