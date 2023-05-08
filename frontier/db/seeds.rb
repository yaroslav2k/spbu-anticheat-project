# frozen_string_literal: true

return unless Rails.env.development?

# Users

user_1 = User.create_with(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password'
).find_or_create_by!(username: "Yaroslav K")

user_2 = User.create_with(
  email: 'admin2@example.com',
  password: 'password2',
  password_confirmation: 'password2'
).find_or_create_by!(username: "Nikolay B")

# Assignments

Assignment.find_or_create_by!(
  title: "RDBMS page caching",
  user: user_1
)

Assignment.find_or_create_by!(
  title: "RDBMS SQL parsing",
  user: user_1
)

Assignment.find_or_create_by!(
  title: "RDBMS write-ahead-log",
  user: user_1
)

Assignment.find_or_create_by!(
  title: "RDBMS transaction management",
  user: user_1
)

Assignment.find_or_create_by!(
  title: "Consistent hashing",
  user: user_1
)

Assignment.find_or_create_by!(
  title: "Java enums",
  user: user_2
)

Assignment.find_or_create_by!(
  title: "Java generics",
  user: user_2
)

# Submissions

5.times do |i|
  Submission.find_or_create_by!(
    assignment: Assignment.find_by(title: "Consistent hashing"),
    url: "https://github.com/hashing-repo-#{i}",
    author: "Kidr Livanskiy"
  )
end

2.times do |i|
  Submission.find_or_create_by!(
    assignment: Assignment.find_by(title: "RDBMS transaction management"),
    url: "https://github.com/rdbms-repo-#{i}",
    author: "Ian Curtis"
  )
end
