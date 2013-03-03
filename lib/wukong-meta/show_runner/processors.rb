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
             when 'json'  then MultiJson.dump(processor_as_json(processor))
             when 'tsv'   then processor_as_tsv(processor).join("\t")
             when 'text'  then processor_as_text(processor)
             when 'list'  then processor_as_list(processor).join("\t")
             end
      end

      def processor_as_json processor
        {
          _id: processor.label,
          name: processor.label,
          class: processor.for_class.to_s,
          description: processor.for_class.description.to_s,
          fields: processor_fields(processor),
        }
      end

      def processor_as_tsv processor
        [
         'Processor',
         processor.label,
         processor_fields(processor).map { |field| field[:name] }.join(',')
        ].map(&:to_s)
      end
      
      def processor_as_list processor
        [
         heading('Processor'),
         color_proc(processor.label.to_s.ljust(max_label_size)),
         processor_fields(processor).map { |field| color_field(field[:name]) }.join(',')
        ]
      end
      
      def processor_as_text processor, level=1
        [
         "#{heading('PROCESSOR:', level)} #{color_proc(processor.label)}",
         "#{heading('CLASS:', level)}     #{color_proc(processor.for_class)}",
        ].tap do |lines|

          lines << ''
          if processor_fields(processor).empty?
            lines << "#{heading('Fields:', level)} None"
          else
            lines << heading("FIELDS:", level)
            processor_fields(processor).each_with_index do |field, index|
              lines << "  #{heading('NAME:', level+1)}        #{color_field(field[:name])}"
              lines << "  #{heading('TYPE:', level+1)}        #{color_field(field[:type])}"
              lines << "  #{heading('DEFAULT:', level+1)}     #{field[:default]}" if field[:default]
              lines << "  #{heading('DESCRIPTION:', level+1)} #{field[:doc]}" if field[:doc]
              lines << '' unless index == processor_fields(processor).size
            end
          end

          lines << ''
          if processor.for_class.description.nil?
            lines << "#{heading('DESCRIPTION:', level)} None"
          else
            
            lines << heading("DESCRIPTION:", level)
            lines << processor.for_class.description.split("\n").map { |line| '  ' + line }.join("\n")
          end

        end.compact.map(&:to_s)
      end

      def processor_fields processor
        [].tap do |formatted_fields|
          processor.for_class.fields.each_pair do |label, field|
            next if ignored_processor_fields.include?(label.to_s)
            formatted_fields << format_field(field)
          end
        end
      end

      def ignored_processor_fields
        @ignored_processor_fields ||= Set.new(%w[label log notifier action])
      end
      

    end
  end
end
