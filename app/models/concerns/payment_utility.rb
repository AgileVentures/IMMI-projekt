module PaymentUtility
  extend ActiveSupport::Concern

  included do

    def most_recent_payment(payment_type)
      payments.completed.send(payment_type).order(:created_at).last
    end

    def payment_expire_date(payment_type)
      most_recent_payment(payment_type)&.expire_date
    end

    def payment_notes(payment_type)
      most_recent_payment(payment_type)&.notes
    end
  end

  class_methods do

    def next_payment_dates(entity_id, payment_type)
      entity = find(entity_id)

      expire_date = entity.payment_expire_date(payment_type)

      if expire_date && expire_date.future?
        start_date = expire_date + 1.day
      else
        start_date = Time.zone.today
      end

      expire_date = start_date + 1.year - 1.day

      [start_date, expire_date]
    end
  end
end
