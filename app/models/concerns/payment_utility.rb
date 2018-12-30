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
        start_date = Time.zone.today  # can't use this to determine how many days OVERDUE the membership payment is!
      end

      expire_date = expire_date_for_start_date(start_date)

      [start_date, expire_date]
    end


    # THIS IS THE KEY RULE ABOUT WHEN PAYMENTS EXPIRE:
    def expire_date_for_start_date(start_date)
      start_date + 1.year - 1.day
    end

  end
end
