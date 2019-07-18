require 'clipboard'

module Leeloo
    class Output

        def render_preferences preferences
        end

        def render_secrets secrets
        end

        def render_secret secret
        end
    end

    class Ascii < Output

        def render_preferences preferences
            default_keystore = preferences.default_keystore
            preferences.keystores.each { |keystore| puts keystore.name }
        end

        def render_secrets secrets
            secrets.sort_by(&:name).each() {|secret| puts secret.name}
        end

        def render_secret secret
            puts secret.read
        end
    end

    class ClipboardOutputDecorator < Output

        def initialize output
            @output = output
        end

        def render_preferences preferences
            @output.render_preferences preferences
        end

        def render_secrets secrets
            @output.render_secrets secrets
        end

        def render_secret secret

            Signal.trap("INT") do
                Clipboard.clear
                abort "ciao"
              end

            Clipboard.copy secret.read
            wait = Thread.new do
               puts "cleaning in 30s"
               30.times {
                   print "."
                   sleep 1
               }
            end
            wait.join
            Clipboard.clear
        end
    end

end