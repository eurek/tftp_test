class User < ApplicationRecord
  include StatisticsConcern
  # TODO:  Faire une task qui supprime les passwords de tous les users qui n'ont jamais changé leur password temporaire
  # créer en même temps un moyen de réinviter quelqu'un à la main.

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :validatable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :confirmable
  # TODO: Bizarre qu'on ait registerable alors que dans les faits ils ne sont pas, c'est nous qui créons les comptes.

  has_many :companies, dependent: :nullify, foreign_key: :admin_id
  has_many :created_companies, class_name: "Company", dependent: :nullify, foreign_key: :creator_id
  belongs_to :individual

  accepts_nested_attributes_for :individual

  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of :password, within: Devise.password_length, allow_blank: true

  delegate :first_name, to: :individual

  paginates_per 10

  # Override devise method to adapt to our database schema
  def self.find_first_by_auth_conditions(sanitized_conditions, opts = {})
    conditions = sanitized_conditions.dup
    if (email = conditions.delete(:email))
      where(conditions.to_h).joins(:individual)
        .where("individuals.email_bidx = ?", Individual.generate_email_bidx(email))
        .first
    else
      super(sanitized_conditions, opts)
    end
  end

  def email
    individual&.email
  end

  def email=(email)
    if individual.present?
      individual.email = email
    end
  end

  def is_admin?
    !companies.empty?
  end

  def password_match?
    errors[:password] << I18n.t("errors.messages.blank") if password.blank?
    errors[:password_confirmation] << I18n.t("errors.messages.blank") if password_confirmation.blank?
    if password != password_confirmation
      errors[:password_confirmation] << I18n.translate("errors.messages.confirmation", attribute: "password")
    end
    password == password_confirmation && !password.blank?
  end

  # new function to set the password without knowing the current
  # password used in our confirmation controller.
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update(p)
  end

  def has_no_password?
    encrypted_password.blank?
  end

  def only_if_unconfirmed
    pending_any_confirmation { yield }
  end

  private

  def will_save_change_to_email?
    individual.will_save_change_to_email?
  end

  def password_required?
    if !persisted?
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end
end
