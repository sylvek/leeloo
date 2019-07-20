require 'clipboard'
require 'tty-table'
require 'tty-tree'

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
            preferences.keystores.each { |keystore| puts keystore.name }
        end

        def render_secrets secrets
            secrets.sort_by(&:name).each {|secret| puts secret.name}
        end

        def render_secret secret
            puts secret.read
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
            hash = {:secrets => []}
            secrets.sort_by(&:name).each { |secret| sort(hash[:secrets], secret.name) }
            puts TTY::Tree.new(hash).render
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