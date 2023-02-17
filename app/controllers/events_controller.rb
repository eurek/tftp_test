class EventsController < ApplicationController
  skip_before_action :authenticate_user!
  layout "static"

  def index
    selected_categories = params.dig(:filters, :categories)&.reject(&:empty?)&.map(&:to_sym) || []
    selected_locales = params.dig(:filters, :locales)&.reject(&:empty?)&.map(&:to_sym) || []
    @incoming_events = filter_events(Event.incoming.with_picture, selected_categories, selected_locales).decorate
    @passed_events = filter_events(Event.passed.with_picture, selected_categories, selected_locales).decorate
  end

  def show
    @event = Event.find(params[:id]).decorate
  end

  private

  def filter_events(events, categories, locales)
    events = events.where(locale: locales) unless locales.blank?
    events = events.where(category: categories) unless categories.blank?
    events
  end
end
