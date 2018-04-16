# frozen_string_literal: true

class FetchEventsFromDinkursJob < ApplicationJob
  queue_as :default

  def perform(company)
    Dinkurs::EventsCreator.new(company, update_after_date).call
  end


  def update_after_date
    @update_after_date ||= company.events.any? ? 2.days.ago.end_of_day : nil
  end
end
