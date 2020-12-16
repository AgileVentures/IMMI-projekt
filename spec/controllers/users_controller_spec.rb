require 'rails_helper'
require_relative '../../app/models/logfile_namer'


RSpec.describe UsersController, type: :controller do

  let(:admin) { create(:user, admin: true) }

  before(:each) { sign_in admin }

  describe '#index will fix_FB_changed_params' do

    it "does not change URL if there are no query ('q') parameters" do
      no_query_params = { "utf8" => "✓" }

      expected_fixed = { "utf8" => "✓",
                         "controller" => "users",
                         "action" => "index",
      }

      get :index, params: no_query_params

      expect(subject.params.to_unsafe_h).to eq expected_fixed

    end

    it 'q parameters that are a Hash are converted to Array with the Hash values' do

      fb_mangled_params = { "utf8" => "✓",
                            "q" => {
                                "first_name_in" => { "0" => "A", "1" => "B", "2" => "C" }
                            }
      }

      expected_fixed_q = { "first_name_in" => ["A", "B", "C"] }

      get :index, params: fb_mangled_params
      expect(subject.params.to_unsafe_h['q']).to eq expected_fixed_q
    end

    it 'empty values do not need to be retained)' do

      fb_mangled_params = { "utf8" => "✓",
                            "q" => {
                                "first_name_in" => { "0" => "A", "1" => "B", "2" => "C" },
                                "addresses_region_id_in" => { "0" => "6" },
                                "addresses_kommun_id_in" => { "0" => nil, "1" => "" },
                                "name_in" => { "0" => nil } },
                            "commit" => "Sök" }

      expected_fixed_q = { "first_name_in" => ["A", "B", "C"],
                           "addresses_region_id_in" => ["6"],
                           "addresses_kommun_id_in" => ["", ""],
                           "name_in" => [""] }


      get :index, params: fb_mangled_params

      expect(subject.params.to_unsafe_h['q']).to match expected_fixed_q
    end

  end


  describe '#toggle_membership_package_sent' do

    context 'user found' do

      it 'returns success response' do
        u = create(:user)

        post :toggle_membership_package_sent,
             xhr: true,
             params:  { "utf8" => "✓",
                       "date_membership_packet_sent"=>"false",
                       "user_id"=>"#{u.id}",
                       "locale"=>"en"
                      }

        expect(response).to have_http_status(:success) # 200
      end
    end


    context 'cannot find user' do

      it 'raises RecordNotFound error' do

        expect{
          post :toggle_membership_package_sent,
               xhr: true,
               params:  { "utf8" => "✓",
                          "date_membership_packet_sent"=>"false",
                          "user_id"=>"999",
                          "locale"=>"en",
                          format: :js
               }
          expect(response).to have_http_status(:not_found) # 404
        }.to raise_exception ActiveRecord::RecordNotFound
      end
    end
  end


  it '#destroy logs to a logfile, name is set by LogfileNamer' do

    user = create(:user)

    expected_logfile_name = LogfileNamer.name_for('users')
    expected_logfile_facility = 'Manage Users'
    expected_logfile_activity = 'Delete'

    expect(ActivityLogger).to receive(:open).with(expected_logfile_name, expected_logfile_facility, expected_logfile_activity)

    delete :destroy, params:  { "utf8" => "✓",
                      "id"=>"#{user.id}",
                      "locale"=>"en"
    }


  end

  context '#proof_of_membership' do
    let(:app_config) { create(:app_configuration) }
    let(:member) { create(:member_with_membership_app) }

    it "returns JPG for params[:render_to] == 'jpg' request" do
      get :proof_of_membership, params: { id: member.id, render_to: 'jpg' }
      expect(response.content_type).to eq 'image/jpg'
    end

    it "returns JPG for params[:format] == 'jpg' request" do
      get :proof_of_membership, params: { id: member.id, format: 'jpg' }
      expect(response.content_type).to eq 'image/jpg'
    end

    it 'returns HTML otherwise' do
      get :proof_of_membership, params: { id: member.id }
      expect(response.content_type).to eq 'text/html'
    end
  end




end
