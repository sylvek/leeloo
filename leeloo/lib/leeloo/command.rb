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

    def initialize
      @preferences = PrivateLocalFileSystemPreferences.new.load
      @output = Ascii.new
    end

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

        c.action do |args, options|
          keystore = @preferences.keystore(options.keystore)
          @output.render_secrets keystore.secrets
        end
      end

      command :keystore do |c|
        c.syntax      = 'leeloo keystores'
        c.description = "Display current keystores"
        c.option '--ascii', nil, 'display secrets without unicode tree'

        c.action do |args, options|
          @output.render_preferences @preferences
        end
      end

      command :read do |c|
        c.syntax      = 'leeloo read <name>'
        c.description = "Display a secret from a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'
        c.option '--clipboard', nil, 'copy to clipboard'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first

          output = @output
          if(options.clipboard)
            output = ClipboardOutputDecorator.new @output
          end

          keystore = @preferences.keystore(options.keystore)
          secret = keystore.secret_from_name(name)
          output.render_secret secret
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
          phrase = nil

          phrase = STDIN.read if options.stdin
          phrase = SecureRandom.base64(32).truncate(options.generate.to_i) if options.generate

          unless phrase
            phrase  = password "secret"
            confirm = password "confirm it"
            abort "not the same secret" unless phrase == confirm
          end

          keystore = @preferences.keystore(options.keystore)
          secret = keystore.secret_from_name(name)
          secret.write(phrase)

          output = @output
          if(options.clipboard)
            output = ClipboardOutputDecorator.new @output
          end
          output.render_secret secret
        end
      end

      command :remove do |c|
        c.syntax      = 'leeloo delete <name>'
        c.description = "Delete a secret from a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "name is missing" unless args.length == 1
          name = args.first

          keystore = @preferences.keystore(options.keystore)
          secret = keystore.secret_from_name(name)
          secret.erase
        end
      end

      command :sync do |c|
        c.syntax      = 'leeloo sync'
        c.description = "Synchronize a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          keystore = @preferences.keystore(options.keystore)
          keystore.sync
        end
      end

      command :init do |c|
        c.syntax      = 'leeloo init'
        c.description = "Initialize a keystore"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          keystore = @preferences.keystore(options.keystore)
          keystore.init
        end
      end

    end
  end
end
