module Wukong
  module Meta
    module ShowProcessors
      
      def processors
        @processors ||= Wukong.registry.show.values.find_all { |val| processor?(val.label) }.sort_by { |proc| proc.label }
      end

      def list_processors
        settings[:to] = 'list' if settings[:to] == 'text'
        processors.each { |proc| show_processor(proc) }
      end
      
      def show_processor processor
        puts case settings[:to]
             when 'json'  then show_processor_as_json(processor)
             when 'tsv'   then show_processor_as_tsv(processor)
             when 'text'  then show_processor_as_text(processor)
             when 'list'  then show_processor_as_list(processor)
             end
      end

      def show_processor_as_json processor
        MultiJson.dump({
                         __id: processor.label,
                         name: processor.label,
                         class: processor.for_class.to_s,
                         description: processor.for_class.description.to_s,
                         fields: processor_fields(processor),
                       })
      end

      def show_processor_as_tsv processor
        [
         'Processor',
         processor.label,
         processor.for_class
        ].map(&:to_s).join("\t")
      end
      
      def show_processor_as_list processor
        [
         'Processor',
         processor.label.to_s.ljust(list_max_sizes[:label]),
         processor.for_class.to_s.ljust(list_max_sizes[:class])
        ].join("\t")
      end
      
      def show_processor_as_text processor
        [
         "#{green('PROCESSOR:')} #{processor.label}",
         "#{green('CLASS:')}     #{processor.for_class}",
        ].tap do |lines|

          lines << ''
          if processor_fields(processor).empty?
            lines << "#{green('Fields:')} None"
          else
            lines << green("FIELDS:")
            processor_fields(processor).each_with_index do |field, index|
              lines << "  #{blue('NAME:')}        #{field[:name]}"
              lines << "  #{blue('TYPE:')}        #{field[:type]}"
              lines << "  #{blue('DEFAULT:')}     #{field[:default] || 'nil'}"
              lines << "  #{blue('DESCRIPTION:')} #{field[:doc]}" if field[:doc]
              lines << '' unless index == processor_fields(processor).size
            end
          end

          lines << ''
          if processor.for_class.description.nil?
            lines << "#{green('DESCRIPTION:')} None"
          else
            
            lines << green("DESCRIPTION:")
            lines << processor.for_class.description.split("\n").map { |line| '  ' + line }.join("\n")
          end

        end.compact.map(&:to_s).join("\n")
      end

      def processor_fields processor
        [].tap do |formatted_fields|
          processor.for_class.fields.each_pair do |label, field|
            next if ignored_processor_fields.include?(label.to_s)
            formatted_fields << format_processor_field(field)
          end
        end
      end

      def ignored_processor_fields
        @ignored_processor_fields ||= Set.new(%w[label log notifier action])
      end
      
      def format_processor_field field
        {name: field.name}.tap do |formatted_field|
          formatted_field[:type]    = field.type.product
          formatted_field[:default] = field.default unless field.default.nil?
          formatted_field[:doc]     = field.doc     if field.doc
        end
      end

    end
  end
end
