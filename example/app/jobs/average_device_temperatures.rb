Wukong.dataflow(:mapper) do
  from_json | recordize(model: TemperatureReading) | map { |temperature_reading| [temperature_reading.device, temperature_reading.temperature] } | to_tsv
end

Wukong.processor(:average_temperature_of_device, Wukong::Processor::Accumulator) do
  attr_accessor :temperatures
  def get_key record
    record.first
  end
  def start record
    self.temperatures = []
  end
  def accumulate record
    temperatures << record.last.to_f
  end
  def finalize
    yield [key, average_temperature]
  end
  def average_temperature
    return if temperatures.empty?
    temperatures.inject(0.0) { |sum, summand| sum += summand } / temperatures.length
  end
end


Wukong.dataflow(:reducer) do
  from_tsv | average_temperature_of_device | to_tsv
end
