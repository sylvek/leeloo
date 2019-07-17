module Leeloo
    class Output
        def render_secrets secrets
        end

        def render_secret secret
        end
    end

    class Ascii < Output

        def render_secrets secrets
            secrets.each() {|secret| puts secret.name}
        end

        def render_secret secret
            puts secret.read
        end
    end

end