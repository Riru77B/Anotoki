FactoryBot.define do
  factory :other_answer do
    other_diagnosis
    question
    choice { association :choice, question: question }
  end
end
