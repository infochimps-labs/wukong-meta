require_relative("../formatter")

module Wukong
  module Meta
    class ProcessorsFormatter < Formatter
      
      def objects
        @objects ||= Wukong.registry.show.values.find_all do |builder|
          builder.is_a?(ProcessorBuilder) && !Wukong::BUILTINS.include?(builder.label)
        end.sort_by { |proc_builder| proc_builder.label }
      end

      def retrieve label_or_flow
        return label_or_flow if label_or_flow.respond_to?(:label)
        Wukong.registry.retrieve(label_or_flow.to_sym)
      end

      def column_names
        [:type, :name, :fields]
      end
      
      def as_hash processor
        {
          _id:         processor.label,
          type:        "Processor",
          name:        processor.label,
          class:       processor.for_class.to_s,
          description: processor.for_class.description.to_s,
          fields:      fields(processor),
        }
      end

      def as_tsv processor
        hsh = as_hash(processor)
        [
         hsh[:type],
         color_proc(hsh[:name]),
         hsh[:fields].map { |field| color_field(field[:name]) }.join(','),
        ].map(&:to_s)
      end
      
      def display_text processor
        f.display_line "#{heading('PROCESSOR:')} #{color_proc(processor.label)}"
        f.display_line "#{heading('CLASS:')} #{color_class(processor.for_class)}"
        display_fields(fields(processor))
        display_description(processor.for_class.description)
      end

      def fields processor
        [].tap do |formatted_fields|
          processor.for_class.fields.each_pair do |label, field|
            next if ignored_fields.include?(label.to_s)
            formatted_fields << format_field(field)
          end
        end
      end

      def ignored_fields
        @ignored_fields ||= Set.new(%w[label log notifier action])
      end
      
    end
  end
end
