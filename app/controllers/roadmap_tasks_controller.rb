class RoadmapTasksController < ApplicationController
  skip_before_action :authenticate_user!
  layout "static"

  def index
    @done_short_tasks = RoadmapTask.where(duration_type: "short").done
    @done_medium_tasks = RoadmapTask.where(duration_type: "medium").done
    @done_long_tasks = RoadmapTask.where(duration_type: "long").done
    @short_tasks = RoadmapTask.where(duration_type: "short").not_done
    @medium_tasks = RoadmapTask.where(duration_type: "medium").not_done
    @long_tasks = RoadmapTask.where(duration_type: "long").not_done
    @last_done_task = RoadmapTask.done.last
    @current_situation = CurrentSituation.first
    @current_episode = Episode.current.decorate
    @funded_innovations = Innovation.star.count
    @total_raised = SharesPurchase.total_raised
  end

  def show
    @roadmap_task = RoadmapTask.find_by(id: params[:id])
    @no_index = params[:js] != "true"
    render :show, layout: false
  end
end
