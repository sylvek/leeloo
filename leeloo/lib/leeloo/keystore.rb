require 'fileutils'
require 'gpgme'
require 'git'

module Leeloo
  class Keystore

    def self.secret_key_empty?
      GPGME::Key.find(:secret, nil, ).empty?
    end

    def self.add_keystore name, path
      FileUtils.mkdir_p path
      FileUtils.mkdir_p "#{path}/secrets/"
      FileUtils.mkdir_p "#{path}/keys/"

      GPGME::Key.find(:public, nil, ).each do |key|
        key.export(:output => File.open("#{path}/keys/#{key.uids.first.email}", "w+"))
      end

      g = Git.init path
      g.add
      g.commit "keystore #{path} added"
    end

    def self.sync_keystore path
      g = Git.init path
      g.push
    end

  end
end
