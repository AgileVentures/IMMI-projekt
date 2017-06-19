require 'rails_helper'

class TestPaginationUtility < ApplicationController
  include PaginationUtility
end

RSpec.describe TestPaginationUtility do

  let(:initial_load_companies) { {controller: 'companies', action: 'index'} }

  let(:empty_search_companies) do
    { q: { "business_categories_id_in"=>[""],
           "addresses_region_id_in"=>[""],
           "addresses_kommun_id_in"=>[""],
           "name_in"=>[""] },
      commit: 'Search' }
  end

  let(:specified_search_companies) do
    { q: { "business_categories_id_in"=>["", "1"],
           "addresses_region_id_in"=>["", "1"],
           "addresses_kommun_id_in"=>[""],
           "name_in"=>[""] },
      commit: 'Search' }
  end

  let(:empty_search_applications) do
    { q: { "last_name_in"=>[""],
           "company_number_in"=>[""],
           "state_in"=>[""] },
      commit: "Search" }
  end

  let(:specified_search_applications) do
    { q: { "last_name_in"=>["", "Andreasson", "Axelsson"],
           "company_number_in"=>[""],
           "state_in"=>["", "under_review"] },
      commit: "Search" }
  end

  let(:items_count_25) { {items_count: '25'} }
  let(:items_count_all) { {items_count: 'All'} }

  describe "#process_pagination_params('companies')" do

    it 'initial page load' do
      subject.params = ActionController::Parameters.new(initial_load_companies)

      expect(subject.process_pagination_params('companies'))
        .to match_array [ nil, 10, 10 ]
    end

    it 'search with no criteria' do
      subject.params = ActionController::Parameters.new(
        initial_load_companies.merge(empty_search_companies))

      expect(subject.process_pagination_params('companies'))
        .to match_array [ ActionController::Parameters.new(
          empty_search_companies[:q]), 10, 10 ]
    end

    it 'search with specified criteria' do
      subject.params = ActionController::Parameters.new(
        initial_load_companies.merge(specified_search_companies))

      expect(subject.process_pagination_params('companies'))
        .to match_array [ ActionController::Parameters.new(
          specified_search_companies[:q]), 10, 10 ]
    end

    it 'set per-page items to 25' do
      # "Load" the page first
      subject.params = ActionController::Parameters.new(initial_load_companies)
      subject.process_pagination_params('companies')

      # Now set items count
      subject.params = ActionController::Parameters.new(
        initial_load_companies.merge(items_count_25))

      expect(subject.process_pagination_params('companies'))
        .to match_array [ nil, 25, 25 ]
    end

    it 'set per-page items to All' do
      # "Load" the page first
      subject.params = ActionController::Parameters.new(initial_load_companies)
      subject.process_pagination_params('companies')

      # Now set items count
      subject.params = ActionController::Parameters.new(
        initial_load_companies.merge(items_count_all))

      expect(subject.process_pagination_params('companies'))
        .to match_array [ nil, 'All', 10_000 ]
    end

    it 'session cache management' do
      # "Load" the page
      subject.params = ActionController::Parameters.new(initial_load_companies)
      subject.process_pagination_params('companies')

      expect(session[:companies_search_criteria]).to eq 'null'
      expect(session[:companies_items_selection]).to be_nil

      # Set items count to 25
      subject.params = ActionController::Parameters.new(
        initial_load_companies.merge(items_count_25))
      subject.process_pagination_params('companies')

      expect(session[:companies_search_criteria]).to eq 'null'
      expect(session[:companies_items_selection]).to eq 25

      # Search with no criteria
      subject.params = ActionController::Parameters.new(
        initial_load_companies.merge(empty_search_companies))
      subject.process_pagination_params('companies')

      expect(session[:companies_search_criteria]).to eq empty_search_companies[:q].to_json
      expect(session[:companies_items_selection]).to eq 25

      # Search with criteria
      subject.params = ActionController::Parameters.new(
        initial_load_companies.merge(specified_search_companies))
      subject.process_pagination_params('companies')

      expect(session[:companies_search_criteria])
        .to eq specified_search_companies[:q].to_json
      expect(session[:companies_items_selection]).to eq 25

      # Set items count to 'All'
      subject.params = ActionController::Parameters.new(
        initial_load_companies.merge(items_count_all))
      subject.process_pagination_params('companies')

      expect(session[:companies_search_criteria])
        .to eq specified_search_companies[:q].to_json
      expect(session[:companies_items_selection]).to eq 'All'
    end
  end

  describe "#process_pagination_params('membership_applications')" do

    it 'initial page load' do
      subject.params = ActionController::Parameters.new({})

      expect(subject.process_pagination_params('membership_applications'))
        .to match_array [ nil, 10, 10 ]
    end

    it 'search with no criteria' do
      subject.params = ActionController::Parameters.new(empty_search_applications)

      expect(subject.process_pagination_params('membership_applications'))
        .to match_array [ ActionController::Parameters.new(
          empty_search_applications[:q]), 10, 10 ]
    end

    it 'search with specified criteria' do
      subject.params = ActionController::Parameters.new(specified_search_applications)

      expect(subject.process_pagination_params('membership_applications'))
        .to match_array [ ActionController::Parameters.new(
          specified_search_applications[:q]), 10, 10 ]
    end

    it 'set per-page items to 25' do
      # "Load" the page first
      subject.params = ActionController::Parameters.new({})
      subject.process_pagination_params('membership_applications')

      # Now set items count
      subject.params = ActionController::Parameters.new(items_count_25)

      expect(subject.process_pagination_params('membership_applications'))
        .to match_array [ nil, 25, 25 ]
    end

    it 'set per-page items to All' do
      # "Load" the page first
      subject.params = ActionController::Parameters.new({})
      subject.process_pagination_params('membership_applications')

      # Now set items count
      subject.params = ActionController::Parameters.new(items_count_all)

      expect(subject.process_pagination_params('membership_applications'))
        .to match_array [ nil, 'All', 10_000 ]
    end

    it 'session cache management' do
      # "Load" the page
      subject.params = ActionController::Parameters.new({})
      subject.process_pagination_params('membership_applications')

      expect(session[:membership_applications_search_criteria]).to eq 'null'
      expect(session[:membership_applications_items_selection]).to be_nil

      # Set items count to 25
      subject.params = ActionController::Parameters.new(items_count_25)
      subject.process_pagination_params('membership_applications')

      expect(session[:membership_applications_search_criteria]).to eq 'null'
      expect(session[:membership_applications_items_selection]).to eq 25

      # Search with no criteria
      subject.params = ActionController::Parameters.new(empty_search_applications)
      subject.process_pagination_params('membership_applications')

      expect(session[:membership_applications_search_criteria])
        .to eq empty_search_applications[:q].to_json
      expect(session[:membership_applications_items_selection]).to eq 25

      # Search with criteria
      subject.params = ActionController::Parameters.new(specified_search_applications)
      subject.process_pagination_params('membership_applications')

      expect(session[:membership_applications_search_criteria])
        .to eq specified_search_applications[:q].to_json
      expect(session[:membership_applications_items_selection]).to eq 25

      # Set items count to 'All'
      subject.params = ActionController::Parameters.new(items_count_all)
      subject.process_pagination_params('membership_applications')

      expect(session[:membership_applications_search_criteria])
        .to eq specified_search_applications[:q].to_json
      expect(session[:membership_applications_items_selection]).to eq 'All'
    end
  end
end
