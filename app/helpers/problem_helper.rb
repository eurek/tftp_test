module ProblemHelper
  def problem_cover_image(problem, size)
    if problem.cover_image.attached?
      url_for(problem.cover_image.variant(resize_to_limit: size))
    else
      image_url "icebergs.jpg"
    end
  end
end
