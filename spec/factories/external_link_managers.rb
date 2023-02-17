FactoryBot.define do
  factory :external_link_manager do
    shares_purchase_form { "https://automate-me.typeform.com/to/ykenkf" }
    company_shares_purchase_form { "https://automate-me.typeform.com/to/mMEHsn7V" }
    offer_shares_form { "https://automate-me.typeform.com/to/wCi1qxFG" }
    company_offer_shares_form { "https://automate-me.typeform.com/to/t7vfW635" }
    contact_form { "https://automate-me.typeform.com/to/SCbbOq" }
    b2b_contact_form { "https://automate-me.typeform.com/to/XX9l9YFn" }
    climate_deal_meeting_form { "https://automate-me.typeform.com/to/Y6cW1mEl" }
    innovation_proposal_form { "https://automate-me.typeform.com/to/OiHvRp" }
    climate_deal_simulator_form { "https://automate-me.typeform.com/to/uuZPV16u" }
    climate_deal_presentation_document {
      "https://drive.google.com/file/d/1U5ajXRJf7jcJE6xho3uVtZnDV1ur8-tg/view?usp=sharing"
    }
    report_video { "https://youtu.be/c0ICQN_uIng" }
    summary_information_document do
      "https://drive.google.com/file/d/1K5DUKeQZOa6TlGLS1gte-rqUmAWgBeKu/view?usp=sharing"
    end
    galaxy_app { "https://galaxytimefortheplanet.my.stacker.app/register" }
    use_gift_coupon { "https://automate-me.typeform.com/to/uhIb7Q7h?typeform-source=localhost" }
    time_app { "https://app-tftp.glideapp.io/" }
  end
end
