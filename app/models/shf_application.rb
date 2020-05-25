require_relative File.join('..', 'services', 'address_exporter')

require 'observer'


class ShfApplication < ApplicationRecord

  include Observable
  include AASM


  before_destroy :before_destroy_checks

  after_initialize :add_observers

  belongs_to :user

  #  A Company for a membership application (an instantiated one)
  #  is created (instantiated) when a embership application is created,
  #  unless the company already exists, in which case that existing instance
  #  is associated with the new membership application.

  has_many :company_applications
  has_many :companies, through: :company_applications, dependent: :destroy

  has_and_belongs_to_many :business_categories

  has_many :uploaded_files

  belongs_to :waiting_reason, optional: true,
             foreign_key: "member_app_waiting_reasons_id",
             class_name: 'AdminOnly::MemberAppWaitingReason'

  belongs_to :file_delivery_method, optional: true,
             class_name: 'AdminOnly::FileDeliveryMethod'

  validates :contact_email, :state, :companies, :business_categories, presence: true

  validates :file_delivery_method, presence: { on: :create }

  validates :contact_email, email: true

  validates_uniqueness_of :user_id

  accepts_nested_attributes_for :uploaded_files, allow_destroy: true

  # FIXME - rename this scope. It is only used in no_uploaded_files
  scope :open, -> { where.not(state: [:accepted, :rejected]) }

  CAN_EDIT_STATES = [:new, :waiting_for_applicant]


  def add_observers
    add_observer MembershipStatusUpdater.instance, :shf_application_updated
  end


  aasm :column => 'state' do

    state :new, :initial => true
    state :under_review
    state :waiting_for_applicant
    state :ready_for_review
    state :accepted
    state :rejected
    state :being_destroyed

    # after all of our state changes (transitions), call :tell_observers
    after_all_transitions :state_transitioned


    event :start_review do
      transitions from: :new, to: :under_review
      transitions from: :ready_for_review, to: :under_review
    end

    event :ask_applicant_for_info do
      transitions from: :under_review, to: :waiting_for_applicant
    end

    event :cancel_waiting_for_applicant do
      transitions from: :waiting_for_applicant, to: :under_review
    end

    event :is_ready_for_review do
      transitions from: :waiting_for_applicant, to: :ready_for_review
    end

    event :accept do
      transitions from: [:under_review, :rejected], to: :accepted, after: :accept_application
    end

    event :reject do
      transitions from: [:under_review, :accepted], to: :rejected, after: :reject_application
    end

  end

  # encapsulate how to get a list of all states as symbols
  def self.all_states
    aasm.states.map(&:name)
  end

  def self.in_state(app_state)
    where(state: app_state)
  end

  def self.total_in_state(app_state)
    where(state: app_state).count
  end

  # Have to guard agains the condition where there are no uploaded files in the system
  def self.no_uploaded_files
    return open if UploadedFile.count == 0

    open.where('id NOT IN (?)', UploadedFile.pluck(:shf_application_id))

  end

  # return all SHF applications where updated_at: >= start date AND updated_at: <= end_date
  def self.updated_in_date_range(start_date, end_date)
    where( updated_at: start_date..end_date )
  end



  # these are only used by the submisssion form and are not saved to the db
  def marked_ready_for_review
    @marked_ready_for_review ||= (ready_for_review? ? 1 : 0)
  end


  def marked_ready_for_review=(value)
    @marked_ready_for_review = value
  end


  def not_a_member?
    !user.member?
  end

  def company_numbers
    companies.order(:id).map(&:company_number).join(', ')
  end

  def company_names
    companies.order(:id).map(&:name).join(', ')
  end

  def company_branding_fee_paid?
    companies.last&.branding_license?
  end

  # @return [boolean] - is the application in a state where the applicant can edit it?
  def applicant_can_edit?
    CAN_EDIT_STATES.include? state.to_sym
  end


  def accept_application
    begin

      update(when_approved: Time.zone.now)

      # create the SHF Membership Guidelines checklist for the user
      # AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(user)

      # Default company email = user's membership contact email
      companies.first.email = contact_email

      # email the applicant to let them know the application was approved:
      ShfApplicationMailer.app_approved(self).deliver_now

    rescue => e
      puts "ERROR: could not accept_membership.  error: #{e.inspect}"
      update(when_approved: nil)
      raise e
    end
  end


  def reject_application

    user.update(membership_number: nil)

    update(when_approved: nil)
    destroy_uploaded_files

  end


  def before_destroy_checks

    destroy_uploaded_files

    destroy_associated_companies

  end


  def se_mailing_csv_str
     companies.empty? ?  AddressExporter.se_mailing_csv_str(nil) : companies.last.se_mailing_csv_str
  end


  private

  def destroy_uploaded_files

    uploaded_files.each do |uploaded_file|
      uploaded_file.actual_file = nil
      uploaded_file.destroy
    end

    save
  end

  def destroy_associated_companies
    # Destroy company if no other associated applications

    self.update(state: :being_destroyed)

    companies.all.each do |cmpy|
      cmpy.destroy if cmpy.shf_applications.count == 1
    end
  end



  # let all of our observers know our state changed
  def state_transitioned
    changed(true)
    notify_observers(self)
  end



end
