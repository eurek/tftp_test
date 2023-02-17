class Company < ApplicationRecord
  include CompanySearch
  include CompanyAutocompletion
  include ShareholdersConcern
  include CountryConcern
  include PublicUrlConcern
  include CompanyMatching

  belongs_to :admin, class_name: "User", foreign_key: :admin_id, optional: true
  belongs_to :creator, class_name: "User", foreign_key: :creator_id, optional: true
  has_many :employees, class_name: "Individual", foreign_key: :employer_id, dependent: :nullify
  has_many :shares_purchases, dependent: :nullify
  has_many :accomplishments, as: :entity, dependent: :destroy
  has_many :badges, -> { order(:category) }, through: :accomplishments
  has_many :role_attributions, as: :entity, dependent: :destroy
  has_many :roles, through: :role_attributions
  has_one_attached :logo

  # TODO: when we have more time make a task to separate address in multiple fields based on address using geocoding api
  # Careful the api sometimes seem to not send house number ex: company id 11429
  geocoded_by :geocodable_address do |object, results|
    if (result = results.first)
      object.country = result.country
      object.latitude = result.latitude
      object.longitude = result.longitude
      object.normalize_country
    end
  end

  before_validation :normalize_country
  after_validation :reset_coordinates, if: :will_save_change_to_address?
  before_save :geocode, if: -> { (latitude.blank? || longitude.blank?) && address.present? }

  validate :valid_country_code, unless: -> { country.blank? }
  validates :name, presence: true
  validates :logo, content_type: {
    in: [:png, :jpg, :jpeg],
    message: I18n.t("activerecord.errors.messages.picture_error_message")
  }

  scope :to_display, -> {
    where(is_displayed: true).where.not(admin_id: nil).or(where(is_displayed: true).where.not(creator: nil))
  }
  scope :with_admin, -> {
    where.not(admin_id: nil)
  }

  include AbsoluteLinkable.new(
    [:website, :facebook, :linkedin]
  )
  include AttributesTrimming.new(
    [:name, :city, :address, :street_address]
  )
  include AttributesTitleizing.new([:city, :address, :street_address])

  def shareholder?
    admin.present?
  end

  def to_param
    [public_slug, name&.parameterize].join("-")
  end

  def self.deduplicate(chosen_company, company_to_delete)
    ActiveRecord::Base.transaction do

      Company.columns.each do |column|
        new_attribute_value = chosen_company.send(column.name).present? ?
          chosen_company.send(column.name) : company_to_delete.send(column.name)
        chosen_company.send("#{column.name}=", new_attribute_value)
      end

      chosen_company.shares_purchases << company_to_delete.shares_purchases
      chosen_company.employees << company_to_delete.employees
      chosen_company.save
      company_to_delete.destroy
    end
  end

  private

  def geocodable_address
    if street_address.present?
      [
        street_address,
        zip_code,
        city,
        ISO3166::Country.find_country_by_alpha3(country)
      ].compact.join(" ")
    else
      address
    end
  end

  def reset_coordinates
    self.latitude = nil
    self.longitude = nil
  end
end
