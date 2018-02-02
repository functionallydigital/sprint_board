FactoryGirl.define do
  factory :project do
    name 'Super Awesome Project'
    description 'A really cool project'
    start_date Date.today
    end_date Date.today + 1.month
    sprint_length 2
  end
end
