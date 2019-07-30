module Constraints
  class ApiSubdomainConstraint
    def self.matches?(request)
      Rails.logger.info ">>>>>>subdomain: #{request.subdomain}>>>>>>"
      environment = Rails.env

      case environment
      when 'production'
        request.subdomain.present? && request.subdomain.start_with?('api')
      when 'staging'
        request.subdomain.present? && request.subdomain.start_with?('stag-api')
      when 'qa'
        request.subdomain.present? && request.subdomain.start_with?('qa-api')
      when 'development'
        true
      end
    end
  end
end
