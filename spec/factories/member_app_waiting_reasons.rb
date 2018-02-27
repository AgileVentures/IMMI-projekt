FactoryBot.define do

  factory :member_app_waiting_reason, class: AdminOnly::MemberAppWaitingReason do

    name_sv "anledning namn"
    description_sv "anledning beskrivning"
    name_en "reason name"
    description_en "reason description"

    is_custom false

  end

end
