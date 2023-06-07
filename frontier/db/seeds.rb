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

user_3 = User.create_with(
  email: 'mkn_demo@example.com',
  password: 'mkn-demo-pass',
  password_confirmation: 'mkn-demo-pass'
).find_or_create_by!(username: "Demo User")

# Courses

course_1 = Course.create_with(
  year: 2023,
  semester: "fall",
  user: user_1
).find_or_create_by!(title: "DB internals")

course_2 = Course.create_with(
  year: 2023,
  semester: "fall",
  user: user_1
).find_or_create_by!(title: "Diffirential topology")

course_3 = Course.create_with(
  year: 2022,
  semester: "spring",
  user: user_2
).find_or_create_by!(title: "Ruby internals")

course_4 = Course.create_with(
  year: 2023,
  semester: "spring",
  user: user_2
).find_or_create_by!(title: "Erlang VM")

# Assignments

Assignment.find_or_create_by!(
  title: "RDBMS page caching",
  course: course_1
)

Assignment.find_or_create_by!(
  title: "RDBMS SQL parsing",
  course: course_1
)

Assignment.find_or_create_by!(
  title: "Manifolds",
  course: course_2
)

Assignment.find_or_create_by!(
  title: "Characteristic classes",
  course: course_2
)

Assignment.find_or_create_by!(
  title: "YARV: Yet Another Ruby VM",
  course: course_3
)

Assignment.find_or_create_by!(
  title: "Ruby method lookup",
  course: course_3
)

Assignment.find_or_create_by!(
  title: "Erlang processes",
  course: course_4
)

Assignment.find_or_create_by!(
  title: "Erlang memory model",
  course: course_4
)

# Submissions

Submission.find_or_create_by!(
  assignment: Assignment.first,
  url: "https://github.com/namespace/repo",
  branch: "master",
  author: "Yaroslav K"
)
