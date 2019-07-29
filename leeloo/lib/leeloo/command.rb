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

      default_command :"list"

      command :list do |c|
        c.syntax      = 'leeloo list [options]'
        c.description = "Display secrets list of keystore"
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
          ctl = SecretsController.new(options)
          ctl.search(args)
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

        c.action do |args, options|
          ctl = KeystoreController.new(options)
          ctl.remove(args)
          ctl.display
        end
      end

      command "keystore add" do |c|
        c.syntax      = 'leeloo keystore add <name> <path/to/keystore>'
        c.description = "add a keystore"

        c.action do |args, options|
          ctl = KeystoreController.new(options)
          ctl.add(args)
          ctl.display
        end
      end

      command "keystore default" do |c|
        c.syntax      = 'leeloo keystore default name'
        c.description = "set the default keystore"

        c.action do |args, options|
          ctl = KeystoreController.new(options)
          ctl.set_default(args)
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
          ctl = SecretController.new(options)
          ctl.read(args)
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
          ctl = SecretController.new(options)
          ctl.write(args)
          ctl.display
        end
      end

      command :translate do |c|
        c.syntax      = 'leeloo translate'
        c.description = "translate stdin by replacing key ${my/secret} by the current value"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          ctl = TranslateController.new(options)
          ctl.translate(args)
          ctl.display
        end
      end

      command :remove do |c|
        c.syntax      = 'leeloo delete <name>'
        c.description = "Delete a secret from a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          ctl = SecretController.new(options)
          ctl.remove(args)
          ctl.display
        end
      end

      command :sync do |c|
        c.syntax      = 'leeloo sync'
        c.description = "Synchronize a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          ctl = KeystoreController.new(options)
          ctl.sync(args)
          ctl.display
        end
      end

      command :init do |c|
        c.syntax      = 'leeloo init'
        c.description = "Initialize a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          ctl = KeystoreController.new(options)
          ctl.init(args)
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

          keystore = @preferences.keystore(options.keystore)
          footprint = keystore.footprint name

          OutputFactory.create(options).render_footprint footprint
          Server.new.start @preferences
        end
      end

      command :token do |c|
        c.syntax      = 'leeloo token <name>'
        c.description = "generate an access token for a given secret"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first

          keystore = @preferences.keystore(options.keystore)
          footprint = keystore.footprint name

          OutputFactory.create(options).render_footprint footprint
        end
      end

      command :server do |c|
        c.syntax      = 'leeloo server'
        c.description = "start a server access token"

        c.action do |args, options|
          Server.new.start @preferences
        end
      end

    end
  end
end
