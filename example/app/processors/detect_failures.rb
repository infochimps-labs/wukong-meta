Wukong.processor(:detect_failures) do
  field :threshold, Float, doc: "Maximum safe operating temperature", default: "100"
  description <<-EOF.gsub(/^ {4}/, '')
    Detects failures from devices with a temperature greater than the
    threshold.
  EOF
end
