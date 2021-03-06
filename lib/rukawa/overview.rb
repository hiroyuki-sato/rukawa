module Rukawa
  module Overview
    class << self
      def list_job_net(with_jobs: false)
        header = ["Job", "Desc"] 
        header << "Dependencies" if with_jobs
        table = Terminal::Table.new headings: header do |t|
          JobNet.subclasses.each do |job_net|
            list_table_row(t, job_net, job_net.dependencies, with_jobs: with_jobs)
          end
        end
        puts table
      end

      def list_table_row(table, job_net, level = 0, with_jobs: false)
        row = [Paint[job_net.name, :bold, :underline], job_net.desc]
        row << "" if with_jobs
        table << row
        if with_jobs
          job_net.dependencies.each do |inner_j, deps|
            table << [Paint["#{"  "}#{inner_j.name}"], inner_j.desc, deps.join(", ")]
          end
        end
      end

      def display_running_status(root_job_net)
        table = Terminal::Table.new headings: ["Job", "Status", "Elapsed Time"] do |t|
          root_job_net.each_with_index do |j|
            running_table_row(t, j)
          end
        end
        puts table
      end

    def running_table_row(table, job, level = 0)
      if job.is_a?(JobNet)
        table << [Paint["#{"  " * level}#{job.class}", :bold, :underline], Paint[job.state.colored, :bold, :underline], Paint[job.formatted_elapsed_time_from, :bold, :underline]]
        job.each do |inner_j|
          running_table_row(table, inner_j, level + 1)
        end
      else
        table << [Paint["#{"  " * level}#{job.class}", :bold], job.state.colored, job.formatted_elapsed_time_from]
      end
    end
    end
  end
end
