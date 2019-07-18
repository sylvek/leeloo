require 'gpgme'
require 'fileutils'
require 'git'

module Leeloo
  class Keystore

    attr_reader :name

    def initialize name
      @name = name
    end

    def secrets
      # returns the secrets list
    end

    def secret_of path
      # returns a secret object
    end

    def secret_from_name name
      # returns a secret object
    end

    def sync
      # synchronizes the keystore
    end

    def init
      # initialize the keystore
    end

    def == keystore
      self.name == keystore.name
    end
  end

  class PrivateLocalFileSystemKeystore < Keystore

    attr_reader :path

    def initialize name, path
      super name
      @path = path
      FileUtils.mkdir_p "#{@path}/secrets"
    end

    def secrets
      find_secrets "#{@path}/secrets"
    end

    def find_secrets path
      elements = []
      Dir.glob("#{path}/**") do |element|
        elements << secret_of(element) unless Dir.exist? element
        elements << find_secrets(element) if Dir.exist? element
      end
      return elements.flatten
    end

    def == keystore
      self.name == keystore.name && self.path == keystore.path
    end

    def secret_of path
      name = path.gsub("#{@path}/secrets/", "")
      LocalFileSystemSecret.new path, name
    end

    def secret_from_name name
      secret_of "#{path}/secrets/#{name}"
    end

  end

  class GpgPrivateLocalFileSystemKeystore < PrivateLocalFileSystemKeystore

    def initialize name, path
      super name, path
      FileUtils.mkdir_p "#{@path}/keys"

      @recipients = []
      Dir.glob("#{path}/keys/*") { |key| @recipients << File.basename(key) }
      @recipients.each { |key| GPGME::Key.import(File.open("#{path}/keys/#{key}")) }
    end

    def init
      super
      GPGME::Key.find(:public, nil, ).each { |key| key.export(:output => File.open("#{path}/keys/#{key.uids.first.email}", "w+")) }
    end

    def secret_of path
      name = path.gsub("#{@path}/secrets/", "").gsub(".gpg", "")
      GpgLocalFileSystemSecret.new path, name, @recipients
    end

    def secret_from_name name
      secret_of "#{path}/secrets/#{name}.gpg"
    end

  end

  class GitKeystoreDecorator < Keystore
    def initialize keystore
      @keystore = keystore
      Git.init @keystore.path
      @git = Git.open keystore.path
    end

    def secret_of element
      GitSecretDecorator.new(@git, element)
    end

    def secret_from_name element
      secret_of @keystore.secret_from_name(element)
    end

    def secrets
      @keystore.secrets
    end

    def name
      @keystore.name
    end

    def sync
      @git.pull
      @keystore.sync
      @git.push
    end

    def init
      @keystore.init
      @git.add
      @git.commit "keystore #{@keystore.name} added"
    end

  end
end
