require 'leeloo/version'
require 'leeloo/controller'
require 'leeloo/command'
require 'leeloo/preferences'
require 'leeloo/keystore'
require 'leeloo/secret'
require 'leeloo/output'
require 'leeloo/server'

module Leeloo
  def self.start
    Command.new.run
  end
end
