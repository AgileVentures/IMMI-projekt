class RemoveWaitingForPaymentStatus < ActiveRecord::Migration[5.1]
  def change
    MembershipApplication.where("state = 'waiting_for_payment'").each do |application|
      application.state = :accepted
      application.save
    end
  end
end
