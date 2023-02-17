module BecomeShareholderHelper
  def fundraising_duration
    (Date.today - CurrentSituation::FUNDRAISING_START_DATE).to_i
  end

  def amf_risks_values
    {
      legal_form: {
        probability: :medium,
        extent: :medium,
        impact: :medium
      },
      treasury_control: {
        probability: :low,
        extent: :medium,
        impact: :medium
      },
      financial_situation: {
        probability: :low,
        extent: :low,
        impact: :low
      },
      no_dividend: {
        probability: :high,
        extent: :high,
        impact: :high
      },
      shareholders_dilution: {
        probability: :high,
        extent: :high,
        impact: :high
      },
      non_liquidity: {
        probability: :high,
        extent: :high,
        impact: :medium
      },
      capital_loss: {
        probability: :medium,
        extent: :medium,
        impact: :medium
      },
      business_model: {
        probability: :medium,
        extent: :high,
        impact: :medium
      }
    }
  end
end
