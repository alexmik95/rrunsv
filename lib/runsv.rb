require "runsv/version"

module Runsv
  class Error < StandardError
    class UnknownCommand < Error; end
  end

  autoload :Service, "runsv/service"
  autoload :Config, "runsv/config"
end
