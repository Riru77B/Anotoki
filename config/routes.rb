Rails.application.routes.draw do
  root "static_pages#top"

  devise_for :users
  resource :mypage, only: :show

  # 自己診断
  #   POST /diagnoses                                       診断をはじめる（途中の診断があれば続きから）
  #   GET  /diagnoses/:diagnosis_id/questions/:position     1問ずつの回答画面
  #   POST /diagnoses/:diagnosis_id/questions/:position/answer  回答を保存
  #   GET  /diagnoses/:diagnosis_id/confirmation            全問回答後の確認画面
  #   POST /diagnoses/:diagnosis_id/completion              スコアを計算して診断を完了にする
  #   GET  /diagnoses/:id                                   結果画面
  #   DELETE /diagnoses/:id                                 回答中の診断を削除（最初からやり直す）
  resources :diagnoses, only: %i[create show destroy] do
    scope module: :diagnoses do
      resources :questions, only: :show, param: :position do
        resource :answer, only: :create
      end
      resource :confirmation, only: :show
      resource :completion, only: :create
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
