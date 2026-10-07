class AddDiagnosisTypeToDiagnoses < ActiveRecord::Migration[8.1]
  def change
    # 診断が完了したときに決まる総合タイプ（回答中は空）
    add_reference :diagnoses, :diagnosis_type, foreign_key: true
  end
end
