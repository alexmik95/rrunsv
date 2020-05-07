require "rrunsv/version"

module RRunsv
  class Error < StandardError
    class UnknownCommand < Error; end
  end

  autoload :Service, "rrunsv/service"
  autoload :Config, "rrunsv/config"
end
