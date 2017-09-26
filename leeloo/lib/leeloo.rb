require 'leeloo/version'
require 'leeloo/command'
require 'leeloo/secret'
require 'leeloo/keystore'
require 'leeloo/config'

module Leeloo
  def self.start
    Config.load
    Command.new.run
  end
end
