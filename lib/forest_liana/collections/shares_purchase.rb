class Forest::SharesPurchase
  include ForestLiana::Collection

  collection :SharesPurchase

  action "Mark as Paid", type: "single"
  action "Request Subscription Bulletin", type: "bulk"
  action "Send Confirmation Email", type: "bulk"
  action "Mark as not duplicated", type: "bulk"
  action "Mark as duplicated", type: "bulk"
  action "Generate Subscription Bulletin Recurring", type: "bulk"

  field :is_susbscription_bulletin_present, type: "String" do
    object.subscription_bulletin.attached?
  end

  field :email, type: "String" do
    object.individual.email
  end

  field :phone, type: "String" do
    object.individual.phone
  end

  field :individual_first_name, type: "String" do
    object.individual.first_name
  end

  field :individual_last_name, type: "String" do
    object.individual.last_name
  end

  # TODO : Voir avec Stan pour un faire un monkeyPatch sur ForestLiana::Collection et définir un active_storage_field ?
  # ou définir dans un concern un active_storage_field qu'on inclue dans la collection ?
  [:subscription_bulletin, :subscription_bulletin_certificate].each do |attribute|
    file_setter = lambda do |params, value|
      data = value.split(";")
      decoded_file_content = Base64.decode64(data[2].split(",")[1])
      filename = data[1].split("=")[1]
      content_type = data[0].split(":")[1]
      params[attribute] = {
        io: StringIO.new(decoded_file_content),
        content_type: content_type,
        filename: filename
      }
      params
    end

    field attribute, type: "String", set: file_setter do
      Rails.application.routes.url_helpers.rails_blob_url(object.send(attribute), host: ForestLiana.application_url)
    end
  end

  segment "Paid No Subscription Bulletin" do
    {id: SharesPurchase.where.missing(:subscription_bulletin_attachment)
      .where(status: "pending").where(payment_status: "paid")}
  end
end
