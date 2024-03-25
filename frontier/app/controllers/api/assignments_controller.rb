# frozen_string_literal: true

class API::AssignmentsController < API::ApplicationController
  def index
    render json: assignments_scope
  end

  def show
    render json: assignments_scope.find(params[:id])
  end

  private

    def assignments_scope
      current_user.assignments
    end
end
