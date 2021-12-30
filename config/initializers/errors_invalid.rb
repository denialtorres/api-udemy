# frozen_string_literal: true

module JsonapiErrorsHandler
  module Errors
    # override serializable_hash method for jsonapi_errors_handler gem
    # since there is a bug for rails 6
    class Invalid
      def serializable_hash
        errors_array = []
        errors.to_h&.each do |error|
          errors_array << {
            status: status,
            title: title,
            detail: "#{error[0]} #{error[1]}",
            source: { pointer: "/data/attributes/#{error[0]}" }
          }
        end

        errors_array
      end
    end
  end
end
