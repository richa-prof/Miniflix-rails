module Constraints
  class ProviderSubdomainConstraint
    def self.matches?(request)
      Rails.logger.info ">>>>>>subdomain: #{request.subdomain}>>>>>>"
      environment = Rails.env

      case environment
      when 'production'
        request.subdomain.present? && request.subdomain.start_with?('provider')
      when 'staging'
        request.subdomain.present? && request.subdomain.start_with?('stag-provider')
      when 'qa'
        request.subdomain.present? && request.subdomain.start_with?('qa-provider')
      when 'development'
        request.subdomain.present? && request.subdomain.start_with?('provider')
      end
    end
  end
end
