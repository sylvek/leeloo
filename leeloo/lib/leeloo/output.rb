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
            preferences.keystores.each do |keystore|
                is_default = default_keystore == keystore
                puts "name: #{keystore.name} default: #{is_default}"
            end
        end

        def render_secrets secrets
            secrets.each() {|secret| puts secret.name}
        end

        def render_secret secret
            puts secret.read
        end
    end

end