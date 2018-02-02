FactoryGirl.define do
  factory :user do
    first_name 'Joe'
    last_name 'Bloggs'
    email 'joe.bloggs@test.co.uk'
    password "P$ssword10"
    password_confirmation "P$ssword10"    
  end
end
