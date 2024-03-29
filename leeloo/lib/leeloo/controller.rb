module Leeloo
	class OutputFactory
		def self.create options
			output = nil
			if options.ascii
				output = Ascii.new
			else
				output = Terminal.new
			end
			if options.clipboard
				ClipboardOutputDecorator.new output
			else
				output
			end
		end
	end

	class Controller
		def display
		end
	end
    
	class PrivateLocalFileSystemController < Controller
		def initialize options
			@preferences = PrivateLocalFileSystemPreferences.new.load
			@keystore = @preferences.keystore(options.keystore)
			@output = OutputFactory.create(options)
			@options = options
		end
	end

	class SecretsController < PrivateLocalFileSystemController
		def initialize options
			super options
			@secrets = @keystore.secrets
		end
		def search name
			@secrets = @secrets.select { |secret| secret.name.downcase.include? name.downcase } || []
		end
		def list
			@secrets
		end
		def display
			@output.render_secrets @secrets
		end
	end

	class ExportController < PrivateLocalFileSystemController
		def display
			@keystore.secrets.each do |secret|
				@output.render_name_and_secret(secret.name, @keystore.secret_from_name(secret.name))
			end
		end
	end

	class KeysController < PrivateLocalFileSystemController
		def add_key email
			@keystore.add_key(email)
		end
		def remove_key email
			@keystore.remove_key(email)
		end
		def sync
			@keystore.secrets.each do |secret|
				phrase = @keystore.secret_from_name(secret.name).read
				@keystore.secret_from_name(secret.name).write(phrase)
			end
		end
		def display
			@keys = @keystore.keys
			@output.render_keys @keys
		end
	end

	class SecretController < PrivateLocalFileSystemController
		def read name
			@secret = @keystore.secret_from_name(name)
		end
		def write name
			phrase = nil

			phrase = STDIN.read if @options.stdin
			phrase = SecureRandom.base64(32).truncate(@options.generate.to_i) if @options.generate

			unless phrase
				phrase  = password "Enter password for #{name}"
				confirm = password "Confirm it"
				abort "not the same secret" unless phrase == confirm
			end

			@secret = @keystore.secret_from_name(name)
			@secret.write(phrase)
		end
		def remove name
			@secret = @keystore.secret_from_name(name)
			@secret.erase
		end
		def display
			@output.render_secret @secret
		end
	end

	class TranslateController < PrivateLocalFileSystemController
		def translate
			@text = STDIN.read
			@text.scan(/\$\{.*\}/).each do |secret|
				begin
				@text.gsub! secret, (@keystore.secret_from_name(secret[2..-2])).read.to_s.strip 
				rescue => exception
					# silent
				end
			end
		end
		def display
			@output.render_text @text
		end
	end

	class KeystoreController < PrivateLocalFileSystemController
		def add name, path
			@preferences.add_keystore({"name" => name, "path" => path, "cypher" => "gpg", "vc" => "git"})
			@preferences.keystore(name).init
		end
		def remove name
			@preferences.remove_keystore name
		end
		def set_default name
			@preferences.set_default_keystore name
		end
		def sync
			@keystore.sync
		end
		def init
			@keystore.init
		end
		def display
			@output.render_preferences @preferences
		end
    end

    class ShareController < PrivateLocalFileSystemController
        def token name
            @footprint = @keystore.footprint_of(name)
        end
        def start_server
            Server.new.start @preferences
        end
        def display
            @output.render_footprint @footprint
        end
    end
end