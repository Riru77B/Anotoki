# 初期データ: bin/rails db:seed で投入（何度実行してもよい）
require_relative "seeds/question_loader"
require_relative "seeds/diagnosis_type_loader"

QuestionLoader.call
DiagnosisTypeLoader.call
puts "診断軸 #{DiagnosisAxis.count} / 質問 #{Question.count} / 選択肢 #{Choice.count} / 配点 #{ChoiceScore.count} / 総合タイプ #{DiagnosisType.count}"
