module CompanyHMarktUrlGenerator

  extend ActiveSupport::Concern

  included do

    # The full url for the H-markt ("h-brand") URL.
    # This is used in meta-data, which is used by search engines, so it
    # must be the full URL to the SHF site.  (A short URl cannot be used;
    # it would misleadingly have the search engine(s) assign that url (the short url)
    # as the real source for the h-markt image.)
    #
    # TODO can the host be set to localhost for development/testing? vs. using I18n value
    def company_h_markt_url(company)
      "#{I18n.t('shf_medlemssystem_url')}/hundforetag/#{company.id}/company_h_brand"
    end

  end

end
