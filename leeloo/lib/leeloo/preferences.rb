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
            keystore_created = nil
            case keystore["cypher"]
            when "gpg"
                keystore_created = GpgPrivateLocalFileSystemKeystore.new keystore["name"], keystore["path"] 
            else 
                keystore_created = PrivateLocalFileSystemKeystore.new keystore["name"], keystore["path"]
            end

            case keystore["vc"]
            when "git"
                GitKeystoreAdapter.new keystore_created
            else
                keystore_created
            end
        end
    end
end