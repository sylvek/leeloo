require 'commander/import'
require 'securerandom'

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
        c.syntax      = 'leeloo list secret [options]'
        c.description = "Display secrets list of keystore (private by default)"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          options.default :keystore => 'private'
          Secret::list Config.get_keystore(options.keystore)
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
        c.syntax      = 'leeloo add secret <name>'
        c.description = "add a new secret in a keystore (private by default)"
        c.option '--keystore STRING', String, 'a selected keystore'
        c.option '--generate INTEGER', Integer, 'a number of randomized characters'
        c.option '--stdin', nil, 'secret given by stdin pipe'

        c.action do |args, options|
          abort "name or path are missing" unless args.length == 1
          name = args.first

          options.default :keystore => 'private'
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
        end
      end

      command :"read secret" do |c|
        c.syntax      = 'leeloo read secret <name>'
        c.description = "read a secret from a keystore (private by default)"
        c.option '--keystore STRING', String, 'a selected keystore'

        c.action do |args, options|
          abort "name or path are missing" unless args.length == 1
          name = args.first

          options.default :keystore => 'private'
          keystore = Config.get_keystore(options.keystore)

          Secret.read_secret keystore, name
        end
      end
    end
  end
end
