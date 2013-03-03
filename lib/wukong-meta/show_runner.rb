require_relative 'formatters/models'
require_relative 'formatters/processors'
require_relative 'formatters/dataflows'
require_relative 'formatters/jobs'

module Wukong
  module Meta

    # Runs the wu-show command.
    class ShowRunner < Wukong::Runner
      
      usage "[legend|processors|dataflows|jobs|models|PROCESSOR|DATAFLOW|JOB|MODEL]"

      description <<-EOF.gsub(/^ {8}/,'')

        wu-show shows you objects within a deploy pack.  It will show
        everything it can find by default:

          $ wu-show

        But you can also restrict it to a particular object

          $ wu-show my_processor

        Or kind of object

          $ wu-show processors

        It's often convenient to use the --to option so the listed
        contents can be processed downstream.

          $ wu-show my_processor --to=json
      EOF
      
      include Logging

      attr_reader :formatador
      alias_method :f, :formatador
      
      def initialize settings=Configliere::Param.new
        super(settings)
        require 'formatador'
        @formatador = Formatador.new
      end
      
      def arg
        args.first
      end

      # Shows the requested processor or dataflow or shows all
      # processors and dataflows if none was requested.
      def run
        case
        when arg == 'legend'     then models_formatter.display_legend
        when arg == 'models'     then models_formatter.list
        when arg == 'processors' then processors_formatter.list
        when arg == 'dataflows'  then dataflows_formatter.list
        when arg == 'jobs'       then jobs_formatter.list      
        when models_formatter.model?(arg)
          models_formatter.show(arg.constantize)
        when processor?(arg)
          processors_formatter.show(arg)
        when dataflow?(arg)
          dataflows_formatter.show(arg)
        when jobs_formatter.job?(arg)
          jobs_formatter.show(arg)
        when arg
          raise Wukong::Error.new("No such model, processor, dataflow, or job <#{arg}>")
        else
          list_all
        end
      end
      
      def list_all
        Formatador.display_line "[bold]Models:[/]"     if settings[:to] == 'text'
        models_formatter.list
        if settings[:to] == 'text'
          Formatador.display_line ""
          Formatador.display_line "[bold]Processors:[/]"
        end
        processors_formatter.list
        if settings[:to] == 'text'
          Formatador.display_line ""
          Formatador.display_line "[bold]Dataflows:[/]"
        end
        dataflows_formatter.list
        if settings[:to] == 'text'
          Formatador.display_line ""
          Formatador.display_line "[bold]Jobs:[/]"
        end
        jobs_formatter.list
      end

      def models_formatter
        @models_formatter ||= ModelsFormatter.new(formatador, settings)
      end
      
      def processors_formatter
        @processors_formatter ||= ProcessorsFormatter.new(formatador, settings)
      end
      
      def dataflows_formatter
        @dataflows_formatter ||= DataflowsFormatter.new(formatador, settings)
      end
      
      def jobs_formatter
        @jobs_formatter ||= JobsFormatter.new(formatador, settings, processors_formatter, dataflows_formatter)
      end
      
    end
  end
end
