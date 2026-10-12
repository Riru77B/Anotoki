class AddOthersViewToDiagnosisAxes < ActiveRecord::Migration[8.1]
  def change
    # 周りから見たあなたは…（「自分では気づいていない強み」に、周りの人の目線で表示する文章）
    add_column :diagnosis_axes, :others_view, :text
  end
end
