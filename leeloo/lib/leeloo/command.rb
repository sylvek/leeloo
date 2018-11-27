require 'commander/import'
require 'securerandom'
require 'clipboard'


class String
  def truncate(max)
    length > max ? self[0...max] : self
  end
end

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

      command :"list-keystore" do |c|
        c.syntax      = 'leeloo keystore'
        c.description = "Display keystores list"
        c.option '--ascii', nil, 'display secrets without unicode tree'

        c.action do |args, options|

          Config::list_keystores options.ascii
        end
      end
      alias_command :keystore, :"list-keystore"

      command :"list-secret" do |c|
        c.syntax      = 'leeloo list [options]'
        c.description = "Display secrets list of keystore"
        c.option '--keystore STRING', String, 'a selected keystore'
        c.option '--ascii', nil, 'display secrets without unicode tree'

        c.action do |args, options|
          options.default :keystore => Config.default['keystore']

          Secret::list Config.get_keystore(options.keystore), options.ascii
        end
      end
      alias_command :list, :"list-secret"
      alias_command :secrets, :"list-secret"

      command :"add-keystore" do |c|
        c.syntax      = 'leeloo add-keystore <name> <path>'
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

      command :"remote-keystore" do |c|
        c.syntax      = "leeloo remote <repository>"
        c.description = "add a remote repository to synchronize keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "repository is missing" unless args.length == 1
          repository = args.first
          Keystore.add_remote Config.get_keystore(options.keystore), repository
          say "remote added successfully"
        end
      end
      alias_command :remote, :"remote-keystore"

      command :"sync-keystore" do |c|
        c.syntax      = "leeloo sync"
        c.description = "sync secrets with git repository (if configured)"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          options.default :keystore => Config.default['keystore']
          synchronized = Keystore.sync_keystore Config.get_keystore(options.keystore)
          if synchronized
            say "secrets synchronized successfully"
          else
            abort "call remote-keystore before sync-keystore"
          end
        end
      end
      alias_command :sync, :"sync-keystore"

      command :"sign-secret" do |c|
        c.syntax      = 'leeloo sign'
        c.description = "(re)sign all secrets from a given keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          options.default :keystore => Config.default['keystore']
          signed = Secret.sign_secrets Config.get_keystore(options.keystore)
          say "secrets signed successfully" if signed
        end
      end
      alias_command :sign, :"sign-secret"

      command :"add-secret" do |c|
        c.syntax      = 'leeloo add <name>'
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
          secret = SecureRandom.base64(32).truncate(options.generate.to_i) if options.generate

          unless secret
              secret  = password "secret"
              confirm = password "confirm it"
              abort "not the same secret" unless secret == confirm
          end

          Secret.add_secret keystore, name, secret
          say "#{name} added successfully"
          Clipboard.copy secret if options.clipboard
          say secret unless options.clipboard
        end
      end
      alias_command :write, :"add-secret"
      alias_command :add, :"add-secret"
      alias_command :insert, :"add-secret"
      alias_command :set, :"add-secret"

      command :"read-secret" do |c|
        c.syntax      = 'leeloo read <name>'
        c.description = "Display a secret from a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'
        c.option '--clipboard', nil, 'copy to clipboard'
        c.option '--to /path/to/file', String, 'for binary file'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first

          options.default :keystore => Config.default['keystore']
          keystore = Config.get_keystore(options.keystore)

          begin
            secret = Secret.read_secret keystore, name

            if (options.to)
              File.open(options.to, 'w') { |file| file.write(secret) }
              say "stored to #{options.to}"
            else
              say secret unless options.clipboard
              Clipboard.copy secret if options.clipboard
            end

          rescue
            abort "unable to find #{name}"
          end
        end
        alias_command :read, :"read-secret"
        alias_command :get, :"read-secret"
      end

      command :"remove-secret" do |c|
        c.syntax      = 'leeloo remove <name>'
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
        alias_command :remove, :"remove-secret"
        alias_command :delete, :"remove-secret"
        alias_command :erase, :"remove-secret"
      end
    end
  end
end
