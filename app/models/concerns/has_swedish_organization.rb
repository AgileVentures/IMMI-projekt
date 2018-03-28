module HasSwedishOrganization

  extend ActiveSupport::Concern

  KEY = 'activerecord.errors.models.shf_application.attributes.company_number.invalid'

  included do

    def swedish_organisationsnummer
      unless Orgnummer.new(self.company_number).valid?
        errors.add(:company_number, I18n.t(KEY, company_number: self.company_number))
      end
    end

  end
end
