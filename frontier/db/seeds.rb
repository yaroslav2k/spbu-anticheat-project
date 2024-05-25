# frozen_string_literal: true

# Users

ApplicationRecord.transaction do
  user_1 = User.create_with(
    email: "admin@example.com",
    password: "password",
    password_confirmation: "password"
  ).find_or_create_by!(username: "admin")

  # Courses

  course_1 = Course.create_with(
    year: Time.zone.now.year,
    semester: Utilities::DateTime.current_semester,
    user: user_1
  ).find_or_create_by!(title: "DB internals")

  course_2 = Course.create_with(
    year: Time.zone.now.year,
    semester: Utilities::DateTime.current_semester,
    user: user_1
  ).find_or_create_by!(title: "Diffirential topology")

  # Groups

  Group.create(
    course: course_1,
    title: "mkn-1"
  )

  Group.create(
    course: course_2,
    title: "mkn-2"
  )

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
end
