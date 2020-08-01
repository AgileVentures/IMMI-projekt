require 'rails_helper'

RSpec.describe AbstractUpdater, type: :model do

  let(:subject) { AbstractUpdater.instance }

  let(:mock_log) { instance_double("ActivityLogger") }

  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  describe 'check_requirements_and_act' do

    it 'logs activity' do
      allow(described_class).to receive(:update_requirements_checker).and_return(RequirementsForMembership)
      allow(described_class).to receive(:revoke_requirements_checker).and_return(RequirementsForRevokingMembership)

      expect(ActivityLogger).to receive(:open)
      subject.check_requirements_and_act({})
    end

    it 'has the update_requirements_checker check if the update requirements are satisfied' do
      allow(described_class).to receive(:update_requirements_checker).and_return(RequirementsForMembership)
      allow(described_class).to receive(:revoke_requirements_checker).and_return(RequirementsForRevokingMembership)

      expect(RequirementsForMembership).to receive(:satisfied?)
      subject.check_requirements_and_act({})
    end

    context 'update requirements are satisfied' do

      it 'calls update_action' do
        allow(described_class).to receive(:update_requirements_checker).and_return(RequirementsForMembership)
        allow(described_class).to receive(:revoke_requirements_checker).and_return(RequirementsForRevokingMembership)

        allow(RequirementsForMembership).to receive(:satisfied?).and_return(true)

        expect(subject).to receive(:update_action)
        expect(subject).not_to receive(:revoke_update_action)
        subject.check_requirements_and_act({})
      end
    end


    context 'update requirements are not satisfied' do

      it 'has the revoke_requirements_checker check if the revoke update requirements are satisfied' do
        allow(described_class).to receive(:update_requirements_checker).and_return(RequirementsForMembership)
        allow(described_class).to receive(:revoke_requirements_checker).and_return(RequirementsForRevokingMembership)

        allow(RequirementsForMembership).to receive(:satisfied?).and_return(false)

        expect(RequirementsForRevokingMembership).to receive(:satisfied?)
        subject.check_requirements_and_act({})
      end


      context 'revoke update requirements are satisfied' do

        it 'calls revoke_update_action' do
          allow(described_class).to receive(:update_requirements_checker).and_return(RequirementsForMembership)
          allow(described_class).to receive(:revoke_requirements_checker).and_return(RequirementsForRevokingMembership)

          allow(RequirementsForMembership).to receive(:satisfied?).and_return(false)
          allow(RequirementsForRevokingMembership).to receive(:satisfied?).and_return(true)

          expect(subject).to receive(:revoke_update_action)
          expect(subject).not_to receive(:update_action)
          subject.check_requirements_and_act({})
        end
      end

      context 'revoke update requirements are not satisfied' do

        it 'does nothing' do
          allow(described_class).to receive(:update_requirements_checker).and_return(RequirementsForMembership)
          allow(described_class).to receive(:revoke_requirements_checker).and_return(RequirementsForRevokingMembership)

          allow(RequirementsForMembership).to receive(:satisfied?).and_return(false)
          allow(RequirementsForRevokingMembership).to receive(:satisfied?).and_return(false)

          expect(subject).not_to receive(:update_action)
          expect(subject).not_to receive(:revoke_update_action)
          subject.check_requirements_and_act({})
        end
      end
    end
  end


  describe 'subclasses must define; raises NoMethodError' do

    it '.update_requirements_checker' do
      expect { described_class.update_requirements_checker }.to raise_error NoMethodError
    end

    it '.revoke_requirements_checker' do
      expect { described_class.revoke_requirements_checker }.to raise_error NoMethodError
    end

    it 'update_action' do
      expect { subject.update_action({}) }.to raise_error NoMethodError
    end

    it 'revoke_update_action' do
      expect { subject.revoke_update_action({}) }.to raise_error NoMethodError
    end
  end

end
