class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :provider, :registration_plan, :phone_number, :customer_id, :subscription_id, :cancelation_date, :receipt_data, :subscription_plan_status, :image, :sign_up_from, :cancelation_date, :payment_verified, :migrate_user, :valid_for_thankyou_page, :current_payment_method, :subscription_info, :film_school_users_role, :organization_name, :film_school_student_info, :fs_student_sessions

  def image
    { staff_medium: { url: object.profile_image_url } }
  end

  def organization_name
    if object.registration_plan['FilmSchool'] && object.activate? && object.organizations_users_infos.try(:take).organization.present?
      object.organizations_users_infos.try(:take).organization.org_name
    end
  end

  def payment_verified
    object.is_payment_verified?
  end

  def current_payment_method
    object.latest_payment_method.try(:payment_type)
  end

  def film_school_student_info
    object.registration_plan['FilmSchool'] && object.activate? &&
        object.organizations_users_infos.try(:take).present? &&
        object.organizations_users_infos.try(:take).role.eql?('student')
  end

  def fs_student_sessions
    object.film_school_students_sessions ? object.film_school_students_sessions.pluck(:access_token) : []
  end

  def subscription_info
    if object.Educational?
      I18n.t( 'contents.subscription_info.educational' )
    elsif object.cancelled?
      I18n.t( 'contents.subscription_info.cancelled',
              cancelation_date: formatted_cancelation_date(object) )
    elsif object.trial? || object.activate?
      price_rate = price_rate_of_plan(object.registration_plan)
      charge_date = formatted_next_charge_date(object)

      I18n.t( 'contents.subscription_info.active',
              price_rate: price_rate,
              charge_date: charge_date )
    else
      I18n.t('contents.subscription_info.no_subscription')
    end
  end

  def formatted_next_charge_date(user)
    return unless user.next_charge_date
    user.next_charge_date.strftime('%B %d, %Y')
  end

  def formatted_cancelation_date(object)
    return unless object.cancelation_date
    object.cancelation_date.strftime('%B %d, %Y')
  end

  def price_rate_of_plan(plan_type)
    (plan_type == User.registration_plans['Monthly']) ? "$3.99 per month" : "$24 per year"
  end

  def film_school_users_role
    if (object.registration_plan['FilmSchool'] && object.activate?)
      object.organizations_users_infos.try(:take).try(:role) if object.organizations_users_infos.present?
    end
  end
end
