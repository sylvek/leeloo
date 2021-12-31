require 'commander/import'
require 'securerandom'

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

      default_command :wrapper

      command :wrapper do |c|
        c.action do |args, options|
          unless args == []
            name = args.first
            ctl = SecretController.new(options)
            ctl.read(name)
            ctl.display
          else
            SecretsController.new(options).display
          end
        end
      end

      command :list do |c|
        c.syntax      = 'leeloo list [options]'
        c.description = "Display secrets list of stored on a keystore"
        c.option '--ascii', nil, 'display secrets without unicode tree'
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          SecretsController.new(options).display
        end
      end

      command :search do |c|
        c.syntax      = 'leeloo search name'
        c.description = "Display secrets containing name pattern"
        c.option '--ascii', nil, 'display secrets without unicode tree'
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first
          ctl = SecretsController.new(options)
          ctl.search(name)
          ctl.display
        end
      end

      command :keystore do |c|
        c.syntax      = 'leeloo keystores'
        c.description = "Display current keystores"
        c.option '--ascii', nil, 'display secrets without unicode tree'

        c.action do |args, options|
          KeystoreController.new(options).display
        end
      end

      command "keystore remove" do |c|
        c.syntax      = 'leeloo keystore remove <name>'
        c.description = "remove a keystore (path/to/keystore is not destroyed)"

        c.action do |args, options|args
          abort "name is missing" unless args.length == 1
          name = args.first
          ctl = KeystoreController.new(options)
          ctl.remove(name)
          ctl.display
        end
      end

      command "keystore add" do |c|
        c.syntax      = 'leeloo keystore add <name> <path/to/keystore>'
        c.description = "add a keystore"

        c.action do |args, options|
          abort "name or path is missing" unless args.length == 2
          name = args.first
          path = args.last
          ctl = KeystoreController.new(options)
          ctl.add(name, path)
          ctl.display
        end
      end

      command "keystore default" do |c|
        c.syntax      = 'leeloo keystore default name'
        c.description = "set the default keystore"

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first
          ctl = KeystoreController.new(options)
          ctl.set_default(name)
          ctl.display
        end
      end

      command :key do |c|
        c.syntax      = 'leeloo keys'
        c.description = "list keys from this keystore"
        c.option '--ascii', nil, 'display secrets without unicode tree'
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          ctl = KeysController.new(options)
          ctl.display
        end
      end

      command "key sync" do |c|
        c.syntax      = 'leeloo keys sync'
        c.description = "synchronize secrets with keys"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          ctl = KeysController.new(options)
          ctl.sync
          ctl.display
        end
      end

      command "key add" do |c|
        c.syntax      = 'leeloo key add <email>'
        c.description = "add a dedicated key"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "email is missing" unless args.length == 1
          email = args.first
          ctl = KeysController.new(options)
          ctl.add_key(email)
          ctl.display
        end
      end

      command "key remove" do |c|
        c.syntax      = 'leeloo key remove <email>'
        c.description = "remove a dedicated key"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "email is missing" unless args.length == 1
          email = args.first
          ctl = KeysController.new(options)
          ctl.remove_key(email)
          ctl.display
        end
      end

      command :read do |c|
        c.syntax      = 'leeloo read <name>'
        c.description = "Display a secret from a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'
        c.option '--clipboard', nil, 'copy to clipboard'
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first
          ctl = SecretController.new(options)
          ctl.read(name)
          ctl.display
        end
      end

      command :write do |c|
        c.syntax      = 'leeloo write <name> <secret>'
        c.description = "Write a secret from a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'
        c.option '--generate INTEGER', Integer, 'a number of randomized characters'
        c.option '--stdin', nil, 'secret given by stdin pipe'
        c.option '--clipboard', nil, 'copy to clipboard'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first
          ctl = SecretController.new(options)
          ctl.write(name)
          ctl.display
        end
      end

      command :translate do |c|
        c.syntax      = 'leeloo translate'
        c.description = "translate stdin by replacing key ${my/secret} by the current value"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          ctl = TranslateController.new(options)
          ctl.translate
          ctl.display
        end
      end

      command :remove do |c|
        c.syntax      = 'leeloo delete <name>'
        c.description = "Delete a secret from a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first
          ctl = SecretController.new(options)
          ctl.remove(name)
          ctl.display
        end
      end

      command "keystore sync" do |c|
        c.syntax      = 'leeloo sync'
        c.description = "Synchronize a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          ctl = KeystoreController.new(options)
          ctl.sync
          ctl.display
        end
      end

      command "keystore export" do |c|
        c.syntax      = 'leeloo export'
        c.description = "Export all secrets from a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          ctl = ExportController.new(options)
          ctl.display
        end
      end

      command "keystore init" do |c|
        c.syntax      = 'leeloo init'
        c.description = "Initialize a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          ctl = KeystoreController.new(options)
          ctl.init
          ctl.display
        end
      end

      command :share do |c|
        c.syntax      = 'leeloo share <name>'
        c.description = "share a secret with someone"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first
          ctl = ShareController.new(options)
          ctl.token(name)
          ctl.display
          ctl.start_server
        end
      end

      command :token do |c|
        c.syntax      = 'leeloo token <name>'
        c.description = "generate an access token for a given secret"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first
          ctl = ShareController.new(options)
          ctl.token(name)
          ctl.display
        end
      end

      command :server do |c|
        c.syntax      = 'leeloo server'
        c.description = "start a server access token"

        c.action do |args, options|
          ctl = ShareController.new(options)
          ctl.start_server
        end
      end

    end
  end
end
