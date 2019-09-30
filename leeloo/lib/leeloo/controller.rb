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
			@output = OutputFactory.create(options)
			@options = options
		end
	end

	class SecretsController < PrivateLocalFileSystemController
		def initialize options
			super options
			@secrets = @preferences.keystore(@options.keystore).secrets
		end
		def search args
			abort "name is missing" unless args.length == 1
			name = args.first
			@secrets = @secrets.select { |secret| secret.name.downcase.include? name.downcase } || []
		end
		def display
			@output.render_secrets @secrets
		end
	end

	class SecretController < PrivateLocalFileSystemController
		def initialize options
			super options
			@keystore = @preferences.keystore(@options.keystore)
		end
		def read args
			abort "name is missing" unless args.length == 1
			name = args.first
			@secret = @keystore.secret_from_name(name)
		end
		def write args
			abort "name is missing" unless args.length == 1
			name = args.first
			phrase = nil

			phrase = STDIN.read if @options.stdin
			phrase = SecureRandom.base64(32).truncate(@options.generate.to_i) if @options.generate

			unless phrase
				phrase  = password "secret"
				confirm = password "confirm it"
				abort "not the same secret" unless phrase == confirm
			end

			@secret = @keystore.secret_from_name(name)
			@secret.write(phrase)
		end
		def remove args
			abort "name is missing" unless args.length == 1
			name = args.first
			@secret = @keystore.secret_from_name(name)
			@secret.erase
		end
		def display
			@output.render_secret @secret
		end
	end

	class TranslateController < PrivateLocalFileSystemController
		def initialize options
			super options
			@keystore = @preferences.keystore(@options.keystore)
		end
		def translate args
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
		def add args
			abort "name or path is missing" unless args.length == 2
			@preferences.add_keystore({"name" => args.first, "path" => args.last, "cypher" => "gpg", "vc" => "git"})
			@preferences.keystore(args.first).init
		end
		def remove args
			abort "name is missing" unless args.length == 1
			@preferences.remove_keystore args.first
		end
		def set_default args
			abort "name is missing" unless args.length == 1
			@preferences.set_default_keystore args.first
		end
		def sync args
			@preferences.keystore(args.first).sync
		end
		def init args
			@preferences.keystore(args.first).init
		end
		def display
			@output.render_preferences @preferences
		end
	end
end