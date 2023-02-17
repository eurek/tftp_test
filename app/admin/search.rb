ActiveAdmin.register_page "Search" do
  content do
    render partial: "search"
  end

  controller do
    def index
      terms = [
        params[:query],
        Individual.generate_email_bidx(params[:query]),
        Individual.generate_first_name_bidx(params[:query]),
        Individual.generate_last_name_bidx(params[:query])
      ]

      @resources = terms.map { |term| PgSearch.multisearch(term).with_pg_search_rank }
        .flatten
        .uniq
        .sort_by(&:pg_search_rank)
    end
  end
end
