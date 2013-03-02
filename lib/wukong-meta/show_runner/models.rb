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

      def model_files
        @model_files ||= Dir[Wukong::Deploy.app_dir.join('models/**/*.rb')].map { |path| Pathname.new(path) }
      end

      def models
        @models ||= Hash[model_files.map { |file| model = Model.new(file) ; [model.label, model] }]
      end

      def model? model_name
        model_name && models.include?(model_name.to_sym)
      end
      
      def list_models
        settings[:to] = 'list' if settings[:to] == 'text'
        models.keys.sort.each { |model_label| show_model(models[model_label]) }
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
          _id:  model.label,
          name: model.label,
        }
      end
      
      def model_as_tsv model
        [
         'Model',
         model.label,
        ].map(&:to_s)
      end
      
      def model_as_list model
        [
         'Model   ',
         color_model(model.label.to_s.ljust(max_label_size)),
        ]
      end

      def model_as_text model, level=1
        [
         "#{heading('MODEL:')} #{color_model(model.label)}",
        ]
      end

    end
  end
end
