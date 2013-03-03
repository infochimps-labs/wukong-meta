Wukong.dataflow(:temperature_readings) do
  from_json | recordize(model: TemperatureReading) | detect_failures | to_json
end
