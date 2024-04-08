# frozen_string_literal: true

# Users

user_1 = User.create_with(
  email: "admin@example.com",
  password: "password",
  password_confirmation: "password"
).find_or_create_by!(username: "admin")

# Courses

course_1 = Course.create_with(
  year: Time.zone.now.year,
  semester: Utilities::DateTime.current_semester,
  user: user_1,
  group: "mkn-1"
).find_or_create_by!(title: "DB internals")

course_2 = Course.create_with(
  year: Time.zone.now.year,
  semester: Utilities::DateTime.current_semester,
  user: user_1,
  group: "mkn-2"
).find_or_create_by!(title: "Diffirential topology")

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
