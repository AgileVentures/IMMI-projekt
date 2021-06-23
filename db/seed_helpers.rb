require_relative 'seed_helpers/address_factory.rb'
require 'smarter_csv'
require_relative('../lib/fake_addresses/csv_fake_addresses_reader')


module SeedHelper

  # The tests of defined? below are due to the rspec file that executes the seed file
  # repeatedly.  Without this, rspec complains about "already initialized constant"

  SEED_ERROR_MSG             = 'Seed ERROR: Could not load either admin email or password.' +
      ' NO ADMIN was created!' unless defined?(SEED_ERROR_MSG)

  MA_NEW_STATE          = :new unless defined?(MA_NEW_STATE)
  MA_UNDER_REVIEW_STATE = :under_review unless defined?(MA_UNDER_REVIEW_STATE)
  MA_WAITING_FOR_APPLICANT_STATE =
                          :waiting_for_applicant unless defined?(MA_WAITING_FOR_APPLICANT_STATE)
  MA_READY_FOR_REVIEW_STATE =
                          :ready_for_review unless defined?(MA_READY_FOR_REVIEW_STATE)
  MA_ACCEPTED_STATE     = :accepted unless defined?(MA_ACCEPTED_STATE)
  MA_REJECTED_STATE     = :rejected unless defined?(MA_REJECTED_STATE)

  MA_ACCEPTED_STATE_STR      = MA_ACCEPTED_STATE.to_s unless defined?(MA_ACCEPTED_STATE_STR)

  MA_BEING_DESTROYED_STATE   = :being_destroyed unless defined?(MA_BEING_DESTROYED_STATE)

  FIRST_MEMBERSHIP_NUMBER    = 100 unless defined?(FIRST_MEMBERSHIP_NUMBER)

  PERCENT_WITH_SENT_PACKETS = 60 unless defined?(PERCENT_WITH_SENT_PACKETS)


  class SeedAdminENVError < StandardError
  end

end
