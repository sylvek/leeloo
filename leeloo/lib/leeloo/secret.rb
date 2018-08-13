require 'gpgme'
require 'tty-tree'
require 'git'
require 'fileutils'

module Leeloo

  class Secret

    def self.list(keystore, ascii)
      if ascii
        Dir.glob("#{keystore}/secrets/**/*.gpg")
          .sort
          .reject { |path| File.directory? path }
            .each { |secret| puts secret.gsub(/#{keystore}\/secrets\//, '').gsub(/\.gpg/, '') }
      else
        puts TTY::Tree.new("#{keystore}/secrets").render.gsub(/\.gpg/, '')
      end
    end

    def self.add_secret(keystore, name, secret)
      recipients = []
      Dir.foreach("#{keystore}/keys") { |key| recipients << File.basename(key, ".*") unless File.directory? key }

      FileUtils.mkdir_p File.dirname "#{keystore}/secrets/#{name}"

      crypto = GPGME::Crypto.new :always_trust => true
      crypto.encrypt secret,
        :output => File.open("#{keystore}/secrets/#{name}.gpg","w+"),
        :recipients => recipients

      g = Git.open keystore
      g.add "#{keystore}/secrets/#{name}.gpg"
      g.commit "secret #{name} added"
    end

    def self.read_secret(keystore, name)
      crypto = GPGME::Crypto.new
      crypto.decrypt File.open("#{keystore}/secrets/#{name}.gpg")
    end

    def self.delete_secret(keystore, name)
      g = Git.open keystore
      g.remove "#{keystore}/secrets/#{name}.gpg"
      g.commit "secret #{name} removed"
    end

    def self.sign_secrets keystore

      g = Git.open keystore

      recipients = []
      Dir.foreach("#{keystore}/keys") do |key|
        unless File.directory? key
          recipients << File.basename(key, ".*")
          GPGME::Key.import(File.open("#{keystore}/keys/#{key}"))
        end
      end

      crypto = GPGME::Crypto.new :always_trust => true
      find_secrets("#{keystore}/secrets").each do |secret|
          say "."
          decrypted = crypto.decrypt File.open(secret)
          crypto.encrypt decrypted,
            :output => File.open(secret,"w+"),
            :recipients => recipients
          g.add secret
      end

      g.commit "sync"
      return true
    end

    def self.find_secrets path
      elements = []
      Dir.glob("#{path}/**") do |element|
        elements << element unless Dir.exist? element
        elements << find_secrets(element) if Dir.exist? element
      end
      return elements.flatten
    end

  end
end
