module Wukong
  module Meta
    module ShowDataflows

      def dataflows
        @dataflows ||= Wukong.registry.show.values.find_all { |val| val.class == Wukong::DataflowBuilder }.sort_by { |flow| flow.label.to_s }
      end

      def list_dataflows
        settings[:to] = 'list' if settings[:to] == 'text'        
        dataflows.each { |flow| show_dataflow(flow) }
      end
      
      def show_dataflow dataflow
        puts case settings[:to]
             when 'json'  then MultiJson.dump(dataflow_as_json(dataflow))
             when 'tsv'   then dataflow_as_tsv(dataflow).join("\t")
             when 'text'  then dataflow_as_text(dataflow)
             when 'list'  then dataflow_as_list(dataflow).join("\t")
             end
      end

      def dataflow_as_json dataflow
        {
          _id: dataflow.label,
          name: dataflow.label,
          class: dataflow.for_class.to_s,
          stages: [],
          edges: [],
        }.tap do |json|
          dataflow.stages.each do |label, stage|
            json[:stages] << stage.label
          end
          dataflow.links.each do |link|
            json[:edges] << {
              from: link.from,
              into: link.into,
            }
          end
        end
      end
      
      def dataflow_as_tsv dataflow
        [
         'Dataflow',
         dataflow.label,
         dataflow.stages.map(&:first).uniq.map(&:to_s).join(',')
        ].map(&:to_s)
      end
      
      def dataflow_as_list dataflow
        [
         heading('Dataflow'),
         color_flow(dataflow.label.to_s.ljust(max_label_size)),
         dataflow.stages.map(&:first).uniq.map { |label| color_proc(label) }.join(',')
        ]
      end

      def dataflow_as_text dataflow, level=1
        [
         "#{heading('DATAFLOW:', level)} #{color_flow(dataflow.label)}",
         "#{heading('CLASS:', level)}    #{color_flow(dataflow.for_class.to_s)}",
         '',
         heading("TOPOLOGY:", level),
         '',
         '  ' + dataflow_diagram(dataflow),
         '',
        ]
      end

      def dataflow_diagram dataflow
        ''.tap do |line|
          size = dataflow.links.size
          dataflow.links.each_with_index do |link, index|
            case
            when index == 0
              line << dataflow_node(link.from)
            when index == size - 1
              line << " #{dataflow_arrow} #{dataflow_node(link.from)}"
              line << " #{dataflow_arrow} #{dataflow_node(link.into)}"
            else
              line << " #{dataflow_arrow} #{dataflow_node(link.from)}"
            end
          end
        end
      end

      def dataflow_node node
        color_proc(node.to_s)
      end

      def dataflow_arrow
        "->"
      end
      
    end
  end
end
