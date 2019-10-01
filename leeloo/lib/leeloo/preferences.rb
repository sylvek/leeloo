require 'yaml'

module Leeloo
    class Preferences

        attr_reader :default

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
            keystores.find { |k| k.name == (name||@default) }
        end

        def keystores
            @keystores.map { |k| KeystoreFactory::create k }
        end

        def add_keystore keystore
            unless @keystores.include? keystore
                @keystores << keystore
            end
        end

        def remove_keystore name
            abort "you can not remove default keystore" if name == @default
            keystore = @keystores.find { |k| k["name"] == name }
            if keystore != nil
                @keystores.delete keystore
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

        def keystore_of name
            keystore = @keystores.find { |keystore| keystore["name"] == name }
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

        def remove_keystore name
            super name
            File.write("#{@path}/keystores", @keystores.to_yaml)
        end

    end

end