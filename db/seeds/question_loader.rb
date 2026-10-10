# db/seeds/questions.yml を読み込んで、診断軸・質問・選択肢・配点を DB に入れる。
# 何度実行しても同じ結果になる（番号で探して上書きするので ID は変わらない）。
class QuestionLoader
  DEFAULT_PATH = Rails.root.join("db/seeds/questions.yml")
  AXIS_ATTRIBUTES = %w[name description position strength_scene growth_hint low_score_merit flip_side reflection_prompt].freeze

  def self.call(path = DEFAULT_PATH)
    new(YAML.load_file(path)).call
  end

  def initialize(data)
    @data = data
  end

  def call
    ActiveRecord::Base.transaction do
      axes = load_axes
      @data.fetch("questions").each { |attrs| load_question(attrs, axes) }
    end
  end

  private

  # 戻り値は { "analysis" => DiagnosisAxis, ... }
  def load_axes
    @data.fetch("axes").to_h do |attrs|
      axis = DiagnosisAxis.find_or_initialize_by(key: attrs.fetch("key"))
      axis.update!(attrs.slice(*AXIS_ATTRIBUTES))
      [ axis.key, axis ]
    end
  end

  def load_question(attrs, axes)
    question = Question.find_or_initialize_by(position: attrs.fetch("position"))
    question.update!(diagnosis_axis: axes.fetch(attrs.fetch("axis")), content: attrs.fetch("content"))

    attrs.fetch("choices").each.with_index(1) do |choice_attrs, position|
      choice = question.choices.find_or_initialize_by(position: position)
      choice.update!(content: choice_attrs.fetch("content"))
      load_scores(choice, choice_attrs.fetch("scores"), axes)
    end
  end

  def load_scores(choice, scores, axes)
    scores.each do |axis_key, score|
      choice.choice_scores.find_or_initialize_by(diagnosis_axis: axes.fetch(axis_key)).update!(score: score)
    end
    # YAML から消えた軸の配点は削除する
    choice.choice_scores.where.not(diagnosis_axis: scores.keys.map { |key| axes.fetch(key) }).destroy_all
  end
end
