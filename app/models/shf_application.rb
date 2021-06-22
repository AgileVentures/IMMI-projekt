require_relative File.join('..', 'services', 'address_exporter')

require 'observer'


class ShfApplication < ApplicationRecord

  include Observable
  include AASM
  include UpdatedAtRange


  before_destroy :before_destroy_checks

  after_initialize :add_observers
  after_update :clear_image_caches
  before_destroy :before_destroy_checks

  belongs_to :user

  #  A Company for a membership application (an instantiated one)
  #  is created (instantiated) when a membership application is created,
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


  CAN_EDIT_STATES = [:new, :waiting_for_applicant]

  # The application can be changed if it is in one of these states:
  EDITABLE_STATES_FOR_APPLICATION = Set[:new, :initial, :ready_for_review, :waiting_for_applicant].freeze

  # these are the SHF application states where it might be waiting for uploaded files:
  STATES_WAITING_FOR_FILES = %w(new under_review waiting_for_applicant)



  scope :not_decided, -> { where.not(state: [:accepted, :rejected]) }


  # Have to guard against the condition where there are no uploaded files in the system
  def self.decided_with_no_uploaded_files
    return not_decided if UploadedFile.count == 0

    # must compact to get rid of uploaded files not associated with any application
    not_decided.where('id NOT IN (?)', UploadedFile.pluck(:shf_application_id).compact)
  end


  # encapsulate how to get a list of all states as symbols
  def self.all_states
    aasm.states.map(&:name)
  end


  # TODO don't need this. AASM provides a scope for each defined state
  def self.in_state(app_state)
    where(state: app_state)
  end


  def self.total_in_state(app_state)
    where(state: app_state).count
  end


  # ---------------------
  # AASM (State machine)

  # FIXME - should 'being_destroyed' really be a state? These represent business (domain) states, not implementations.
  #   If an application is in the 'being_destroyed' state in the db, then that represents an error (it was not able to be destroyed successfully),
  #   not a state/status that exists in the 'real world' (business/domain).
  aasm column: 'state' do

    state :new, initial: true
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

  # ---------------------


  def self.edittable_states
    EDITABLE_STATES_FOR_APPLICATION
  end

  # ===========================================================================================


  def clear_image_caches
    user.clear_proof_of_membership_jpg_cache

    companies.each do |company|
      company.clear_h_brand_jpg_cache
    end
  end


  def business_subcategories(business_category)
    return nil unless business_category.is_root?
    return nil unless business_categories.include?(business_category)

    subcategories = []

    business_category_ids =  business_categories.map(&:id)

    BusinessCategory.children_of(business_category.id).order(:name).each do |subcategory|
      subcategories << subcategory if business_category_ids.include?(subcategory.id)
    end

    subcategories
  end

  def set_business_subcategories(business_category, subcategories)

    return unless business_category.is_root? &&
                  business_categories.include?(business_category)

    # Remove existing and reset new subcategories for this business category
    self.business_categories.children_of(business_category.id).each do |subcategory|
      self.business_categories.delete(subcategory)
    end

    subcategories.each do |subcategory|
      self.business_categories << subcategory
    end
  end


  # these are only used by the submission form and are not saved to the db
  def marked_ready_for_review
    @marked_ready_for_review ||= (ready_for_review? ? 1 : 0)
  end


  def marked_ready_for_review=(value)
    @marked_ready_for_review = value
  end


  # FIXME where is this used?
  def not_a_member?
    user.not_a_member? # TODO should delegate
  end

  def company_numbers
    companies.order(:id).map(&:company_number).join(', ')
  end

  def company_names
    companies.order(:id).map(&:name).join(', ')
  end

  # TODO change this to work with a specific company, not the last one
  def company_branding_fee_paid?
    companies.last&.branding_license?
  end


  def add_observers
    add_observer MembershipStatusUpdater.instance, :shf_application_updated
  end


  def upload_files_will_be_delivered_later?
    file_delivery_method&.email? || file_delivery_method&.mail?
  end

  def edittable_states
    self.class.edittable_states
  end

  # @return [Boolean] - uploaded files can be editted or deleted if the application is not
  def can_edit_delete_uploads?
    edittable_states.include?(state.to_sym)
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
    destroy_uploaded_files # FIXME why destroy these?  Don't they need to be kept in case the applicant wants to talk about them?
  end


  def possibly_waiting_for_upload?
    STATES_WAITING_FOR_FILES.include? state
  end

  def before_destroy_checks
    destroy_uploaded_files
    destroy_associated_companies
  end


  def se_mailing_csv_str
     companies.empty? ?  AddressExporter.se_mailing_csv_str(nil) : companies.last.se_mailing_csv_str
  end

  # ---------------------------------------------------------------------------

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
