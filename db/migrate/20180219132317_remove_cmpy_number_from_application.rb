class RemoveCmpyNumberFromApplication < ActiveRecord::Migration[5.1]

  # Define temp models using both old and new associations
  class Company < ApplicationRecord
    has_and_belongs_to_many :shf_applications

    has_many :company_applications
    has_many :shf_applications_tmp, through: :company_applications,
                                    source: :shf_application, dependent: :destroy
  end

  class ShfApplication < ApplicationRecord
    has_and_belongs_to_many :companies

    has_many :company_applications
    has_many :companies_tmp, through: :company_applications,
                             source: :company, dependent: :destroy
  end

  class CompanyApplication < ApplicationRecord
    belongs_to :company
    belongs_to :shf_application
  end

  def change

    # This logic here assumes that there is only one company (at most)
    # associated with an application.  This is the situation in production
    # at the time of this migration.

    reversible do |dir|
      dir.up do

        # Create table for CompanyApplication model
        create_table :company_applications do |t|
          t.references :company, foreign_key: true, null: false
          t.references :shf_application, foreign_key: true, null: false

          t.timestamps
        end

        ShfApplication.all.each do |app|

          app.companies_tmp = app.companies

          if app.companies_tmp.count == 2
            # At this time (Mar 14, 2018) there is *one* application in production
            # that has the same company associated with it twice.
            # Removing the second association (join record will be destroy,
            # NOT the actual company)
            first_company = app.companies_tmp.first
            second_company = app.companies_tmp.second

            app.companies_tmp.destroy(first_company)

            app.companies_tmp << second_company if app.companies_tmp.count == 0
            # ^^ In case first and second company are the same
          end

          if (app.companies.count == 0) && app.company_number &&
             ! Company.find_by(company_number: app.company_number)
             # This logic prevents creating a second company for an
             # application that was accepted and subsequently the
             # user changed the company_number in that company

            app.companies_tmp << Company
              .create(company_number: app.company_number,
                      email: app.contact_email)
          end
        end

        remove_column :shf_applications, :company_number

        remove_column :shf_applications, :company_id

        # Drop unneeded join table
        drop_table :companies_shf_applications
      end

      dir.down do
        # Recreate join table has HABTM associations
        create_join_table :shf_applications, :companies do |t|
          t.index [:shf_application_id, :company_id],
                  name: 'index_application_company'
          t.index [:company_id, :shf_application_id],
                  name: 'index_company_application'
        end

        add_column :shf_applications, :company_number, :string

        add_column :shf_applications, :company_id, :integer

        ShfApplication.all.each do |app|

          if app.state == 'accepted'

            app.companies = app.companies_tmp
            app.company_number = app.companies[0]&.company_number
            app.save

          elsif app.companies_tmp.count > 0

            app.company_number = app.companies_tmp[0].company_number
            app.save

            app.companies_tmp[0].destroy
          end
        end

        drop_table :company_applications
      end
    end
  end
end
