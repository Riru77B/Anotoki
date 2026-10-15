class RemoveFlipSideFromDiagnosisAxes < ActiveRecord::Migration[8.1]
  def change
    # 強みの裏返し。画面で使っていないので削除する
    remove_column :diagnosis_axes, :flip_side, :text
  end
end
