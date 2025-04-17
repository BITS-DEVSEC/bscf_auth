module Bscf
  module Core
    class TokenService
      def encode(payload)
        JWT.encode(payload, ENV["SECRET_KEY_BASE"] || "secret_key_base")
      end

      def decode(token)
        body = JWT.decode(token, ENV["SECRET_KEY_BASE"] || "secret_key_base")[0]
        HashWithIndifferentAccess.new body
      rescue JWT::DecodeError, JSON::ParserError => e
        raise JWT::DecodeError.new("Invalid token")
      end
    end
  end
end
