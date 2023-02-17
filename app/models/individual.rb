class Individual < ApplicationRecord
  include IndividualSearch
  include CountryConcern
  include ShareholdersConcern
  include PreventDestruction
  include PublicUrlConcern

  multisearchable against: [:email_bidx, :first_name_bidx, :last_name_bidx, :current_job]

  has_one :user
  has_one_attached :picture
  belongs_to :employer, class_name: "Company", foreign_key: :employer_id, optional: true
  has_many :accomplishments, as: :entity, dependent: :destroy
  has_many :badges, -> { order(:category) }, through: :accomplishments
  has_many :role_attributions, as: :entity, dependent: :destroy
  has_many :roles, through: :role_attributions
  belongs_to :funded_innovation, optional: true
  has_many :evaluations, dependent: :destroy
  has_many :evaluated_innovations, source: :innovation, through: :evaluations
  has_many :shares_purchases, dependent: :nullify
  has_many :notifications, as: :subject, dependent: :destroy

  has_encrypted :first_name, type: :string
  has_encrypted :last_name, type: :string
  has_encrypted :email, type: :string
  has_encrypted :phone, type: :string
  has_encrypted :date_of_birth, type: :date
  has_encrypted :address, type: :string
  has_encrypted :linkedin, type: :string
  has_encrypted :description, type: :string

  blind_index :first_name, expression: ->(v) { v&.downcase&.strip&.unaccent }
  blind_index :last_name, expression: ->(v) { v&.downcase&.strip&.unaccent }
  blind_index :email, expression: ->(v) { v&.downcase&.strip }
  blind_index :phone, expression: ->(v) { Phonelib.parse(v).full_international.presence || v }
  blind_index :date_of_birth

  blind_indexes.keys.each do |attr|
    ransacker attr, formatter: proc { |v| Individual.send("generate_#{attr}_bidx", v) } do
      Arel.sql("text(#{attr}_bidx)")
    end
  end

  accepts_nested_attributes_for :employer, reject_if: proc { |employer_params| employer_params[:name].blank? }

  validates :first_name, :last_name, :email, presence: true
  validates :date_of_birth, inclusion: {in: (Date.today - 120.years..Date.today), allow_blank: true, message: :invalid}
  validates_uniqueness_of :email, allow_blank: true, if: :will_save_change_to_email?
  validates_format_of :email, with: Devise.email_regexp, allow_blank: true, if: :will_save_change_to_email?
  validates :description, length: {maximum: 380}
  validates :external_uid, uniqueness: true, allow_nil: true
  validates :picture, content_type: {
    in: [:png, :jpg, :jpeg],
    message: I18n.t("activerecord.errors.messages.picture_error_message")
  }
  validate :valid_country_code, unless: -> { country.blank? }

  before_validation :normalize_country
  before_validation :update_public_search_text
  after_validation :reset_coordinates, if: -> { will_save_change_to_city? || will_save_change_to_country? }
  after_validation :set_department_number, if: :will_save_change_to_zip_code?
  before_save :geocode, if: -> { (latitude.blank? || longitude.blank?) && geocodable_address.present? }
  after_save :remove_notifications, if: -> { saved_change_to_is_displayed? }
  after_save :queue_locale_detector_job, if: -> { saved_change_to_reasons_to_join? }
  after_save :send_id_card_received_email, if: -> { saved_change_to_id_card_received? && id_card_received? }
  after_update :notify_zapier_of_email_changed, if: :saved_change_to_email?

  geocoded_by :geocodable_address do |object, results|
    if (result = results.first)
      object.latitude = result.latitude
      object.longitude = result.longitude
      object.country = result.country
      object.normalize_country
    end
  end

  scope :to_display, -> { where(is_displayed: true) }
  scope :with_picture, -> { includes(picture_attachment: :blob) }
  scope :with_completed_shares_purchase, -> { SharesPurchase.where(status: "completed").joins(:individual).uniq }

  scope :with_shareholder_since, -> {
    joins(:shares_purchases)
      .where(shares_purchases: {status: :completed})
      .select("individuals.*, MIN(shares_purchases.completed_at) AS shareholder_since").group(:id)
  }

  scope :shareholders_since, ->(date) {
    with_shareholder_since.having("MIN(shares_purchases.completed_at) >= ?", date)
  }

  include AttributesTrimming.new(
    [:first_name, :last_name, :email, :linkedin, :current_job, :description, :reasons_to_join]
  )
  include AttributesTitleizing.new([:first_name, :last_name])

  def full_name
    [first_name, last_name].join(" ")
  end

  def geocodable_address
    return nil if city.blank? && country.blank?

    [city, ISO3166::Country.find_country_by_alpha3(country)].compact.to_sentence(two_words_connector: ", ")
  end

  def to_param
    [public_slug, first_name.parameterize, last_name.parameterize].join("-")
  end

  def shareholder?
    !shares_purchases.completed.by_individual.blank?
  end

  def notify_new_shareholder
    Notification.create(subject: self) if is_displayed && shareholder?
  end

  def origin=(new_origin)
    set = origin.flatten.to_set
    if new_origin.is_a?(Array)
      set.merge(new_origin)
    else
      set.add(new_origin)
    end
    super(set.to_a.flatten)
  end

  private

  def reset_coordinates
    self.latitude = nil
    self.longitude = nil
  end

  def set_department_number
    self.department_number = zip_code.first(2) if country == "FRA" && zip_code.present?
  end

  def remove_notifications
    notifications.destroy_all unless is_displayed
  end

  def queue_locale_detector_job
    IndividualLocaleDetectorJob.perform_later(id)
  end

  def send_id_card_received_email
    SendIdCardReceivedEmailJob.perform_later(id)
  end

  def notify_zapier_of_email_changed
    ZapierNotifier.new.notify_individual_email_changed(self, attribute_before_last_save(:email))
  end

  def update_public_search_text
    return self.public_search_text = nil unless is_displayed

    self.public_search_text = "#{first_name} #{last_name}"
  end
end
