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

        def set_default_keystore name
            @default = name
        end

        def keystore name=nil
            keystores.find { |k| k.name == name||@default }
        end

        def keystores
            @keystores.map { |k| KeystoreFactory::create k }
        end

        def add_keystore keystore
            unless @keystores.include? keystore
                @keystores << keystore
            end
        end
    end

    class PrivateLocalFileSystemPreferences < Preferences

        DEFAULT_PATH = "#{Dir.home}/.leeloo"
        
        def load(path=DEFAULT_PATH)
            @path = path

            if File.exist? "#{path}/keystores"
                @keystores = YAML.load_file "#{path}/keystores"
            end

            if File.exist? "#{path}/config"
                config = YAML.load_file "#{path}/config"
                set_default_keystore config["keystore"]
            else
                default_keystore = {
                    'name'      => "private",
                    'path'      => "#{path}/private",
                    'cypher'    => "gpg",
                    'vc'        => "git"
                }
                add_keystore default_keystore
                set_default_keystore "private"
                keystore_of("private").init
            end

            self
        end

        def keystore_of keystore_name
            keystore = @keystores.find { |keystore| keystore["name"] == keystore_name }
            KeystoreFactory::create keystore
        end

        def set_default_keystore name
            super name
            config = {
                "keystore" => name
            }
            File.write("#{@path}/config", config.to_yaml)
        end

        def add_keystore keystore
            super keystore
            FileUtils.mkdir_p keystore["path"]
            File.write("#{@path}/keystores", @keystores.to_yaml)
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
                GitKeystoreDecorator.new keystore_created
            else
                keystore_created
            end
        end
    end
end