module Wukong
  module Meta
    class Formatter

      attr_accessor :settings

      attr_reader  :formatador
      alias_method :f, :formatador

      def initialize formatador, settings
        self.settings = settings
        @formatador = formatador
      end

      def deploy_pack_name
        (Wukong::Deploy.settings[:deploy_pack][:name] || 'unknown') rescue 'unknown'
      end
      
      def table
        @table ||= objects.map do |object|
          row = as_row(object)
          row.shift             # ignore type
          Hash[column_names.zip(row)]
        end
      end

      def list
        if settings[:to] == 'text'
          f.display_compact_table(table, column_names)
        else
          objects.each { |object| show(object) }
        end
      end

      def column_names
        []
      end

      def show label
        obj = retrieve(label)
        case settings[:to]
        when 'json'  then puts MultiJson.dump(as_hash(obj))
        when 'tsv'   then puts as_row(obj).join("\t")
        when 'text'  then display_text(obj)
        end
      end

      def retrieve label
        raise NotImplementedError.new("Override the #{self.class}#retrieve method to turn a label into an object")
      end

      def display_legend
        f.display_line "#{heading('LEGEND:')} #{color_class('Class')}, #{color_field('Field')}, #{color_model('Model')}, #{color_proc('Processor')}, #{color_flow('Dataflow')}, #{color_job('Job')}"
      end
      
      protected

      def heading text
        color text.ljust(10), :black, true
      end

      def color_class text
        color text, :cyan
      end

      def color_field text
        color text, :green
      end
      
      def color_proc text
        color text, :magenta
      end
      
      def color_flow text
        color text, :blue
      end
      
      def color_job text
        color text, :red
      end

      def color_model text
        color text, :yellow
      end
      
      def color text, name, bold=false
        settings[:to] == 'text' ? "#{'[bold]'if bold}[#{name}]#{text}[/]" : text
      end

      
      def format_field field
        {name: color_field(field.name)}.tap do |formatted_field|
          formatted_field[:type]    = color_class(field.type.respond_to?(:product) ? field.type.product : field.type)
          unless field.default.nil?
            formatted_field[:default] = field.default.is_a?(Proc) ? "<dynamically calculated>" : field.default
          end
          unless field.doc.nil? || field.doc.empty? || field.doc == "#{field.name} field"
            formatted_field[:doc]     = field.doc     if field.doc
          end
        end
      end

      def display_fields fields
        if fields.empty?
          f.display_line "#{heading('FIELDS:')} None"
        else
          f.display_line heading("FIELDS:")
          f.indent do
            f.display_compact_table(fields, [:name, :type, :default, :doc])
          end
        end
      end

      def display_description description
        if description.nil?
          f.display_line "#{heading('DOC:')} None"
        else
          f.display_line heading("DOC:")
          f.indent do
            description.split("\n").each { |line| f.display_line(line) }
          end
        end
      end
      
    end
  end
end

