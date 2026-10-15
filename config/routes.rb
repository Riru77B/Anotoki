Rails.application.routes.draw do
  root "static_pages#top"
  get "terms", to: "static_pages#terms", as: :terms       # 利用規約
  get "privacy", to: "static_pages#privacy", as: :privacy # プライバシーポリシー

  devise_for :users
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  resource :mypage, only: :show

  # 他者診断の依頼用 URL
  #   POST /diagnosis_invitation   URL を作る（すでにあればそのまま）
  #   GET  /invitations/:token     URL を開いたときの入口（ログイン不要）
  resource :diagnosis_invitation, only: :create
  get "invitations/:token", to: "invitations#show", as: :invitation

  # 他者診断の回答（ログイン不要。依頼用 URL の下にまとめる）
  #   POST /invitations/:token/other_diagnosis                     回答をはじめる（途中なら続きから）
  #   GET  /invitations/:token/questions/:position                 1問ずつの回答画面
  #   POST /invitations/:token/questions/:position/answer          回答を保存
  #   GET  /invitations/:token/confirmation                        確認画面
  #   POST /invitations/:token/completion                          回答を送信する
  #   GET  /invitations/:token/thanks                              ありがとう画面
  scope "invitations/:token", module: :invitations, as: :invitation do
    resource :other_diagnosis, only: :create
    resources :questions, only: :show, param: :position do
      resource :answer, only: :create
    end
    resource :confirmation, only: :show
    resource :completion, only: :create
    resource :thanks, only: :show
  end

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
