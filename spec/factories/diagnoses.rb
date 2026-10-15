FactoryBot.define do
  factory :diagnosis do
    user
    status { :in_progress }

    trait :completed do
      status { :completed }
      completed_at { Time.current }
    end
  end
end
