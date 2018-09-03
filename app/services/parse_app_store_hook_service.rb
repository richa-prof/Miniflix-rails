class ParseAppStoreHookService
  def initialize(json_payload)
    @payload = json_payload
  end

  def call
    user = User.find_by_receipt_data(receipt_data) if receipt_data

    if user.present?
      do_process(user)
    else
      { success: true,
        message: I18n.t('flash.webhook.information_updated') }
    end
  end

  private
    def do_process(user)
      if user.present?
        if notification_type == 'CANCEL'
          unless user.expired?
            if user.expired!
              PAYMENT_LOGGER.debug "<<< ParseAppStoreHookService::do_process : user_id: #{user.id} <<<"
            end
          end
        end
      end
    end

    def notification_type
      @payload['notification_type']
    end

    def receipt_data
      @payload['password']
    end
end

#Ref.: https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/Subscriptions.html#//apple_ref/doc/uid/TP40008267-CH7-SW16
