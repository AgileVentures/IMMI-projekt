require 'aasm'

class PivotalTrackerFeature < ActiveRecord::Base

  include AASM

  aasm do

    state :new_in_icebox, initial: true

    state :points_assigned

    state :started, enter: :write_feature_or_spec, exit: :all_tests_pass
    state :waiting_for_scrum_review

    state :waiting_for_client_review, enter: :press_FINISHED_button,  exit: :press_DELIVER_button

    state :accepted, enter: :press_Accepted_button
    state :declined, enter: :press_Rejected_button


    event :vote_on_feature do
      transitions from: :new_in_icebox, to: :points_assigned, guard: :at_least_3_people_voted
    end

    event :start_work do
      transitions from: :points_assigned, to: :started

    end

    event :finished_PR do
      transitions from: :started, to: :waiting_for_scrum_review
    end

    event :approved_in_scrum do
      transitions from: :waiting_for_scrum_review, to: :waiting_for_client_review
    end

    event :rejected_in_scrum do
      transitions from: :waiting_for_scrum_review, to: :started
    end

    event :deliver_to_and_review_with_client do

    end

    event :client_accepted do
      transitions from: :waiting_for_client_review, to: :accepted
    end

    event :client_rejected do
      transitions from: :waiting_for_client_review, to: :declined
    end
  end




end
