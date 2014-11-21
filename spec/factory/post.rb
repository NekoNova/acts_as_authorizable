FactoryGirl.define do
  factory :post do
    name  'My First Post'
    association :owner, factory: :user
    association :forum_thread, factory: :forum_thread
  end
end