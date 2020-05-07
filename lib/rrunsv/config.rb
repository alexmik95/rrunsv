module RRunsv
  class Config
    attr_reader :fullpath, :path, :filename, :lines

    def initialize(params = {})
      @fullpath = params.delete(:fullpath).to_s
      @path = @fullpath.split("/")[0..-2].join("/")
      @filename = @fullpath.split("/").last
      @lines = []
      ensure_directory
      write(params.delete(:text).to_s)
    end

    def read
      File.read(@fullpath) if File.exist?(@fullpath)
    end

    def write(text)
      if dir_exist?
        clear
        lines = text.split("\n").compact.map(&:strip).reject(&:empty?)
        add_lines(lines)
      end
    end

    def clear
      if File.exist?(@fullpath)
        File.delete(@fullpath)
        @lines.clear
      end
    end

    private

    def ensure_directory
      system("mkdir -p #{@path}") unless @path.nil?
    end

    def dir_exist?
      Dir.exist?(@path)
    end

    def add_lines(lines = [])
      File.open(@fullpath, "a") do |file|
        lines.each do |line|
          file.write(line)
          @lines << line
        end
      end
      self
    end
  end
end
