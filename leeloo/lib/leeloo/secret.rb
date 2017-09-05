require 'gpgme'
require 'tty-tree'
require 'git'

module Leeloo
  class Secret

    def self.list(keystore)
      puts TTY::Tree.new("#{keystore}/secrets").render
    end

    def self.add_secret(keystore, name, secret)
      recipients = []
      Dir.foreach("#{keystore}/keys") do |key|
        unless File.directory? key
          recipients << File.basename(key, ".*")
          GPGME::Key.import(File.open("#{keystore}/keys/#{key}"))
        end
      end

      crypto = GPGME::Crypto.new :always_trust => true
      crypto.encrypt secret,
        :output => File.open("#{keystore}/secrets/#{name}","w+"),
        :recipients => recipients

      g = Git.open keystore
      g.add "#{keystore}/secrets/#{name}"
      g.commit "secret #{name} added"

      say "#{name} added successfully"
    end

    def self.read_secret(keystore, name)
      crypto = GPGME::Crypto.new
      say crypto.decrypt File.open("#{keystore}/secrets/#{name}")
    end
  end
end
