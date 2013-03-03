require_relative("../formatter")

module Wukong
  module Meta
    class DataflowsFormatter < Formatter

      def objects
        @objects ||= Wukong.registry.show.values.find_all do |builder|
          builder.class == Wukong::DataflowBuilder
        end.sort_by { |flow| flow.label.to_s }
      end

      def retrieve label_or_flow
        return label_or_flow if label_or_flow.respond_to?(:label)
        Wukong.registry.retrieve(label_or_flow.to_sym)
      end

      def column_names
        [:name, :stages]
      end

      def as_hash dataflow
        {
          _id:    dataflow.label,
          type:   "Dataflow",
          name:   dataflow.label,
          class:  dataflow.for_class.to_s,
          stages: dataflow.stages.map { |label, stage| label },
          edges:  dataflow.links.map  { |link| { from: link.from, into: link.into } },
        }
      end
      
      def as_row dataflow
        hsh = as_hash(dataflow)
        [
         hsh[:type],
         color_flow(hsh[:name]),
         topology(dataflow),
        ].map(&:to_s)
      end

      def display_text dataflow
        f.display_line "#{heading('DATAFLOW:')} #{color_flow(dataflow.label)}"
        f.display_line "#{heading('CLASS:')} #{color_class(dataflow.for_class.to_s)}"
        f.display_line heading("TOPOLOGY:")
        f.indent do
          f.display_line display_diagram(dataflow)
        end
      end

      def display_diagram dataflow
        f.display_line(topology(dataflow))
      end

      def topology dataflow
        ''.tap do |line|
          size = dataflow.links.size
          dataflow.links.each_with_index do |link, index|
            case
            when index == 0
              line << node(link.from)
            when index == size - 1
              line << "#{arrow}#{node(link.from)}"
              line << "#{arrow}#{node(link.into)}"
            else
              line << "#{arrow}#{node(link.from)}"
            end
          end
        end        
      end

      def node node
        color_proc(node.to_s)
      end
      
      def arrow
        " -> "
      end
    end
  end
end
