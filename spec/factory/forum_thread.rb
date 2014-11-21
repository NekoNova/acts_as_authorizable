FactoryGirl.define do
  factory :forum_thread do
    name 'Thread A'
    association :forum, factory: :forum
    association :moderator, factory: :user
  end
end