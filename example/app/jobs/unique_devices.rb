Wukong.dataflow(:mapper) do
  from_json | recordize(model: TemperatureReading) | map { |temperature_reading| temperature_reading.device_id }
end

Wukong.processor(:reducer, Wukong::Processor::Uniq)
