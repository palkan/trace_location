# frozen_string_literal: true

module TraceLocation
  module Generator
    class Markdown < Base # :nodoc:
      def initialize(events, return_value, options)
        super
        @current_dir = ::TraceLocation.config.current_dir
        @dest_dir = options.fetch(:dest_dir) { ::TraceLocation.config.dest_dir }
        @current = Time.now
        @filename = "trace_location-#{@current.strftime('%Y%m%d%H%m%s')}.md"
        @file_path = File.join(@dest_dir, @filename)
      end

      def generate
        setup_dir
        create_file
        $stdout.puts "Created at #{file_path}"
      end

      private

      attr_reader :events, :return_value, :current_dir, :dest_dir, :current, :filename, :file_path

      def setup_dir
        FileUtils.mkdir_p(dest_dir)
      end

      def create_file
        File.open(file_path, 'wb+') do |io|
          io.write <<~MARKDOWN
            Generated by [trace_location](https://github.com/yhirano55/trace_location) at #{current}

          MARKDOWN

          events.select(&:call?).each do |e|
            path = e.path.to_s.gsub(%r{#{current_dir}/}, '')
            caller_path = e.caller_path.to_s.gsub(%r{#{current_dir}/}, '')

            io.write <<~MARKDOWN
              <details open>
              <summary>#{path}:#{e.lineno}</summary>

              ##### #{e.owner_with_name}

              ```ruby
              #{e.source}
              # called from #{caller_path}:#{e.caller_lineno}
              ```
              </details>
            MARKDOWN
          end
        end
      end
    end
  end
end
