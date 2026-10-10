class AddReflectionPromptToDiagnosisAxes < ActiveRecord::Migration[8.1]
  def change
    # 振り返ってみよう（強みTOP3 に表示し、自分の経験を思い出すきっかけにする問いかけ）
    add_column :diagnosis_axes, :reflection_prompt, :text
  end
end
