# テストの中で create(:user) のように FactoryBot を短く書けるようにする
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
