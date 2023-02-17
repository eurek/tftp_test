class GalaxyController < ApplicationController
  skip_before_action :authenticate_user!
  layout "static"

  def home
  end

  def planets
  end

  def stars
  end

  def quarks
  end

  def planet_leaders
  end

  def comet_leaders
  end

  def gluons
  end

  def ambassadors
  end

  def keepers
  end

  def comets
  end
end
