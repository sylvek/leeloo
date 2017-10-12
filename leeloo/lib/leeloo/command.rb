require 'commander/import'
require 'securerandom'
require 'clipboard'

module Leeloo
  class Command
    include Commander::Methods

    def run
      program :name, 'leeloo'
      program :version, Leeloo::VERSION
      program :description, [
        "leeloo multipass - #{Leeloo::DESCRIPTION}",
        "\tRun using `leeloo [action]`"
      ].join("\n")
      program :help, 'Author', 'Sylvain Maucourt <smaucourt@gmail.com>'
      program :help, 'GitHub', 'https://github.com/sylvek'
      program :help_formatter, :compact

      default_command :"list"

      command :"init" do |c|
        c.syntax      = 'leeloo init'
        c.description = "Initialize leeloo and private keystore"
        c.action do |args, options|
          abort("a secret key PGP is mandatory") if Keystore::secret_key_empty?
          Config::init
          say "Initialization completed"
        end
      end

      command :"list keystore" do |c|
        c.syntax      = 'leeloo list'
        c.description = "Display keystores list"
        c.action do |args, options|

          Config::list_keystores
        end
      end
      alias_command :keystore, :"list keystore"

      command :"list secret" do |c|
        c.syntax      = 'leeloo list secret [options]'
        c.description = "Display secrets list of keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          options.default :keystore => Config.default['keystore']
          Secret::list Config.get_keystore(options.keystore)
        end
      end
      alias_command :list, :"list secret"

      command :"add keystore" do |c|
        c.syntax      = 'leeloo add keystore <name> <path>'
        c.description = "Add a new keystore"

        c.action do |args, options|

          abort "name or path are missing" unless args.length == 2
          name = args.first
          keystore = args.last

          Keystore.add_keystore name, keystore
          Config.add_keystore name, keystore
          say "keystore #{name} added"
        end
      end

      command :"sync secret" do |c|
        c.syntax      = 'leeloo recrypt secrets'
        c.description = "(re)sync all secrets from a given keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          options.default :keystore => Config.default['keystore']
          Secret.sync_secrets Config.get_keystore(options.keystore)
          say "keystore synced successfully"
        end
      end
      alias_command :sync, :"sync secret"

      command :"add secret" do |c|
        c.syntax      = 'leeloo add secret <name>'
        c.description = "Add a new secret in a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'
        c.option '--generate INTEGER', Integer, 'a number of randomized characters'
        c.option '--stdin', nil, 'secret given by stdin pipe'
        c.option '--clipboard', nil, 'copy to clipboard'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first

          options.default :keystore => Config.default['keystore']
          keystore = Config.get_keystore(options.keystore)

          secret = nil
          secret = STDIN.read if options.stdin
          secret = SecureRandom.base64(options.generate) if options.generate

          unless secret
              secret  = password "secret"
              confirm = password "confirm it"
              abort "not the same secret" unless secret == confirm
          end

          Secret.add_secret keystore, name, secret
          say "#{name} added successfully"
          Clipboard.copy secret if options.clipboard
        end
      end
      alias_command :add, :"add secret"
      alias_command :insert, :"add secret"
      alias_command :set, :"add secret"

      command :"read secret" do |c|
        c.syntax      = 'leeloo read secret <name>'
        c.description = "Display a secret from a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'
        c.option '--clipboard', nil, 'copy to clipboard'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first

          options.default :keystore => Config.default['keystore']
          keystore = Config.get_keystore(options.keystore)

          begin
            secret = Secret.read_secret keystore, name
            say secret unless options.clipboard
            Clipboard.copy secret if options.clipboard
          rescue
            abort "unable to find #{name}"
          end
        end
        alias_command :read, :"read secret"
        alias_command :get, :"read secret"
      end

      command :"remove secret" do |c|
        c.syntax      = 'leeloo remove secret <name>'
        c.description = "Remove a secret from a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first

          options.default :keystore => Config.default['keystore']
          keystore = Config.get_keystore(options.keystore)

          begin
            Secret.delete_secret keystore, name
            say "#{name} removed successfully"
          rescue
            abort "unable to find #{name}"
          end
        end
        alias_command :delete, :"remove secret"
        alias_command :erase, :"remove secret"
      end
    end
  end
end
