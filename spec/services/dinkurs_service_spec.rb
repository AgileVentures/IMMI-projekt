require 'rails_helper'


require_relative(File.join(__dir__, '..', '..', 'app', 'services', 'dinkurs_service'))

# record: :new_episodes


RSpec.describe DinkursService, vcr: {record: :none } do

  # use this block to ensure the response is in UTF-8 (and not ASCII which may be binary):
  VCR.configure do |c|
    c.before_record do |i|
      i.response.body.force_encoding('UTF-8')
    end
  end


  VALID_COMPANY_ID = 'yFKGQJ'


  describe '.get_events' do

    describe 'valid company and events', :vcr do

      let(:dks_events) { described_class.get_events(VALID_COMPANY_ID) }

    #  let(:expected_10_events) { YAML.load_file File.join(__dir__, '..', 'fixtures', 'dinkurs_service', 'dkevents-10-hashes.yml') }


      it 'returns valid array of 10 DinkursEvents' do
        expect(dks_events).to be_a Array
        expect(dks_events.count).to eq 10

        expect(dks_events.first).to be_a DinkursEvent

      end

      it 'data for all DinkursEvents is correct' do
          # TODO - not passing yet.  Need to deal with Date formatting.
        expected_events = [
            { "id" => nil, "dinkurs_id" => "28613", "name" => "Betaling (DKK)", "place_geometry_location" => nil, "host" => "Demo Din Kurs", "fee" => 0.0, "fee_tax" => 0.0, "pub" => " Fri, 06 Feb 2015 00 : 00 : 00 UTC +00 : 00", "apply" => " Fri, 01 Jan 2100 00 : 00 : 00 UTC +00 : 00",  "start" => " Fri, 01 Jan 2100 00 : 00 : 00 UTC +00 : 00", "stop" => " Fri, 01 Jan 2100 00 : 00 : 00 UTC +00 : 00",  "participant_number" => 0.0, "participant_reserve" => 0.0, "participants" => 0.0, "occasions" => "0", "group" => "0", "position" => "0", "instructor_1" => nil, "instructor_2" => nil, "instructor_3" => nil, "infotext" => nil, "commenttext" => nil, "ticket_info" => nil, "key" => "PEpnLgEsMLFBlGjV", "url_id" => "https://dinkurs.se/appliance/?event_id=28613", "url_key" => "https://dinkurs.se/appliance/?event_key=PEpnLgEsMLFBlGjV", "completion_text" => nil, "aftertext" => nil, "dates" => nil, "created_at" => nil, "updated_at" => nil, "company_id" => nil, "place" => nil },
            { "id" => nil, "dinkurs_id" => "30016", "name" => "Betalning (SEK)", "place_geometry_location" => nil, "host" => "Demo Din Kurs", "fee" => 0.0, "fee_tax" => 0.0, "pub" => " Wed, 15 Apr 2015 00 : 00 : 00 UTC +00 : 00", "apply" => " Fri, 01 Jan 2100 00 : 00 : 00 UTC +00 : 00",  "start" => " Fri, 01 Jan 2100 00 : 00 : 00 UTC +00 : 00", "stop" => " Fri, 01 Jan 2100 00 : 00 : 00 UTC +00 : 00",  "participant_number" => 0.0, "participant_reserve" => 0.0, "participants" => 0.0, "occasions" => "0", "group" => "0", "position" => "0", "instructor_1" => nil, "instructor_2" => nil, "instructor_3" => nil, "infotext" => nil, "commenttext" => nil, "ticket_info" => nil, "key" => "MRCLQjAQUStcThxB", "url_id" => "https://dinkurs.se/appliance/?event_id=30016", "url_key" => "https://dinkurs.se/appliance/?event_key=MRCLQjAQUStcThxB", "completion_text" => nil, "aftertext" => nil, "dates" => nil, "created_at" => nil, "updated_at" => nil, "company_id" => nil, "place" => nil },
            { "id" => nil, "dinkurs_id" => "26296", "name" => "Nyhetsbrevslista", "place_geometry_location" => nil, "host" => "Demo", "fee" => 0.0, "fee_tax" => 0.0, "pub" => " Mon, 20 Oct 2014 00 : 00 : 00 UTC +00 : 00", "apply" => " Fri, 01 Jan 2100 00 : 00 : 00 UTC +00 : 00",  "start" => " Fri, 01 Jan 2100 00 : 00 : 00 UTC +00 : 00", "stop" => " Fri, 01 Jan 2100 00 : 00 : 00 UTC +00 : 00",  "participant_number" => 0.0, "participant_reserve" => 0.0, "participants" => 0.1e1, "occasions" => "0", "group" => "0", "position" => "0", "instructor_1" => nil, "instructor_2" => nil, "instructor_3" => nil, "infotext" => nil, "commenttext" => "Här ser du dina sändlistor. En sändlista är en samling adresser som du kan använda för att skicka nyhetsbrev till. Du kan även skicka nyhetsbrev till deltagare i ett evenemang.", "ticket_info" => nil, "key" => "qPZFJwFENEqVwcvI", "url_id" => "https://dinkurs.se/appliance/?event_id=26296", "url_key" => "https://dinkurs.se/appliance/?event_key=qPZFJwFENEqVwcvI", "completion_text" => nil, "aftertext" => nil, "dates" => nil, "created_at" => nil, "updated_at" => nil, "company_id" => nil, "place" => nil },
            { "id" => nil, "dinkurs_id" => "42356", "name" => "Biljetter", "place_geometry_location" => "(55.6077948, 13.005606100000023)", "host" => "Demo", "fee" => 10.0, "fee_tax" => 2.0, "pub" => " Fri, 18 Nov 2016 00 : 00 : 00 UTC +00 : 00", "apply" => " Wed, 29 Nov 2017 00 : 00 : 00 UTC +00 : 00",  "start" => " Fri, 15 Dec 2017 00 : 00 : 00 UTC +00 : 00", "stop" => " Fri, 15 Dec 2017 00 : 00 : 00 UTC +00 : 00",  "participant_number" => 0.5e3, "participant_reserve" => 0.2e1, "participants" => 0.91e2, "occasions" => "4", "group" => "10", "position" => "3", "instructor_1" => nil, "instructor_2" => nil, "instructor_3" => nil, "infotext" => nil, "commenttext" => nil, "ticket_info" => nil, "key" => "QKCVGOObDgLCHVRY", "url_id" => "https://dinkurs.se/appliance/?event_id=42356", "url_key" => "https://dinkurs.se/appliance/?event_key=QKCVGOObDgLCHVRY", "completion_text" => nil, "aftertext" => "Yolo", "dates" => nil, "created_at" => nil, "updated_at" => nil, "company_id" => nil, "place" => "Elsewhere AB" },
            { "id" => nil, "dinkurs_id" => "43493", "name" => "Grundkurs om eventry.", "place_geometry_location" => "(56.2360185, 14.535028900000043)", "host" => "Demo", "fee" => 10.0, "fee_tax" => 2.0, "pub" => " Thu, 12 Jan 2017 00 : 00 : 00 UTC +00 : 00", "apply" => " Tue, 30 Jan 2018 00 : 00 : 00 UTC +00 : 00",  "start" => " Tue, 30 Jan 2018 00 : 00 : 00 UTC +00 : 00", "stop" => " Tue, 30 Jan 2018 00 : 00 : 00 UTC +00 : 00",  "participant_number" => 0.0, "participant_reserve" => 0.0, "participants" => 0.32e2, "occasions" => "1", "group" => "10", "position" => "3", "instructor_1" => nil, "instructor_2" => nil, "instructor_3" => nil, "infotext" => "ghfddz", "commenttext" => nil, "ticket_info" => nil, "key" => "PPCDTNJrDvrFMBoX", "url_id" => "https://dinkurs.se/appliance/?event_id=43493", "url_key" => "https://dinkurs.se/appliance/?event_key=PPCDTNJrDvrFMBoX", "completion_text" => nil, "aftertext" => nil, "dates" => nil, "created_at" => nil, "updated_at" => nil, "company_id" => nil, "place" => "Fågelvägen 8," },
            { "id" => nil, "dinkurs_id" => "47250", "name" => "Test", "place_geometry_location" => nil, "host" => "Demo", "fee" => 0.0, "fee_tax" => 0.0, "pub" => " Wed, 21 Jun 2017 00 : 00 : 00 UTC +00 : 00", "apply" => " Thu, 21 Jun 2018 00 : 00 : 00 UTC +00 : 00",  "start" => " Thu, 21 Jun 2018 00 : 00 : 00 UTC +00 : 00", "stop" => " Thu, 21 Jun 2018 00 : 00 : 00 UTC +00 : 00",  "participant_number" => 0.0, "participant_reserve" => 0.0, "participants" => 0.56e2, "occasions" => "2", "group" => "10", "position" => "3", "instructor_1" => nil, "instructor_2" => nil, "instructor_3" => nil, "infotext" => "<p><strong>Den kinesiska e-handelsjätten Alibaba drar in 22 miljarder kronor under kvartalet. Samtidigt skruvar bolaget upp prognoserna.</strong></p> <p>Den kinesiska näthandelsjätten Alibaba gör ett nettoresultat på 17,4 miljarder yuan, motsvarande drygt 22 miljarder kronor, för det andra kvartalet i det brutna räkenskapsåret 2017/2018.</p><p>Samma period förra året var vinsten omkring 9 miljarder kronor. Alibaba har alltså mer än fördubblat vinsten.</p><p>Justerat resultat per aktie var 8:57 yuan. Det är betydligt högre än analytikernas förväntningar på ett resultat på 6:86 yuan per aktie, enligt Bloomberg News snittprognos.</p>", "commenttext" => nil, "ticket_info" => "Yolo", "key" => "INhjhxvPAJIDNErZ", "url_id" => "https://dinkurs.se/appliance/?event_id=47250", "url_key" => "https://dinkurs.se/appliance/?event_key=INhjhxvPAJIDNErZ", "completion_text" => "<p><strong>&amp;nbsp;Nu lanseras deras digitala kompis</strong></p> &amp;nbsp;<p>&amp;nbsp;</p><p>Under torsdagen lanseras Shim, en svensk app som vill vara en digital kompis till användaren. Appen är baserad på psykologisk forskning, men är inte avsedd som en behandling för psykisk ohälsa. Istället ska man kunna prata med Shim om vardagens bekymmer.</p><p>”Evolutionen har format oss människor till att i första hand uppmärksamma det som är negativt. Därför kan det få stora effekter om man tränar på det positiva. Samtalet med Shim är ett enkelt sätt att göra just det”, säger Hoa Ly som är medgrundare av Shim och doktor i psykologi.</p>", "aftertext" => "<p><strong>Courtagefri aktieapp når 3 miljoner användare</strong></p><p>Nätmäklaren Robinhood har nu nått tre miljoner registrerade använder, rapporterar&amp;nbsp;<a title=\"https://techcrunch.com/2017/11/01/robinhood-for-web/\" href=\"https://techcrunch.com/2017/11/01/robinhood-for-web/\" target=\"_blank\">Techcrunch</a>.</p><p>Det speciella med nätmäklaren är att de erbjuder courtagefri aktiehandel i USA.&amp;nbsp;Bolaget tjänar pengar på en premiumtjänst som låter användarna låna pengar för att handla.&amp;nbsp;</p><p><strong>Läs även:&amp;nbsp;<a title=\"https://digital.di.se/artikel/efter-courtagechocken-sigmastocks-i-samarbete-med-nordea\" href=\"https://digital.di.se/artikel/efter-courtagechocken-sigmastocks-i-samarbete-med-nordea\">Efter courtagechocken – Sigmastocks i samarbete med Nordea</a></strong></p><p>Samtidigt meddelar bolaget att transaktioner till ett värde av över 800 miljarder kronor skett i appen. Enligt bolaget har kunderna sparat courtageavgifter på drygt 8 miljarder kronor.&amp;nbsp;<br /></p>", "dates" => nil, "created_at" => nil, "updated_at" => nil, "company_id" => nil, "place" => "Demo" },
            { "id" => nil, "dinkurs_id" => "48712", "name" => "Deltagarhantering har aldrig varit enklare!", "place_geometry_location" => "(55.60756180000001, 13.003679599999941)", "host" => "Demo", "fee" => 125.0, "fee_tax" => 25.0, "pub" => " Fri, 22 Sep 2017 00 : 00 : 00 UTC +00 : 00", "apply" => " Mon, 31 Dec 2018 00 : 00 : 00 UTC +00 : 00",  "start" => " Mon, 31 Dec 2018 00 : 00 : 00 UTC +00 : 00", "stop" => " Mon, 31 Dec 2018 00 : 00 : 00 UTC +00 : 00",  "participant_number" => 0.1234e4, "participant_reserve" => 0.56e2, "participants" => 0.11e2, "occasions" => "1", "group" => "10", "position" => "3", "instructor_1" => nil, "instructor_2" => nil, "instructor_3" => nil, "infotext" => "<p><strong>Office 365 är en samlingsterm för Microsoft's cloud tjänster.&amp;nbsp;</strong></p><p>&amp;nbsp;</p><p>Saas (Software as a Service) modelen ersätter den gamla standarden av köp, nedladdgning samt installation av mjukvara på varje dator på arbetsplatsen. Grundtanken är att premuneration på tjänster ger åtkomst till ditt office 24 timmar om dygnet 365 dagar om året. Så även om du loggar in på en tablet eller smart telefon på resa, en bärbar dator i sängen eller en arbetsstation på ditt kontor, kan du komma åt alla de verktyg eller information du behöver. Flera enhe</p>", "commenttext" => nil, "ticket_info" => nil, "key" => "kNzMWFFQTWKBgLPM", "url_id" => "https://dinkurs.se/appliance/?event_id=48712", "url_key" => "https://dinkurs.se/appliance/?event_key=kNzMWFFQTWKBgLPM", "completion_text" => "<p>moms</p><p>&amp;nbsp;</p>", "aftertext" => nil, "dates" => nil, "created_at" => nil, "updated_at" => nil, "company_id" => nil, "place" => "Östergatan" },
            { "id" => nil, "dinkurs_id" => "13343", "name" => "Beställningsformulär", "place_geometry_location" => nil, "host" => "Demo Din Kurs", "fee" => 0.0, "fee_tax" => 0.0, "pub" => " Tue, 21 Aug 2012 00 : 00 : 00 UTC +00 : 00", "apply" => " Wed, 08 Jun 2022 00 : 00 : 00 UTC +00 : 00",  "start" => " Wed, 08 Jun 2022 00 : 00 : 00 UTC +00 : 00", "stop" => " Wed, 08 Jun 2022 00 : 00 : 00 UTC +00 : 00",  "participant_number" => 0.0, "participant_reserve" => 0.0, "participants" => 0.2e1, "occasions" => "0", "group" => "10", "position" => "3", "instructor_1" => nil, "instructor_2" => nil, "instructor_3" => nil, "infotext" => nil, "commenttext" => nil, "ticket_info" => nil, "key" => "pTPQREGNgBXGNMQn", "url_id" => "https://dinkurs.se/appliance/?event_id=13343", "url_key" => "https://dinkurs.se/appliance/?event_key=pTPQREGNgBXGNMQn", "completion_text" => nil, "aftertext" => nil, "dates" => nil, "created_at" => nil, "updated_at" => nil, "company_id" => nil, "place" => nil },
            { "id" => nil, "dinkurs_id" => "26230", "name" => "Intresselista", "place_geometry_location" => nil, "host" => "Demo Din Kurs", "fee" => 0.0, "fee_tax" => 0.0, "pub" => " Wed, 15 Oct 2014 00 : 00 : 00 UTC +00 : 00", "apply" => " Thu, 31 Dec 2015 00 : 00 : 00 UTC +00 : 00",  "start" => " Sun, 01 Jan 2040 00 : 00 : 00 UTC +00 : 00", "stop" => " Sun, 01 Jan 2040 00 : 00 : 00 UTC +00 : 00",  "participant_number" => 0.0, "participant_reserve" => 0.0, "participants" => 0.0, "occasions" => "0", "group" => "10", "position" => "3", "instructor_1" => nil, "instructor_2" => nil, "instructor_3" => nil, "infotext" => nil, "commenttext" => nil, "ticket_info" => nil, "key" => "LGbRBLplIUHsNJHF", "url_id" => "https://dinkurs.se/appliance/?event_id=26230", "url_key" => "https://dinkurs.se/appliance/?event_key=LGbRBLplIUHsNJHF", "completion_text" => nil, "aftertext" => nil, "dates" => nil, "created_at" => nil, "updated_at" => nil, "company_id" => nil, "place" => "Intresselista/Nyhetsbrev" },
            { "id" => nil, "dinkurs_id" => "41988", "name" => "stav", "place_geometry_location" => "(59.2911887, 18.690457000000038)", "host" => "Demo", "fee" => 300.0, "fee_tax" => 0.0, "pub" => " Mon, 14 Nov 2016 00 : 00 : 00 UTC +00 : 00", "apply" => " Thu, 24 Nov 2016 00 : 00 : 00 UTC +00 : 00",  "start" => " Sun, 01 Jan 2040 00 : 00 : 00 UTC +00 : 00", "stop" => " Sun, 01 Jan 2040 00 : 00 : 00 UTC +00 : 00",  "participant_number" => 0.12e2, "participant_reserve" => 0.0, "participants" => 0.1e1, "occasions" => "0", "group" => "10", "position" => "3", "instructor_1" => nil, "instructor_2" => nil, "instructor_3" => nil, "infotext" => "Informationstext innan anmälningsformuläret\n\nLämna denna ruta tom för att låta deltagaren komma direkt till anmälningsformuläret", "commenttext" => nil, "ticket_info" => nil, "key" => "BLQHndUsZcZHrJhR", "url_id" => "https://dinkurs.se/appliance/?event_id=41988", "url_key" => "https://dinkurs.se/appliance/?event_key=BLQHndUsZcZHrJhR", "completion_text" => nil, "aftertext" => nil, "dates" => nil, "created_at" => nil, "updated_at" => nil, "company_id" => nil, "place" => "Stavsnäs" },
        ]
        expect(dks_events.count).to eq expected_events.count
        expect(dks_events.map(&:attributes)).to match expected_events

      end

    end


    describe 'invalid company' do

      it '0 events' do

        dks_events = described_class.get_events('blorf')

        expect(dks_events).to be_a Array
        expect(dks_events.count).to eq 0
      end
    end

  end


  it '.response_url' do
    expect(described_class.response_url(['12345'])).to eq(DINKURS_XML_URL + '?' + DINKURS_COMPANY_ARG + '=12345')
  end


end
