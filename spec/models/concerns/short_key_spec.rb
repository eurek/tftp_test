require "rails_helper"

RSpec.describe ShortKey, type: :model do
  it "can generate a key" do
    expect(ShortKey.generate).not_to eq nil
    expect(ShortKey.generate.size).to eq 11
  end

  it "defines a format" do
    10.times {
      expect(ShortKey.generate).to match ShortKey.format_regex
    }

    expect("ULvj_v81JcY").to match ShortKey.format_regex
    expect("ULvj-v81JcY").not_to match ShortKey.format_regex
    expect("ULvj+v81JcY").not_to match ShortKey.format_regex
    expect("ULvj/v81JcY").not_to match ShortKey.format_regex
    expect("ULvj=v81JcY").not_to match ShortKey.format_regex
  end
end
