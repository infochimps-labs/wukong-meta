class TemperatureReading
  include Gorillib::Model
  field :timestamp,   Time,   doc: "Time at which the reading occurred", default: Proc.new { Time.now }
  field :device_id,   String, doc: "ID of the devide making the reading"
  field :temperature, Float,  doc: "The observed temperature"
  field :status,      String, doc: "The status of the event",            default: 'new'
end
