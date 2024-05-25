# frozen_string_literal: true

class API::Course::Create < ApplicationService
  input :user, type: User
  input :attributes, type: Hash

  output :course, type: Course

  play :create_course

  private

    def create_course
      self.course = user.courses.build(attributes.except(:group))

      fail! error: "Unable to save record", record: course unless course.save
    end
end
