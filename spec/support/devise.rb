# リクエストスペックで sign_in(user) を使えるようにする
RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
end
