require 'gpgme'
require 'tty-tree'
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

  end

  class LocalFileSystemSecret < Secret
    
    def read
      File.read @name
    end

  end

  class GpgLocalFileSystemSecret < LocalFileSystemSecret

    def initialize name
      super name
      @crypto = GPGME::Crypto.new
    end
  
    def read
      @crypto.decrypt File.open(@name)
    end

  end

end
