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
        when 'json'  then show_dataflow_as_json(dataflow)
        when 'tsv'   then show_dataflow_as_tsv(dataflow)
        when 'text'  then show_dataflow_as_text(dataflow)
        when 'list'  then show_dataflow_as_list(dataflow)
        end
      end

      def show_dataflow_as_json dataflow
        MultiJson.dump({
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
                       )
      end
      
      def show_dataflow_as_tsv dataflow
        [
         'Dataflow',
         dataflow.label,
         dataflow.for_class
        ].map(&:to_s).join("\t")
      end
      
      def show_dataflow_as_list dataflow
        [
         'Dataflow',
         dataflow.label.to_s.ljust(list_max_sizes[:label]),
         dataflow.for_class.to_s.ljust(list_max_sizes[:class])
        ].join("\t")
      end

      def show_dataflow_as_text dataflow
        [
         "#{green('DATAFLOW:')} #{dataflow.label}",
         "#{green('CLASS:')}    #{dataflow.for_class}",
         '',
         green("TOPOLOGY:"),
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
              line << link.from.to_s
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
        node.to_s
      end

      def dataflow_arrow
        blue("->")
      end
      
    end
  end
end
