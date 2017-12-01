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
      # Business rules:
      # start_date = prior payment expire date + 1 day
      # expire_date = start_date + 1 year - 1 day
      # (special rules apply for remainder of 2017)
      entity = find(entity_id)

      payment_found = false

      expire_date = entity.payment_expire_date(payment_type)

      if expire_date
        start_date = expire_date + 1.day
        payment_found = true
      else
        start_date = Time.zone.today
      end

      if (Time.zone.today.year == 2017) && !payment_found
        expire_date = Time.zone.local(2018, 12, 31)
      else
        expire_date = start_date + 1.year - 1.day
      end
      [start_date, expire_date]
    end
  end
end
