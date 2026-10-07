# 自己診断の回答から、診断軸ごとのスコアを計算する（DB には保存しない）
#
# 1. 選んだ選択肢の点数を軸ごとに合計する（raw_score）
# 2. その軸で取れる最高点に対する割合（%）を出す
# 3. 全問をランダムに答えた場合の「割合の平均」を50点とし、
#    そこからのずれを「ばらつき（標準偏差）」で測って0〜100に変換する（偏差値と同じ考え方）
#    軸ごとに平均を50点にそろえるので、点の入りやすさの違いが結果に出にくい
class DiagnosisScoreCalculator
  CENTER = 50 # 平均的な答え方をした人のスコア
  SPREAD = 15 # 平均から「ばらつき1つ分」離れたら何点動かすか
  FLOOR = 10  # 最低点（低い点が「悪い」に見えないように下限を付ける）

  Result = Data.define(:diagnosis_axis, :raw_score, :score)

  # choice_ids: 選んだ選択肢の ID（1問につき1つ）
  def initialize(choice_ids)
    @choice_ids = choice_ids
  end

  # 戻り値: Result の配列（診断軸の表示順）
  def call
    DiagnosisAxis.all.map do |axis|
      raw = raw_scores.fetch(axis.id, 0)
      Result.new(diagnosis_axis: axis, raw_score: raw, score: display_score(axis.id, raw))
    end
  end

  private

  def raw_scores
    @raw_scores ||= ChoiceScore.where(choice_id: @choice_ids).group(:diagnosis_axis_id).sum(:score)
  end

  def display_score(axis_id, raw)
    stats = axis_stats.fetch(axis_id)
    return CENTER if stats[:max].zero? || stats[:sd].zero?

    percent = raw * 100.0 / stats[:max]
    value = CENTER + (percent - stats[:mean]) / stats[:sd] * SPREAD
    value.round.clamp(FLOOR, 100)
  end

  # 軸ごとの { max: 最高点, mean: ランダム回答の割合の平均, sd: そのばらつき }
  def axis_stats
    @axis_stats ||= begin
      questions = Question.unscope(:order).includes(choices: :choice_scores).to_a
      DiagnosisAxis.all.to_h { |axis| [ axis.id, stats_for(axis.id, questions) ] }
    end
  end

  def stats_for(axis_id, questions)
    per_question = questions.map do |question|
      question.choices.map { |choice| choice.choice_scores.find { |s| s.diagnosis_axis_id == axis_id }&.score || 0 }
    end
    max = per_question.sum(&:max)
    return { max: 0, mean: 0, sd: 0 } if max.zero?

    mean = 0.0
    variance = 0.0
    per_question.each do |values|
      percents = values.map { |v| v * 100.0 / max }
      mu = percents.sum / percents.size
      mean += mu
      variance += percents.sum { |p| (p - mu)**2 } / percents.size
    end
    { max: max, mean: mean, sd: Math.sqrt(variance) }
  end
end
