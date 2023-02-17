class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!
  layout "errors"

  def not_found
    render_error(404)
  end

  def unacceptable
    render_error(422)
  end

  def internal_error
    render_error(500)
  end

  private

  def render_error(status)
    @status = status

    respond_to do |format|
      format.html { render status: status }
    end
  end
end
