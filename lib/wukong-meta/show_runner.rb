require_relative 'show_runner/processors'
require_relative 'show_runner/dataflows'

module Wukong
  module Meta

    # Runs the wu-show command.
    class ShowRunner < Wukong::Local::LocalRunner

      include ShowProcessors
      include ShowDataflows

      usage "[PROCESSOR|DATAFLOW]"

      description <<-EOF.gsub(/^ {8}/,'')

        wu-show shows you objects within a deploy pack.  It will show
        everything it can find by default:

          $ wu-show

        But you can also restrict it to a particular object

          $ wu-show my_processor

        It's often convenient to use the --to option so the listed
        contents can be processed downstream.

          $ wu-show my_processor --to=json
      EOF
      
      include Logging

      def validate
        true
      end

      # Shows the requested processor or dataflow or shows all
      # processors and dataflows if none was requested.
      def run
        case
        when processor && processor?(processor)
          show_processor(Wukong.registry.retrieve(processor.to_sym))
        when processor && dataflow?(processor)
          show_dataflow(Wukong.registry.retrieve(processor.to_sym))
        else
          if settings[:to] == 'text'
            list_max_sizes[:label] = (processors + dataflows).map { |proc| proc.label.size          }.max
            list_max_sizes[:class] = (processors + dataflows).map { |proc| proc.for_class.to_s.size }.max
          end
          list_dataflows
          list_processors
        end
      end

      protected

      def list_max_sizes
        @list_max_sizes ||= {label: 10, class: 10}
      end

      def green text
        $stdout.tty? ? "\e[32m\e[1m#{text}\e[0m" : text
      end

      def blue text
        $stdout.tty? ? "\e[34m\e[1m#{text}\e[0m" : text
      end
      
    end
  end
end
