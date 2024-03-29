require 'clipboard'
require 'tty-table'
require 'tty-tree'
require 'json'
require 'base64'
require 'socket'

module Leeloo

    class Output

        def render_preferences preferences
        end

        def render_secrets secrets
        end

        def render_secret secret
        end

        def render_text text
        end

        def render_name_and_secret name, secret
        end

        def render_keys keys
        end

        def render_footprint footprint
        end

        def render_share footprint
        end
    end

    class Ascii < Output

        def render_preferences preferences
            preferences.keystores.each { |keystore| puts keystore.name }
        end

        def render_secrets secrets
            secrets.sort_by(&:name).each {|secret| puts secret.name}
        end

        def render_secret secret
            begin
                puts secret.read
            rescue => exception
                puts "#{secret.name} doesn't exist"
            end
        end

        def render_name_and_secret name, secret
            self.render_text name
            self.render_secret secret
            self.render_text '------'
        end

        def render_text text
            puts text
        end

        def render_keys keys
            self.render_text keys
        end

        def render_footprint footprint
            puts "token:"
            puts Base64.strict_encode64 footprint.to_json
        end
    end

    class Terminal < Ascii

        def render_preferences preferences
            rows = []
            default_keystore = preferences.default
            preferences.keystores.each do |keystore|
                is_default = '*' if keystore.name == default_keystore
                rows << [keystore.name, keystore.path, is_default ]
              end
              puts TTY::Table.new(header: ['Name', 'Path', 'Default'], rows: rows).render(:ascii)
        end

        def render_secrets secrets
            hash = {'Password Store' => []}
            secrets.sort_by(&:name).each { |secret| sort(hash['Password Store'], secret.name) }
            puts TTY::Tree.new(hash).render
        end

        def render_keys keys
            rows = []
            keys.each do |key|
                splitted = key.split('::')
                is_present = '*' if splitted[1] == 'true'
                rows << [splitted[0], is_present]
            end
            puts TTY::Table.new(header: ['Email', 'Selected'], rows: rows).render(:ascii)
        end

        def sort array, element
            if element
                e = element.split("/", 2)
                if e.length > 1
                    found = false
                    array.each do |a|
                        if a.is_a? Hash
                            if a[e.first]
                                found = true
                                sort(a[e.first], e.last)
                                break
                            end
                        end
                    end

                    unless found
                        array << { e.first => sort([], e.last) }
                    end
                else
                    array << e.last
                end
            end
            array
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

        def render_text text
            @output.render_text text
        end

        def render_secret secret

            Signal.trap("INT") do
                Clipboard.clear
                abort "cleared"
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

        def render_footprint footprint
            @output.render_footprint footprint
        end

        def render_share footprint
            @output.render_share footprint
        end
    end

end