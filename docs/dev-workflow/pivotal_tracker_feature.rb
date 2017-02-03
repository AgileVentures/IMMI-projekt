require 'aasm'

class PivotalTrackerFeature

  include AASM

  aasm do

    state :new_in_icebox, initial: true

    state :points_assigned

    state :started, enter: :write_feature_or_spec, exit: :all_tests_pass
    
    state :FINISHED__waiting_for_scrum_review, enter: :press_FINISHED_button

    state :DELIVERED__waiting_for_client_review,  enter: :press_DELIVER_button

    state :DELIVERED__waiting_for_shf_review,  enter: :press_DELIVER_button

    state :accepted, enter: :press_Accepted_button

    state :rejected, enter: :press_Rejected_button

    state :deployed, enter: :deployed_to_PRODUCTION, final: true



    event :vote_on_feature do
      transitions from: :new_in_icebox, to: :points_assigned, guard: :at_least_3_people_voted
    end

    event :start_work do
      transitions from: :points_assigned, to: :started

    end

    event :finished_PR do
      transitions from: :started, to: :FINISHED__waiting_for_scrum_review
    end

    event :approved_in_scrum do
      transitions from: :FINISHED__waiting_for_scrum_review, to: :DELIVERED__waiting_for_client_review, guard: :is_client_facing
      transitions from: :FINISHED__waiting_for_scrum_review, to: :DELIVERED__waiting_for_shf_review, guard: :is_not_client_facing
    end

    event :rejected_in_scrum do
      transitions from: :FINISHED__waiting_for_scrum_review, to: :started
    end


    event :deliver_to_and_review_with_client do

    end

    event :client_accepted do
      transitions from: :DELIVERED__waiting_for_client_review, to: :accepted, guard: :test_on_DEPLOYMENT_server_passes
    end

    event :client_rejected do
      transitions from: :DELIVERED__waiting_for_client_review, to: :rejected
    end

    event :shf_accepted do
      transitions from: :DELIVERED__waiting_for_shf_review, to: :accepted, guard: :test_on_DEPLOYMENT_server_passes
    end

    event :shf_rejected do
      transitions from: :DELIVERED__waiting_for_shf_review, to: :rejected
    end


    event :deploy do
      transitions from: :accepted, to: :deployed
    end

  end




end
