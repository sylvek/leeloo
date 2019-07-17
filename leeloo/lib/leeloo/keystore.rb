require 'gpgme'
require 'fileutils'

module Leeloo
  class Keystore

    attr_reader :name

    def initialize name
      @name = name
    end

    def secrets
      # returns the secrets list
    end

    def secret_of element
      # returns a secret object
    end

    def secret_from_name element
      # returns a secret object
    end

    def == keystore
      @name == keystore.name
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
      @name == keystore.name && @path == keystore.path
    end

    def secret_of element
      LocalFileSystemSecret.new element, element.gsub("#{@path}/secrets/", "")
    end

    def secret_from_name element
      secret_of "#{path}/secrets/#{element}"
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

    def secret_of element
      GpgLocalFileSystemSecret.new element, element.gsub("#{@path}/secrets/", "").gsub(".gpg", ""), @recipients
    end

    def secret_from_name element
      secret_of "#{path}/secrets/#{element}.gpg"
    end

  end

  class GitKeystoreAdapter < Keystore
    def initialize keystore
      @keystore = keystore
    end

    def secret_of element
      GitSecretAdapter.new(@keystore.path, element)
    end

    def secret_from_name element
      secret_of @keystore.secret_from_name(element)
    end

    def secrets
      @keystore.secrets
    end

  end
end
