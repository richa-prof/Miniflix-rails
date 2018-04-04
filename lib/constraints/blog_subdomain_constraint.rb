module Constraints
  class BlogSubdomainConstraint
    def self.matches?(request)
      Rails.logger.info "subdomain: #{request.subdomain}"
      environment = Rails.env
      case environment
        when 'production'
          request.subdomain.present? && request.subdomain.start_with?('blog')
        when 'staging'
          request.subdomain.present? && request.subdomain.start_with?('blog')
        when 'development'
          true
      end
    end
  end
end  