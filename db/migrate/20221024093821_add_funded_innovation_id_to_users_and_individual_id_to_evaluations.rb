class AddFundedInnovationIdToUsersAndIndividualIdToEvaluations < ActiveRecord::Migration[6.1]
  def change
    add_reference :evaluations, :individual
    add_reference :individuals, :funded_innovation
  end
end
