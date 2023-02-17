class ProblemsController < ApplicationController
  layout "static"
  skip_before_action :authenticate_user!

  def index
    @problems = Problem.all.by_position.with_cover
  end

  def show
    @problem = Problem.find_by(id: params[:id]).decorate
  end
end
