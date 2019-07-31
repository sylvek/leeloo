require 'leeloo/version'
require 'leeloo/command'
require 'leeloo/preferences'
require 'leeloo/keystore'
require 'leeloo/recipient'
require 'leeloo/secret'
require 'leeloo/output'

module Leeloo
  def self.start
    Command.new.run
  end
end
