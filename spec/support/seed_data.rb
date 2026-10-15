require Rails.root.join("db/seeds/question_loader")
require Rails.root.join("db/seeds/diagnosis_type_loader")

# 診断に必要な初期データ（質問・配点・総合タイプ）をテストの中で読み込む
module SeedDataHelper
  def load_seed_data
    QuestionLoader.call
    DiagnosisTypeLoader.call
  end
end

RSpec.configure do |config|
  config.include SeedDataHelper
end
