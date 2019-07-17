require 'commander/import'
require 'securerandom'

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

        c.action do |args, options|
          @output.render_secrets @preferences.default_keystore.secrets
        end
      end

      command :config do |c|
        c.syntax      = 'leeloo config'
        c.description = "Display current configuration"

        c.action do |args, options|
          @output.render_preferences @preferences
        end
      end

      command :read do |c|
        c.syntax      = 'leeloo read <name>'
        c.description = "Display a secret from a keystore"
        c.option '--clipboard', nil, 'copy to clipboard'

        c.action do |args, options|
          name = args.first

          output = @output
          if(options.clipboard)
            output = ClipboardOutputAdapter.new @output
          end

          secret = @preferences.default_keystore.secret_from_name(name)
          output.render_secret secret
        end
      end

      command :write do |c|
        c.syntax      = 'leeloo write <name> <secret>'
        c.description = "Write a secret from a keystore"

        c.action do |args, options|
          name = args[0]
          phrase = args[1]

          keystore = @preferences.default_keystore
          secret = keystore.secret_from_name(name)
          secret.write(phrase)

          @output.render_secret secret
        end
      end

      command :delete do |c|
        c.syntax      = 'leeloo delete <name>'
        c.description = "Delete a secret from a keystore"

        c.action do |args, options|
          name = args[0]

          keystore = @preferences.default_keystore
          secret = keystore.secret_from_name(name)
          secret.erase
        end
      end

    end
  end
end
