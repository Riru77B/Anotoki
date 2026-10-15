# db/seeds/diagnosis_types.yml を読み込んで、総合タイプを DB に入れる。
# 診断軸が先に入っている必要がある（QuestionLoader のあとに実行する）。
# 何度実行しても同じ結果になる（key で探して上書きする）。
class DiagnosisTypeLoader
  DEFAULT_PATH = Rails.root.join("db/seeds/diagnosis_types.yml")

  def self.call(path = DEFAULT_PATH)
    new(YAML.load_file(path)).call
  end

  def initialize(data)
    @data = data
  end

  def call
    axes = DiagnosisAxis.all.index_by(&:key)

    ActiveRecord::Base.transaction do
      @data.fetch("types").each do |attrs|
        primary_key, secondary_key = attrs["axes"]
        type = DiagnosisType.find_or_initialize_by(key: attrs.fetch("key"))
        type.update!(
          name: attrs.fetch("name"),
          description: attrs.fetch("description"),
          position: attrs.fetch("position"),
          balanced: attrs.fetch("balanced", false),
          primary_axis: primary_key && axes.fetch(primary_key),
          secondary_axis: secondary_key && axes.fetch(secondary_key)
        )
      end
    end
  end
end
