# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "Test User" }
    password { "correct-horse-battery-staple" }
    is_admin { false }

    trait :admin do
      is_admin { true }
    end

    trait :oauth do
      password { nil }
      provider { "authentik" }
      sequence(:uid) { |n| "uid-#{n}" }
    end
  end
end
