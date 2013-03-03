require_relative("../formatter")

module Wukong
  module Meta
    class JobsFormatter < Formatter

      attr_reader :dataflows_formatter, :processors_formatter

      def initialize formatador, settings, processors_formatter, dataflows_formatter
        super(formatador, settings)
        @processors_formatter = processors_formatter
        @dataflows_formatter  = dataflows_formatter
      end

      def job_files
        @job_files ||= Dir[Wukong::Deploy.app_dir.join('jobs/**/*.rb')].map { |path| Pathname.new(path) }
      end

      def objects
        @jobs ||= job_files.map { |file| Job.new(file) }.sort_by { |job| job.label }
      end

      def retrieve label_or_job
        return label_or_job if label_or_job.respond_to?(:label)
        objects.detect { |job| job.label.to_s == label_or_job }
      end

      def job? name
        name && objects.any? { |job| job.label.to_s == name }
      end
      
      def column_names
        [:type, :name, :path, :mapper, :reducer]
      end

      def as_hash job
        {
          _id:  job.label,
          type: "Job",
          name: job.label,
          path: job.relative_path,
        }.tap do |json|

          unless job.processors.empty?
            json[:processors] = job.processors.map { |proc| processors_formatter.as_hash(proc) }
          end
          
          case job.mapper
          when DataflowBuilder
            json[:mapper] = dataflows_formatter.as_hash(job.mapper)
          when ProcessorBuilder
            json[:mapper] = processors_formatter.as_hash(job.mapper)
          end

          case job.reducer
          when DataflowBuilder
            json[:reducer] = dataflows_formatter.as_hash(job.reducer)
          when ProcessorBuilder
            json[:reducer] = processors_formatter.as_hash(job.reducer)
          end
          
        end
      end
      
      def as_tsv job
        hsh = as_hash(job)
        [
         hsh[:type],
         color_job(hsh[:name]),
         hsh[:path]
        ].tap do |tsv|
          case job.mapper
          when DataflowBuilder
            tsv << dataflows_formatter.topology(job.mapper)
          when ProcessorBuilder
            tsv << color_proc(job.mapper.label)
          else
            tsv << '<none>'
          end

          case job.reducer
          when DataflowBuilder
            tsv << dataflows_formatter.topology(job.reducer)
          when ProcessorBuilder
            tsv << color_proc(job.reducer.label)
          else
            tsv << '<none>'
          end
        end.map(&:to_s)
      end
      
      def display_text job
        f.display_line "#{heading('JOB:')} #{color_job(job.label)}"
        f.display_line "#{heading('PATH:')} #{job.relative_path}"
        unless job.processors.empty?
          f.display_line ''
          f.display_line heading("PROCESSORS:")
          job.processors.each do |proc|
            f.indent { processors_formatter.display_text(proc) }
          end
        end

        f.display_line ''
        case job.mapper
        when DataflowBuilder
          f.display_line heading("MAPPER:")
          f.indent { dataflows_formatter.display_text(job.mapper) }
        when ProcessorBuilder
          f.display_line heading("MAPPER:")
          f.indent { processors_formatter.display_text(job.mapper) }
        else
          f.display_line "#{heading('MAPPER:')} None"
        end
          
        case job.reducer
        when DataflowBuilder
          f.display_line heading("REDUCER:")
          f.indent { dataflows_formatter.display_text(job.reducer) }
        when ProcessorBuilder
          f.display_line heading("REDUCER:")
          f.indent { processors_formatter.display_text(job.reducer) }
        else
          f.display_line "#{heading('REDUCER:')} None"
        end
      end

      # FIXME -- this should really be somewhere in Wukong-Hadoop
      class Job

        attr_accessor :path, :mapper, :reducer, :processors, :dataflows

        def self.processors_and_flows
          @processors_and_flows ||= Set.new(Wukong.registry.show.keys)
        end

        def self.register_new_processors_and_flows
          @processors_and_flows = Set.new(Wukong.registry.show.keys)
        end
        
        def initialize path
          self.path = path
          load!
        end
        
        def relative_path
          self.path.relative_path_from(Wukong::Deploy.root)
        end
        
        def label
          File.basename(self.path, '.rb').to_sym
        end
        
        def load!
          existing_processors_and_flows = self.class.processors_and_flows.dup
          
          # FIXME -- I shouldn't have to reach inside the registry
          # like this.  It should provide a delete method.
          Hanuman::Registry::REGISTRY.delete(:mapper)
          Hanuman::Registry::REGISTRY.delete(:reducer)

          Kernel.load(path)
          
          self.class.register_new_processors_and_flows

          self.mapper  = Wukong.registry.retrieve(:mapper)
          self.reducer = Wukong.registry.retrieve(:reducer)

          new_processors_and_flows = self.class.processors_and_flows - existing_processors_and_flows - Set.new([:mapper, :reducer])

          self.processors = new_processors_and_flows
            .map     { |label| Wukong.registry.retrieve(label) }
            .reject  { |obj|   obj.is_a?(DataflowBuilder)      }
            .sort_by { |proc|  proc.label                      }

          self.dataflows = new_processors_and_flows
            .map     { |label| Wukong.registry.retrieve(label) }
            .reject  { |obj|   obj.is_a?(ProcessorBuilder)     }
            .sort_by { |flow|  flow.label                      }
        end

      end
      
    end
  end
end
