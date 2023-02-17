require "rails_helper"

describe "/innovations/_star_scale" do
  it "renders 5 full stars for rating of 5" do
    render partial: "innovations/star_scale", locals: {rating: 5.0}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 5)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 0)
  end

  it "renders 5 full stars for rating of 4.75" do
    render partial: "innovations/star_scale", locals: {rating: 4.75}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 5)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 0)
  end

  it "renders 4 and half star for rating of 4.74" do
    render partial: "innovations/star_scale", locals: {rating: 4.74}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 4)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 1)
  end

  it "renders 4 and half star for rating of 4.25" do
    render partial: "innovations/star_scale", locals: {rating: 4.25}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 4)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 1)
  end

  it "renders 4 full stars for rating of 4.24" do
    render partial: "innovations/star_scale", locals: {rating: 4.24}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 4)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 0)
  end

  it "renders 4 full stars for rating of 4" do
    render partial: "innovations/star_scale", locals: {rating: 4.0}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 4)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 0)
  end

  it "renders 4 full stars for rating of 3.75" do
    render partial: "innovations/star_scale", locals: {rating: 3.75}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 4)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 0)
  end

  it "renders 3 full stars, one half for rating of 3.74" do
    render partial: "innovations/star_scale", locals: {rating: 3.74}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 3)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 1)
  end

  it "renders 3 full stars, one half star for rating of 3.25" do
    render partial: "innovations/star_scale", locals: {rating: 3.25}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 3)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 1)
  end

  it "renders 1 half start for rating of 0.25" do
    render partial: "innovations/star_scale", locals: {rating: 0.25}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 0)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 1)
  end

  it "renders no stars of 0.24" do
    render partial: "innovations/star_scale", locals: {rating: 0.24}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 0)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 0)
  end

  it "renders no stars for rating of 0" do
    render partial: "innovations/star_scale", locals: {rating: 0.0}
    expect(rendered).to have_css(".material-icons", text: /\Astar\z/, count: 0)
    expect(rendered).to have_css(".material-icons", text: "star_half", count: 0)
  end
end
