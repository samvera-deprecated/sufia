module Sufia
  module Import
    class ErrorLog
      class << self
        def error(message)
          file.write(message)
          file.flush
        end

        def file
          @file ||= open_file
          @file = validate(@file)
        end

        private

        def validate(file)
          return open_file unless File.exist?(file.path)
          file
        end

        def open_file
          File.open("import_error_log.out", (File::WRONLY | File::APPEND | File::CREAT))
        end
      end
    end
  end
end
