FactoryBot.define do
  factory :answer do
    diagnosis
    question
    choice { association :choice, question: question }
  end
end
