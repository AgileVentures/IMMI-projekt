# frozen_string_literal: true

class FetchEventsKickoffJob < ApplicationJob
  queue_as :default

  def perform
    Company.where.not(dinkurs_company_id: nil).each do |company|
      FetchEventsFromDinkursJob.perform_later(company)
    end
  end
end
