class CreateDinkursEvents < ActiveRecord::Migration[5.1]

  def change
    create_table :dinkurs_events, comment: "Information tracked by the DinKurs.se system about an Event" do |t|

      t.string  :dinkurs_id,                            comment: "unique identifier for the event in the DinKurs system"

      t.string  :name,                            comment: "text name of the event"
      t.string  :place_geometry_location,         comment: "location geocoordinates"
      t.string  :host,                            comment: "" # TODO what is this field?

      t.float  :fee,                             comment: "cost of the event (for a ticket)"
      t.float  :fee_tax,                         comment: "tax that is in addition to the cost"

      t.datetime  :pub,                            comment: "date the event is published?"
      t.datetime  :apply,                          comment: "TODO date ? " #TODO what is this field?
      t.datetime  :start,                          comment: "start date and time for the event"
      t.datetime  :stop,                           comment: "stop date and time for the event"

      t.numeric  :participant_number,              comment: "max. number of participants allowed for the event"
      t.numeric  :participant_reserve,             comment: "number of participants waiting for a spot to be available for the event"
      t.numeric  :participants,                    comment: "number of participants signed up for the event"

      t.string  :occasions,                        comment: "" # TODO what is this field?
      t.string  :group,                            comment: "" # TODO what is this field?

      t.string  :position,                         comment: "" # TODO what is this field?
      t.string  :instructor_1,                     comment: "name of instructor 1 for the event"
      t.string  :instructor_2,                     comment: "name of instructor 2 for the event"
      t.string  :instructor_3,                     comment: "name of instructor 3 for the event"


      t.string  :infotext,                         comment: "More text details about the event"
      t.string  :commenttext,                      comment: "" # TODO what is this field?


      t.string  :ticket_info,                      comment: "" # TODO what is this field?

      t.string  :key,                              comment: "unique identifier for DinKurs used to construct the event_url_key"
      t.string  :url_id,                           comment: "" # TODO what is this field?
      t.string  :url_key,                          comment: "" # TODO what is this field?

      t.string  :completion_text,                  comment: "" # TODO what is this field?
      t.string  :aftertext,                        comment: "" # TODO what is this field?

      t.string  :dates,                            comment: "" # TODO what is this field?


      t.timestamps
    end
  end
end
