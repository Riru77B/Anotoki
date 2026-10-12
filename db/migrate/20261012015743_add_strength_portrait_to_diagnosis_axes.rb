class AddStrengthPortraitToDiagnosisAxes < ActiveRecord::Migration[8.1]
  def change
    # この強みを持つあなたは…（強みTOP3に表示する、その強みが表す人となり）
    add_column :diagnosis_axes, :strength_portrait, :text
  end
end
