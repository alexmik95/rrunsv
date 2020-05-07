module RRunsv
  class Service
    attr_reader :id, :run_text, :config

    def initialize(args = {})
      @id = parse_id(args.delete(:fork_id))
      @run_text = args.delete(:run_text)
      config_path = args.delete(:config_path)
      config_text = args.delete(:config_text)
      @config = RRunsv::Config.new({ fullpath: config_path, text: config_text })
      ensure_directories
      write_run
    end

    def parse_id(fork_id)
      if fork_id.to_s.strip.empty?
        service_name
      else
        "#{service_name}-#{fork_id.to_s}"
      end
    end

    def directories
      Array.new.tap do |directories|
        directories << sv_directory
        %w{lib run log}.each do |dir|
          path = "/var/#{dir}/#{@id}"
          directories << path
        end
      end
    end

    def ensure_directories
      directories.each do |path|
        system("mkdir -p #{path}") unless Dir.exist?(path)
      end
    end

    def sv_directory
      "/etc/sv/#{@id}"
    end

    def data_directory
      "/var/lib/#{@id}"
    end

    def run_file
      @run_file ||= "#{sv_directory}/run"
    end

    def write_run
      File.write(
        run_file,
        "#!/bin/sh\n\n#{run_text}"
      )
      system("chmod 755 #{run_file}")
    end

    def read_run
      File.read(run_file) if File.exist?(run_file)
    end

    def symlink
      system("ln -s #{sv_directory} /etc/service/#{@id}")
    end

    def unsymlink
      system("rm -rf /etc/service/#{@id}") if Dir.exist?("/etc/service/#{@id}")
    end

    def signals
      [
        "status",
        "up",
        "down",
        "once",
        "pause",
        "cont",
        "hup",
        "alarm",
        "interrupt",
        "quit",
        "1",
        "2",
        "term",
        "kill",
      ]
    end

    def signal(signal)
      if signals.include?(signal)
        system("sv #{signal} #{@id}")
      else
        raise RRunsv::Error::UnknownCommand
      end
    end

    def status
      `sv status #{@id}`.split(":").first
    end

    def up
      signal("up")
    end

    def down
      signal("down")
    end

    def once
      signal("once")
    end

    def pause
      signal("pause")
    end

    def continue
      signal("cont")
    end

    def hup
      signal("hup")
    end

    def alarm
      signal("alarm")
    end

    def interrupt
      signal("interrupt")
    end

    def quit
      signal("quit")
    end

    def one
      signal("1")
    end

    def two
      signal("2")
    end

    def terminate
      signal("term")
    end

    def kill
      signal("kill")
    end

    def exit
      signal("exit")
    end

    def clear
      unsymlink
      @config.clear
      directories.each do |path|
        system("rm -rf #{path}") if Dir.exist?(path)
      end
    end

    def service_name
      self.class.name.downcase.split("::").last
    end

    def executable
      self.class.which(service_name)
    end

    def self.which(executable)
      path = `which #{executable}`.strip
      if path == ""
        exit
        return nil
      else
        return path
      end
    end
  end
end
