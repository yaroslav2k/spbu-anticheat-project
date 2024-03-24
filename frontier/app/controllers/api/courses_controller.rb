# frozen_string_literal: true

class API::CoursesController < API::ApplicationController
  def index
    render json: current_user.courses
  end

  def create
    service_result = API::Course::Create.result(
      user: current_user,
      attributes: course_params.to_h
    )

    if service_result.success?
      head :created
    else
      head :unprocessable_entity
    end
  end

  private

    def course_params
      params.fetch(:course).permit(:group, :semester, :title, :year)
    end
end
