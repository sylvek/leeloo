require 'gpgme'
require 'git'
require 'fileutils'

module Leeloo
  class Secret

    attr_reader :name

    def initialize name
      @name = name
    end

    def == secret
      @name == secret.name
    end

    def read
      # returns the secret
    end

    def write phrase
      # write the secret
    end

    def erase
      # erase the secret
    end

  end

  class LocalFileSystemSecret < Secret

    attr_reader :pathname

    def initialize pathname, name
      super name
      @pathname = pathname
    end

    def read
      File.read @pathname
    end

    def write phrase
      FileUtils.mkdir_p File.dirname @pathname
      File.write @pathname, phrase
    end

    def erase
      File.delete @pathname
    end

  end

  class GpgLocalFileSystemSecret < LocalFileSystemSecret

    def initialize pathname, name, recipients
      super pathname, name
      @recipients = recipients
      @crypto = GPGME::Crypto.new :always_trust => true
    end
  
    def read
      @crypto.decrypt File.open(@pathname)
    end

    def write phrase
      FileUtils.mkdir_p File.dirname @pathname
      @crypto.encrypt phrase,
        :output => File.open(@pathname,"w+"),
        :recipients => @recipients
    end

  end

  class GitSecretDecorator < Secret

    def initialize keystore_path, secret
      @git = Git.open keystore_path
      @secret = secret
    end

    def read
      @secret.read
    end

    def write phrase
      @secret.write phrase
      @git.add @secret.pathname
      @git.commit "secret #{@secret.name} added"
    end

    def erase
      @secret.erase
      @git.remove @secret.pathname
      @git.commit "secret #{@secret.name} removed"
    end

  end

end
