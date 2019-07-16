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

    def initialize
      
      @preferences = PrivateLocalFileSystemPreferences.new.load

      @output = Terminal.new
      
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

      command :"list-secret" do |c|
        c.syntax      = 'leeloo list [options]'
        c.description = "Display secrets list of keystore"

        c.action do |args, options|
          @output.render_secrets @preferences.default_keystore.secrets
        end
      end
      alias_command :list, :"list-secret"
      alias_command :secrets, :"list-secret"

      command :"read-secret" do |c|
        c.syntax      = 'leeloo read <name>'
        c.description = "Display a secret from a keystore"

        c.action do |args, options|
          name = args.first
          @output.render_secret @preferences.default_keystore.secret_from_name(name)
        end
        alias_command :read, :"read-secret"
        alias_command :get, :"read-secret"
      end

    end
  end
end
