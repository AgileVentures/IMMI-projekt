require 'rails_helper'

RSpec.describe NavigationHelper, type: :helper do

  describe 'the urls always end with a SLASH' do

    it 'adds a SLASH if needed' do
      # this is a way to test a private method
      expect(helper.send(:make_https_url, ['no-ending-slash'])).to eq 'https://no-ending-slash/'
    end

    it 'does not add a SLASH if the url already ends with one' do
      # this is a way to test a private method
      expect(helper.send(:make_https_url, ['no-ending-slash/'])).to eq 'https://no-ending-slash/'
    end
  end


  describe 'full urls that can be used' do

    it '#https' do
      expect(helper.https).to eq 'https://'
    end

    it '#https_main_site_home_url' do
      expect(helper.https_shf_main_site_home_url).to eq 'https://sverigeshundforetagare.se/'
    end

    it 'https_shf_main_site_association_url' do
      expect(helper.https_shf_main_site_association_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.association_url_part}"
    end

    it 'https_shf_main_site_brochure' do
      expect(helper.https_shf_main_site_brochure_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.brochure_url_part}"
    end

    it 'https_shf_main_site_board' do
      expect(helper.https_shf_main_site_board_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.board_url_part}"
    end

    it 'https_shf_main_site_board_our_policy' do
      expect(helper.https_shf_main_site_board_our_policy_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.board_our_policy_url_part}"
    end

    it 'https_shf_main_site_board_statues' do
      expect(helper.https_shf_main_site_board_statues_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.board_statues_url_part}"
    end

    it 'https_shf_main_site_history' do
      expect(helper.https_shf_main_site_history_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.history_url_part}"
    end


    context 'for dog owners' do

      it '#https_shf_main_site_for_dog_owners_url' do
        expect(helper.https_shf_main_site_for_dog_owners_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.for_dog_owners_url_part}"
      end


      it '#https_shf_main_site_dog_owners_about us_url' do
        expect(helper.https_shf_main_site_dog_owners_about_us_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.about_us_for_dog_owners_url_part}"
      end

      it '#https_shf_main_site_dog_owners_h_brand_url' do
        expect(helper.https_shf_main_site_dog_owners_h_brand_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.h_brand_dog_owners_url_part}"
      end

      it '#https_shf_main_site_dog_owners_knowledgebank_url' do
        expect(helper.https_shf_main_site_dog_owners_knowledgebank_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.knowledgebank_dog_owners_url_part}"
      end

      it '#https_shf_main_site_dog_owners_consumer_contact_url' do
        expect(helper.https_shf_main_site_dog_owners_contact_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.dog_owners_are_you_interested_contact_url_part}"
      end

      it '#https_shf_main_site_dog_owners_become a support member_url' do
        expect(helper.https_shf_main_site_dog_owners_become_support_member_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.become_support_member_dog_owners_url_part}"
      end

      it '#https_shf_main_site_dog_owners_become a dog owner_url' do
        expect(helper.https_shf_main_site_dog_owner_being_dog_owner_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.being_a_dog_owner_dog_owners_url_part}"
      end
    end # context 'for dog owners'


    context 'for companies' do

      it '#https_shf_main_site_for_companies_url' do
        expect(helper.https_shf_main_site_for_companies_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.for_companies_url_part}"
      end

      it '#https_shf_main_site_about_us_for_companies_url' do
        expect(helper.https_shf_main_site_about_us_for_companies_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.about_us_for_companies_url_part}"
      end

      it '#https_shf_main_site_companies_sign_up_url' do
        expect(helper.https_shf_main_site_companies_sign_up_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.sign_up_for_companies_url_part}"
      end

      it '#https_shf_main_site_companies_become_h_licensed_url' do
        expect(helper.https_shf_main_site_companies_become_h_licensed_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.become_h_licensed_companies_url_part}"
      end

      it '#https_shf_main_site_companies_member_criteria_url' do
        expect(helper.https_shf_main_site_companies_member_criteria_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.member_criteria_companies_url_part}"
      end

      it '#https_shf_main_site_companies_member_benefits_url' do
        expect(helper.https_shf_main_site_companies_member_benefits_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.member_benefits_companies_url_part}"
      end

      it '#https_shf_main_site_companies_gdpr_url' do
        expect(helper.https_shf_main_site_companies_gdpr_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.gdpr_companies_url_part}"
      end

      it '#https_shf_main_site_companies_quality_control_companies_url' do
        expect(helper.https_shf_main_site_companies_quality_control_companies_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.quality_control_companies_url_part}"
      end

      it '#https_shf_main_site_companies_knowledgebank_url' do
        expect(helper.https_shf_main_site_companies_knowledgebank_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.knowledgebank_companies_url_part}"
      end

      context 'knowledgebank' do

        it 'blogs' do
          expect(helper.https_shf_main_site_companies_knowledgebank_blogs_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.knowledgebank_companies_blogs_url_part}"
        end

        it 'books' do
          expect(helper.https_shf_main_site_companies_knowledgebank_books_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.knowledgebank_companies_books_url_part}"
        end

        it 'research' do
          expect(helper.https_shf_main_site_companies_knowledgebank_research_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.knowledgebank_companies_research_url_part}"
        end

        it 'podcasts' do
          expect(helper.https_shf_main_site_companies_knowledgebank_podcasts_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.knowledgebank_companies_podcasts_url_part}"
        end

        it 'popular science' do
          expect(helper.https_shf_main_site_companies_knowledgebank_popsci_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.knowledgebank_companies_popsci_url_part}"
        end

        it 'videos' do
          expect(helper.https_shf_main_site_companies_knowledgebank_videos_url).to eq "#{helper.https_shf_main_site_home_url}#{helper.knowledgebank_companies_videos_url_part}"
        end

      end

    end # context 'for companies'

  end # end describe 'full urls that can be used'


  describe 'parts used to construct the complete urls' do

    context 'visitors' do

      it 'home url part' do
        expect(helper.shf_main_site_home_url_part).to eq 'sverigeshundforetagare.se'
      end

      it 'association' do
        expect(helper.association_url_part).to eq 'foretag/om-sveriges-hundforetagare/styrelse/'
      end

      it 'brochure' do
        expect(helper.brochure_url_part).to eq 'broschyr/'
      end

      it 'board' do
        expect(helper.board_url_part).to eq 'foretag/om-sveriges-hundforetagare/styrelse/'
      end

      it 'our policy' do
        expect(helper.board_our_policy_url_part).to eq 'foretag/bli-medlem/policyn/'
      end

      it 'statues' do
        expect(helper.board_statues_url_part).to eq 'stadgar/'
      end

      it 'history' do
        expect(helper.history_url_part).to eq 'historik/'
      end


      context 'for dog owners' do
        it '#about_us_for_dog_owners_url_part' do
          expect(helper.about_us_for_dog_owners_url_part).to eq 'agare/om-sveriges-hundforetagare/'
        end

        it '#h_brand_dog_owners_url_part' do
          expect(helper.h_brand_dog_owners_url_part).to eq 'agare/h-markt-av-sveriges-hundforetagare/'
        end

        it '#knowledgebank_dog_owners_url_part' do
          expect(helper.knowledgebank_dog_owners_url_part).to eq 'category/kunskapsbank-hundagare/'
        end

        it '#dog_owners_are_you_interested_contact_url_part' do
          expect(helper.dog_owners_are_you_interested_contact_url_part).to eq 'agare/ar-du-inte-nojd/'
        end

        it '#become_support_member_dog_owners_url_part' do
          expect(helper.become_support_member_dog_owners_url_part).to eq 'agare/bli-stodmedlem/'
        end

        it '#being_a_dog_owner_dog_owners_url_part' do
          expect(helper.being_a_dog_owner_dog_owners_url_part).to eq 'agare/att-vara-hundagare/'
        end

      end # contact 'for dog owners


      context 'for companies' do

        it '#for_companies_url_part' do
          expect(helper.for_companies_url_part).to eq 'foretag/'
        end

        it '#about_us_for_companies_url_part' do
          expect(helper.about_us_for_companies_url_part).to eq 'foretag/om-sveriges-hundforetagare/'
        end

        it '#sign_up_for_companies_url_part' do
          expect(helper.sign_up_for_companies_url_part).to eq 'foretag/bli-medlem/'
        end

        it '#become_h_licensed_companies_url_part' do
          expect(helper.become_h_licensed_companies_url_part).to eq 'foretag/bli-h-markt/'
        end

        it '#member_criteria_companies_url_part' do
          expect(helper.member_criteria_companies_url_part).to eq 'medlemskriterier/'
        end

        it '#member_benefits_companies_url_part' do
          expect(helper.member_benefits_companies_url_part).to eq 'foretag/detta-far-du-som-medlem/'
        end

        it '#gdpr_companies_url_part' do
          expect(helper.gdpr_companies_url_part).to eq 'foretag/gdpr/'
        end

        it '#quality_control_companies_url_part' do
          expect(helper.quality_control_companies_url_part).to eq 'foretag/kvalitetskontroll/'
        end

        it '#knowledgebank_companies_url_part' do
          expect(helper.knowledgebank_companies_url_part).to eq 'kunskapsbank-foretagare/'
        end

        context 'knowledgebank' do

          it 'blogs' do
            expect(helper.knowledgebank_companies_blogs_url_part).to eq 'category/bloggar/'
          end

          it 'books' do
            expect(helper.knowledgebank_companies_books_url_part).to eq 'category/bocker/'
          end

          it 'research' do
            expect(helper.knowledgebank_companies_research_url_part).to eq 'category/forskning/'
          end

          it 'podcasts' do
            expect(helper.knowledgebank_companies_podcasts_url_part).to eq 'category/pod/'
          end

          it 'popular science' do
            expect(helper.knowledgebank_companies_popsci_url_part).to eq 'category/popularvetenskap/'
          end

          it 'video' do
            expect(helper.knowledgebank_companies_videos_url_part).to eq 'category/video/'
          end
        end # context 'knowledgebank' do

      end # context 'for companies'

    end

  end

end
