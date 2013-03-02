module Wukong
  module Meta
    module ShowJobs

      # FIXME -- this should really be somewhere in Wukong-Hadoop
      class Job
        
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
        
        def load!
          # FIXME -- I shouldn't have to reach inside the registry
          # like this.  It should provide a delete method.
          Hanuman::Registry::REGISTRY.delete(:mapper)
          Hanuman::Registry::REGISTRY.delete(:reducer)
          Kernel.load(path)
        end
        
        def mapper
          Wukong.registry.retrieve(:mapper)
        end

        def reducer
          Wukong.registry.retrieve(:reducer)
        end

        def type
          mapper && reducer ? "map/reduce" : "map"
        end

      end

      def job_files
        @job_files ||= Dir[Wukong::Deploy.app_dir.join('jobs/**/*.rb')].map { |path| Pathname.new(path) }
      end

      def jobs
        @jobs ||= Hash[job_files.map { |file| job = Job.new(file) ; [job.label, job] }]
      end

      def job? job_name
        job_name && jobs.include?(job_name.to_sym)
      end
      
      def list_jobs
        settings[:to] = 'list' if settings[:to] == 'text'
        jobs.keys.sort.each { |job_label| show_job(jobs[job_label]) }
      end
      
      def show_job job
        job.load!
        puts case settings[:to]
        when 'json'  then MultiJson.dump(job_as_json(job))
        when 'tsv'   then job_as_tsv(job).join("\t")
        when 'text'  then job_as_text(job)
        when 'list'  then job_as_list(job).join("\t")
        end
      end

      def job_as_json job
        {
          _id:  job.label,
          name: job.label,
          path: job.relative_path,
          type: job.type,
        }.tap do |json|
          case job.mapper
          when DataflowBuilder
            json[:mapper] = dataflow_as_json(job.mapper)
          when ProcessorBuilder
            json[:mapper] = processor_as_json(job.mapper)
          end

          case job.reducer
          when DataflowBuilder
            json[:reducer] = dataflow_as_json(job.reducer)
          when ProcessorBuilder
            json[:reducer] = processor_as_json(job.reducer)
          end
          
        end
      end
      
      def job_as_tsv job
        [
         'Job',
         job.label,
         job.relative_path,
         job.type,
        ].map(&:to_s)
      end
      
      def job_as_list job
        [
         'Job     ',
         color_job(job.label.to_s.ljust(max_label_size)),
         job.relative_path.to_s.ljust(max_path_size),
         job.type,
        ]
      end

      def job_as_text job, level=1
        [
         "#{heading('JOB:')}  #{color_job(job.label)}",
         "#{heading('PATH:')} #{color_job(job.relative_path)}",
        ].tap do |lines|
          case job.mapper
          when DataflowBuilder
            lines << ''
            lines << heading("MAPPER:", level)
            lines.concat(dataflow_as_text(job.mapper, level+1).map { |line| '  ' + line })
          when ProcessorBuilder
            lines << ''
            lines << heading("MAPPER:", level)
            lines.concat(processor_as_text(job.mapper, level+1).map { |line| '  ' + line })
          end
          
          case job.reducer
          when DataflowBuilder
            lines << heading("REDUCER:", level)
            lines.concat(dataflow_as_text(job.reducer, level+1).map { |line| '  ' + line })
          when ProcessorBuilder
            lines << heading("REDUCER:", level)
            lines.concat(processor_as_text(job.reducer, level+1).map { |line| '  ' + line })
          end
        end
      end

    end
  end
end
