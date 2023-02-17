class Api::IndividualsController < Api::ApiController
  def create
    individual = create_or_update_individual

    json = individual.attributes.as_json
      .reject { |k, _| k.ends_with?("_bidx") }
      .reject { |k, _| k.ends_with?("_ciphertext") }
      .reject { |k, _| k == "public_search_text" }
    render json: json, status: :ok
  end
end
