require_relative File.join('..', 'services', 'address_exporter')


class ShfApplication < ApplicationRecord

  before_destroy :before_destroy_checks

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


  validates_presence_of :contact_email, :state

  validates_presence_of :companies

  validates_format_of :contact_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]

  validates_uniqueness_of :user_id

  accepts_nested_attributes_for :uploaded_files, allow_destroy: true

  accepts_nested_attributes_for :user, update_only: true
  # ^^ We are not explicitly using any user attributes in the app form.  However,
  # we are delegating the "membership_number" getter and setter methods to
  # User from ShfApplication ("membership_number" used to be an attribute of
  # ShfApplication and was moved to User).
  # The update to "membership_number" (via delegation) will not work without
  # the above statement.

  scope :open, -> { where.not(state: [:accepted, :rejected]) }


  delegate :full_name, to: :user, prefix: true
  delegate :membership_number, :membership_number=, to: :user, prefix: false

  include AASM

  aasm :column => 'state' do

    state :new, :initial => true
    state :under_review
    state :waiting_for_applicant
    state :ready_for_review
    state :accepted
    state :rejected
    state :being_destroyed


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


  def accept_application
    begin

      # Default company email = user's membership contact email
      companies.first.email = contact_email

      # email the applicant to let them know the application was approved:
      ShfApplicationMailer.app_approved(self).deliver_now

    rescue => e
      puts "ERROR: could not accept_membership.  error: #{e.inspect}"
      raise e
    end
  end


  def reject_application

    user.update(membership_number: nil)

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


end
