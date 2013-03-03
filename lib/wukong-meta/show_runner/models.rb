module Wukong
  module Meta
    module ShowModels

      class Model
        
        attr_accessor :path
        
        def initialize path
          self.path = path
        end
        
        def relative_path
          self.path.relative_path_from(Wukong::Deploy.root)
        end
        
        def label
          File.basename(self.path, '.rb').to_sym
        end
      end

      def models
        @models ||= [].tap do |m|
          ObjectSpace.each_object(::Class) do |klass|
            next if klass.to_s =~ /^(Gorillib|Hanuman|Wukong|Vayacondios)/
            next if klass.to_s =~ /^#/
            m << klass if klass.included_modules.include?(Gorillib::Model)
          end
        end.sort_by { |model| model.to_s }
      end

      def model? model_name
        model_name && models.any? { |model| model.to_s == model_name }
      end
      
      def list_models
        settings[:to] = 'list' if settings[:to] == 'text'
        models.each { |model| show_model(model) }
      end
      
      def show_model model
        puts case settings[:to]
        when 'json'  then MultiJson.dump(model_as_json(model))
        when 'tsv'   then model_as_tsv(model).join("\t")
        when 'text'  then model_as_text(model)
        when 'list'  then model_as_list(model).join("\t")
        end
      end

      def model_as_json model
        {
          _id:  model.to_s,
          name: model.to_s,
          fields: model_fields(model),
        }
      end
      
      def model_as_tsv model
        [
         'Model',
         model.to_s,
         model_fields(model).map { |field| field[:name] }.join(',')
        ].map(&:to_s)
      end
      
      def model_as_list model
        [
         heading('Model   '),
         color_model(model.to_s.ljust(max_label_size)),
         model_fields(model).map { |field| color_field(field[:name]) }.join(',')
        ]
      end

      def model_as_text model, level=1
        [
         "#{heading('MODEL:')} #{color_model(model.to_s)}",
        ].tap do |lines|
          if model_fields(model).empty?
            lines << "#{heading('Fields:', level)} None"
          else
            lines << heading("FIELDS:", level)
            model_fields(model).each_with_index do |field, index|
              lines << "  #{heading('NAME:', level+1)}        #{color_field(field[:name])}"
              lines << "  #{heading('TYPE:', level+1)}        #{color_field(field[:type])}"
              lines << "  #{heading('DEFAULT:', level+1)}     #{field[:default]}" if field[:default]
              lines << "  #{heading('DESCRIPTION:', level+1)} #{field[:doc]}" if field[:doc]
              lines << '' unless index == model_fields(model).size
            end
          end
        end
      end

      def model_fields model
        [].tap do |formatted_fields|
          model.fields.each_pair do |label, field|
            formatted_fields << format_field(field)
          end
        end
      end

    end
  end
end
