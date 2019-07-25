require 'gpgme'
require 'fileutils'
require 'git'
require 'base64'

module Leeloo

  class KeystoreFactory
    def self.create keystore
        keystore_created = nil
        case keystore["cypher"]
        when "gpg"
            keystore_created = GpgPrivateLocalFileSystemKeystore.new keystore["name"], keystore["path"] 
        else
            keystore_created = PrivateLocalFileSystemKeystore.new keystore["name"], keystore["path"]
        end

        case keystore["vc"]
        when "git"
            GitKeystoreDecorator.new keystore_created
        else
            keystore_created
        end
    end
  end

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

    def footprint name
      # footprint a given secret path
    end

    def secret_from_footprint footprint
      # returns a secret object
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

    def footprint name
      secret = secret_from_name name
      { "footprint" => secret.footprint, "keystore" => self.name, "secret" => secret.name }
    end

    def secret_from_footprint footprint
      secret = secret_from_name footprint["secret"]
      unless secret.footprint == footprint["footprint"]
        raise "footprint is not valid"
      end
      secret
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

    def footprint name
      footprint = super name
      footprint["sign"] = Base64.strict_encode64 GPGME::Crypto.new.sign(footprint["footprint"]).to_s
      footprint
    end

    def secret_from_footprint footprint
      data = GPGME::Crypto.new.verify(Base64.strict_decode64 footprint["sign"]) { |signature| signature.valid? }
      if data.read == footprint["footprint"]
        super footprint
      else
        raise "signature is not valid"
      end
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

    def path
      @keystore.path
    end

    def footprint element
      @keystore.footprint element
    end

    def secret_from_footprint footprint
      @keystore.secret_from_footprint footprint
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
