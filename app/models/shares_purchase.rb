class SharesPurchase < ApplicationRecord
  include StatisticsConcern
  include PreventDestruction

  belongs_to :individual
  belongs_to :company, optional: true

  # TODO: Should we validate that a shares purchase cannot be completed
  # if not paid or not subscription bulletin attached ?
  validates :amount, :typeform_answer_uid, :form_completed_at, :payment_method, :status, presence: true
  validates :typeform_answer_uid, uniqueness: true
  validates :external_uid, :transfer_reference, :zoho_sign_request_id, uniqueness: true, allow_nil: true

  before_validation :mark_as_paid, if: -> { will_save_change_to_payment_status? && paid_payment? }
  before_validation :set_transfer_reference, if: -> {
    will_save_change_to_payment_method? && transfer_ce_payment_method?
  }
  after_save_commit :after_completed_purchase, if: -> { saved_change_to_status? && completed_status? }
  after_create_commit { DetectSharesPurchaseDuplicatesJob.perform_later(id) }

  has_one_attached :subscription_bulletin
  has_one_attached :subscription_bulletin_certificate
  scope :without_subscription_bulletin, -> {
    left_joins(:subscription_bulletin_attachment).where("active_storage_attachments.id IS NULL")
  }

  validates :subscription_bulletin, :subscription_bulletin_certificate, content_type: {
    in: [:pdf],
    message: I18n.t("activerecord.errors.messages.document_error_message")
  }
  validates_absence_of :subscription_bulletin_certificate, unless: -> { subscription_bulletin.attached? }

  enum payment_method: {
    card_stripe: "card_stripe",
    transfer_ce: "transfer_ce",
    debit_gocardless: "debit_gocardless",
    gift_coupon: "gift_coupon",
    secondary_market: "secondary_market"
  }, _suffix: :payment_method

  enum status: {
    pending: "pending",
    canceled: "canceled",
    completed: "completed",
    sold: "sold"
  }, _suffix: :status

  enum payment_status: {
    pending: "pending",
    refunded: "refunded",
    paid: "paid"
  }, _suffix: :payment

  scope :total_raised, -> { where(status: "completed").sum(:amount) }
  scope :completed, -> { where(status: "completed") }
  scope :ordered_by_completed_at, -> { order(completed_at: :desc) }
  scope :by_company, -> { joins(:company) }
  scope :by_individual, -> { where.missing(:company) }

  def self.day_top
    select_objects_between(
      :completed_at,
      Date.today.at_beginning_of_day,
      Date.today.at_end_of_day
    ).order(:amount).last
  end

  def self.week_top
    select_objects_between(
      :completed_at,
      Date.today.at_beginning_of_week,
      Date.today.at_end_of_day
    ).order(:amount).last
  end

  def self.year_top
    select_objects_between(
      :completed_at,
      Date.today.at_beginning_of_year,
      Date.today.at_end_of_year
    ).order(:amount).last
  end

  def self.month_top
    select_objects_between(
      :completed_at,
      Date.today.at_beginning_of_month,
      Date.today.at_end_of_month
    ).order(:amount).last
  end

  def self.all_time_top
    order(:amount).last
  end

  def file_uploaded
    return unless subscription_bulletin.attached?

    if transfer_ce_payment_method? && pending_payment? && subscription_bulletin_certificate.attached?
      ZapierNotifier.new.send_email_with_bank_details(self)
    elsif paid_payment? && !completed_status?
      update(status: "completed", completed_at: DateTime.now)
    end
  end

  private

  def mark_as_paid
    self.paid_at = DateTime.now

    if subscription_bulletin.attached?
      self.status = "completed"
      self.completed_at = DateTime.now
    end
  end

  def set_transfer_reference
    if payment_method == "transfer_ce" && transfer_reference.nil?
      last_reference = SharesPurchase.where.not(transfer_reference: nil).last
      self.transfer_reference = (last_reference&.transfer_reference.to_i || 0) + 1
    end
  end

  def after_completed_purchase
    AfterCompleteSharesPurchaseJob.perform_later(id)
  end
end
