require 'commander/import'

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

      default_command :list

      command :"init" do |c|
        c.syntax      = 'leeloo init'
        c.description = "Initialize leeloo and private keystore"
        c.action do |args, options|

          Config::init
        end
      end

      command :"list" do |c|
        c.syntax      = 'leeloo list'
        c.description = "Display keystores list"
        c.action do |args, options|

          Config::list_keystores
        end
      end

      command :"list secret" do |c|
        c.syntax      = 'leeloo list secret <keystore>'
        c.description = "Display secrets list"
        c.action do |args, options|
          abort "keytore is missing" unless args.length == 1

          Secret::list Config.get_keystore(args.first)
        end
      end

      command :"add keystore" do |c|
        c.syntax      = 'leeloo add keystore <name> <path>'
        c.description = "add a new keystore"

        c.action do |args, options|

          abort "name or path are missing" unless args.length == 2

          Keystore.add_keystore args.first, args.last
          Config.add_keystore args.first, args.last
        end
      end

      command :"add secret" do |c|
        c.syntax      = 'leeloo add secret <keystore> <name>'
        c.description = "add a new secret in a keystore"

        c.action do |args, options|
          keystore = Config.get_keystore(args.first)

          abort "keytore or name are missing" unless args.length == 2
          secret  = password "secret"
          confirm = password "confirm it"
          abort "not the same secret" unless secret == confirm

          Secret.add_secret keystore, args.last, secret
        end
      end

      command :"read secret" do |c|
        c.syntax      = 'leeloo read secret <keystore> <name>'
        c.description = "read a secret from a keystore"

        c.action do |args, options|
          keystore = Config.get_keystore(args.first)

          abort "keytore or name are missing" unless args.length == 2

          Secret.read_secret keystore, args.last
        end
      end
    end
  end
end
