# 自己診断のスコアと、他者診断（回答してくれた全員）の平均スコアを、診断軸ごとに比べる
class ScoreComparison
  # 周りの平均が自分より何点以上高ければ「自分では気づいていない強み」とするか
  HIDDEN_STRENGTH_GAP = 10

  Row = Data.define(:diagnosis_axis, :self_score, :other_score) do
    def gap
      other_score - self_score
    end
  end

  def initialize(diagnosis)
    @diagnosis = diagnosis
  end

  # 回答（送信）してくれた人数
  def respondent_count
    completed_other_diagnoses.count
  end

  def any_respondents?
    respondent_count.positive?
  end

  # 診断軸の表示順に、自分のスコア・周りの平均スコアを並べる（回答がなければ空）
  def rows
    return [] unless any_respondents?

    @rows ||= self_scores.map do |score|
      Row.new(
        diagnosis_axis: score.diagnosis_axis,
        self_score: score.score,
        other_score: other_averages.fetch(score.diagnosis_axis_id).round
      )
    end
  end

  # 周りの平均が自分より HIDDEN_STRENGTH_GAP 点以上高い軸（差の大きい順）
  def hidden_strengths
    rows.select { |row| row.gap >= HIDDEN_STRENGTH_GAP }.sort_by { |row| [ -row.gap, row.diagnosis_axis.position ] }
  end

  private

  def completed_other_diagnoses
    invitation = @diagnosis.user.diagnosis_invitation
    invitation ? invitation.other_diagnoses.completed : OtherDiagnosis.none
  end

  def self_scores
    @diagnosis.diagnosis_scores.includes(:diagnosis_axis).sort_by { |s| s.diagnosis_axis.position }
  end

  # { 診断軸ID => 周りの平均スコア }
  def other_averages
    @other_averages ||= OtherDiagnosisScore
      .where(other_diagnosis: completed_other_diagnoses)
      .group(:diagnosis_axis_id)
      .average(:score)
  end
end
