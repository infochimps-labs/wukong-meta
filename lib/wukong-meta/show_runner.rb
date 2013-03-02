require_relative 'show_runner/processors'
require_relative 'show_runner/dataflows'
require_relative 'show_runner/jobs'
require_relative 'show_runner/models'

module Wukong
  module Meta

    # Runs the wu-show command.
    class ShowRunner < Wukong::Runner

      include ShowProcessors
      include ShowDataflows
      include ShowJobs
      include ShowModels

      usage "[PROCESSOR|DATAFLOW|JOB|MODEL|processors|dataflows|jobs|models]"

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

      def arg
        args.first
      end

      # Shows the requested processor or dataflow or shows all
      # processors and dataflows if none was requested.
      def run
        case
        when arg == 'processors' then list_processors
        when arg == 'dataflows'  then list_dataflows
        when arg == 'jobs'       then list_jobs
        when arg == 'models'     then list_models
        when processor?(arg)
          show_processor(Wukong.registry.retrieve(arg.to_sym))
        when dataflow?(arg)
          show_dataflow(Wukong.registry.retrieve(arg.to_sym))
        when job?(arg)
          show_job(jobs[arg.to_sym])
        when model?(arg)
          show_model(models[arg.to_sym])
        else
          list_models
          list_processors
          list_dataflows
          list_jobs
        end
      end

      def max_label_size
        @max_label_size ||= (processors + dataflows + jobs.values).map { |thing| thing.label.size }.max
      end

      def max_path_size
        @max_path_size ||= (jobs.values).map { |thing| thing.relative_path.to_s.size }.max
      end
      
      protected

      def heading text, level=1
        case level
        when 1 then color text, :green
        when 2 then color text, :black,
        else        color text, :black, false
        end
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
        color text, :yellow, false
      end
      
      # http://en.wikipedia.org/wiki/ANSI_escape_code#Colors
      COLORS = {}.tap do |colors|
        %w[black red green yellow
           blue magenta cyan white].each_with_index do |color, index|
          colors[color.to_sym] = 30 + index
        end
      end
      
      def color text, name, bold=true
        return text unless $stdout.tty?
        %Q{\e[#{COLORS[name]}m#{bold ? "\e[1m" : ""}#{text}\e[0m}
      end
      
    end
  end
end
