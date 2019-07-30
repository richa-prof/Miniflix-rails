module Constraints
  class AdminSubdomainConstraint
    def self.matches?(request)
      Rails.logger.info ">>>>>>subdomain: #{request.subdomain}>>>>>>"
      environment = Rails.env

      case environment
      when 'production'
        request.subdomain.present? && request.subdomain.start_with?('admin')
      when 'staging'
        request.subdomain.present? && request.subdomain.start_with?('stag-admin')
      when 'qa'
        request.subdomain.present? && request.subdomain.start_with?('qa-admin')
      when 'development'
        request.subdomain.present? && request.subdomain.start_with?('admin')
      end
    end
  end
end
