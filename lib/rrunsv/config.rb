module RRunsv
  class Config
    attr_reader :fullpath, :path, :filename, :lines

    def initialize(args = {})
      @fullpath = args.delete(:fullpath).to_s
      @path = @fullpath.split("/")[0..-2].join("/")
      @filename = @fullpath.split("/").last
      @lines = []
      ensure_directory
      write(args.delete(:text).to_s)
    end

    def ensure_directory
      system("mkdir -p #{@path}")
    end

    def read
      File.read(@fullpath) if File.exist?(@fullpath)
    end

    def clear
      if File.exist?(@fullpath)
        File.delete(@fullpath)
        @lines.clear
      end
    end

    def write(text)
      clear
      lines = text.split("\n").compact.map(&:strip).reject(&:empty?)
      add_lines(lines)
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
