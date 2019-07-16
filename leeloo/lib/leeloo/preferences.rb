require 'yaml'

module Leeloo
    class Preferences

        def initialize
            @keystores = []
            @default = nil
        end

        def load
            # this method loads all preferences
            self
        end

        def default_keystore
            return @default
        end
    end

    class PrivateLocalFileSystemPreferences < Preferences

        DEFAULT_PATH = "#{Dir.home}/.leeloo"
        
        def load(path=DEFAULT_PATH)
            FileUtils.mkdir_p path
            if File.exist? "#{path}/keystores"
                @keystores = YAML.load_file "#{path}/keystores"
            end
            if File.exist? "#{path}/config"
                config = YAML.load_file "#{path}/config"

                default_keystore_name = config["keystore"]
                @default = keystore_of default_keystore_name
            end
            self
        end

        def keystore_of keystore_name
            keystore = @keystores.find { |keystore| keystore["name"] == keystore_name }
            KeystoreFactory::create keystore
        end

    end

    class KeystoreFactory
        def self.create keystore
            case keystore["cypher"]
            when "gpg"
                GpgPrivateLocalFileSystemKeystore.new keystore["name"], keystore["path"] 
            else 
                PrivateLocalFileSystemKeystore.new keystore["name"], keystore["path"]
            end
        end
    end
end