require_relative("../formatter")

module Wukong
  module Meta
    class ModelsFormatter < Formatter

      def objects
        @objects ||= [].tap do |m|
          ObjectSpace.each_object(::Class) do |klass|
            next if klass.to_s =~ /^(Gorillib|Hanuman|Wukong|Vayacondios)/
            next if klass.to_s =~ /^#/
            m << klass if klass.included_modules.include?(Gorillib::Model)
          end
        end.sort_by { |model| model.to_s }
      end

      def retrieve label_or_model
        return label_or_model if label_or_model.respond_to?(:fields)
        models.detect { |model| model.to_s == label_or_model.to_s }
      end

      def column_names
        [:name, :fields]
      end

      def model? name
        name && objects.any? { |model| model.to_s == name }
      end
      
      def as_hash model
        {
          _id:            "#{deploy_pack_name}-#{model}",
          _type:          "deploy_pack_models",
          deploy_pack_id: deploy_pack_name,
          updated_at:     Time.now.iso8601,
          name:           model.to_s,
          fields:         fields(model),
        }
      end
      
      def as_row model
        hsh = as_hash(model)
        [
         hsh[:type],
         color_model(hsh[:name]),
         hsh[:fields].map { |field| color_field(field[:name]) }.join(','),
        ].map(&:to_s)
      end

      def display_text model
        f.display_line "#{heading('MODEL:')} #{color_model(model.to_s)}"
        display_fields(fields(model))
      end

      def fields model
        [].tap do |formatted_fields|
          model.fields.each_pair do |label, field|
            formatted_fields << format_field(field)
          end
        end
      end

    end
  end
end
