# frozen_string_literal: true

class FetchEventsFromDinkursJob < ApplicationJob
  queue_as :default

  def perform(company)
    Dinkurs::EventsCreator.new(company).call
  end
end
