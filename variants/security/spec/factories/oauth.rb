FactoryGirl.define do
  factory :oauth, class: OmniAuth::AuthHash do
    provider :facebook
    uid { Faker::Internet.password(32) }
    info { build(:oauth_info) }

    trait :with_extra do
      extra { build(:oauth_extra) }
    end
  end

  factory :oauth_info, class: OmniAuth::AuthHash::InfoHash do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    image { Faker::Avatar.image }
  end

  factory :oauth_extra, class: OmniAuth::AuthHash do
    raw_info { build(:oauth_raw_info) }
  end

  factory :oauth_raw_info, class: OmniAuth::AuthHash do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    name { "#{first_name} #{last_name}".strip }
  end
end
