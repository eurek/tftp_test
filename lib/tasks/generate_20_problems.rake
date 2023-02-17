namespace :generate_20_problems do
  desc "destroy all existing problems in db"
  task destroy: :environment do
    Problem.destroy_all
  end

  desc "Generates the 20 first problems"
  task generate: :environment do
    p1 = Problem.create(
      title: "Produire et stocker l’énergie sans métaux rares",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "zero_emission",
      domain: "energy",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 1,
      home_displayed: true
    )
    img = File.open(Rails.root.join("app/assets/images/problems/light-45072_1.png"))
    p1.cover_image.attach(io: img, filename: "light-45072_1.png")

    p2 = Problem.create(
      title: "Produire efficacement de l’hydrogène à partir de l’eau",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "energetical_efficacy",
      domain: "energy",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 2
    )
    img = File.open(Rails.root.join(
      "app/assets/images/problems/shallow-focus-photography-of-water-splash-1231622 1.png"
    ))
    p2.cover_image.attach(io: img, filename: "shallow-focus-photography-of-water-splash-1231622 1.png")

    p3 = Problem.create(
      title: "Recycler les panneaux et batteries photovoltaïques",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "sobriety",
      domain: "energy",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 3
    )
    img = File.open(Rails.root.join("app/assets/images/problems/top-view-photo-of-solar-panels-2800832 1.png"))
    p3.cover_image.attach(io: img, filename: "top-view-photo-of-solar-panels-2800832 1.png")

    p4 = Problem.create(
      title: "Capturer les GES émis par les centrales (gaz et charbon)",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "captation",
      domain: "energy",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 4
    )
    img = File.open(Rails.root.join("app/assets/images/problems/black-close-up-coal-dark-46801 1.png"))
    p4.cover_image.attach(io: img, filename: "black-close-up-coal-dark-46801 1.png")

    p5 = Problem.create(
      title: "Chauffer à haute température sans énergies fossiles",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "zero_emission",
      domain: "industry",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 5
    )
    img = File.open(Rails.root.join("app/assets/images/problems/blaze-blue-blur-bright-266896 1 (1).png"))
    p5.cover_image.attach(io: img, filename: "blaze-blue-blur-bright-266896 1 (1).png")

    p6 = Problem.create(
      title: "Valoriser la chaleur fatale",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "energetical_efficacy",
      domain: "industry",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 6
    )
    img = File.open(Rails.root.join("app/assets/images/problems/photo-of-power-plants-3387159 1.png"))
    p6.cover_image.attach(io: img, filename: "photo-of-power-plants-3387159 1.png")

    p7 = Problem.create(
      title: "Augmenter la durée de vie des biens et recycler",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "sobriety",
      domain: "industry",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 7,
      home_displayed: true
    )
    img = File.open(Rails.root.join("app/assets/images/problems/clear-glass-bottle-with-white-cap-3457243 1.png"))
    p7.cover_image.attach(io: img, filename: "clear-glass-bottle-with-white-cap-3457243 1.png")

    p8 = Problem.create(
      title: "Capturer les GES émises par les usines",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "captation",
      domain: "industry",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 8,
      home_displayed: true
    )
    img = File.open(Rails.root.join("app/assets/images/problems/low-angle-photography-of-building-1737779 1.png"))
    p8.cover_image.attach(io: img, filename: "low-angle-photography-of-building-1737779 1.png")

    p9 = Problem.create(
      title: "Se déplacer sans combustibles fossiles",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "zero_emission",
      domain: "transport",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 9
    )
    img = File.open(Rails.root.join("app/assets/images/problems/alternative-auto-automobile-battery-110844 1.png"))
    p9.cover_image.attach(io: img, filename: "alternative-auto-automobile-battery-110844 1.png")

    p10 = Problem.create(
      title: "Améliorer les performances énergétiques des véhicules",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "energetical_efficacy",
      domain: "transport",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 10
    )
    img = File.open(Rails.root.join("app/assets/images/problems/close-up-photo-of-vehicle-engine-1409999 1.png"))
    p10.cover_image.attach(io: img, filename: "close-up-photo-of-vehicle-engine-1409999 1.png")

    p11 = Problem.create(
      title: "Réduire et adapter les déplacements des biens et des personnes",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "sobriety",
      domain: "transport",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 11
    )
    img = File.open(Rails.root.join("app/assets/images/problems/man-riding-bicycle-on-city-street-310983 1.png"))
    p11.cover_image.attach(io: img, filename: "man-riding-bicycle-on-city-street-310983 1.png")

    p12 = Problem.create(
      title: "Capturer les GES émis par les véhicules",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "captation",
      domain: "transport",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 12
    )
    img = File.open(Rails.root.join("app/assets/images/problems/gray-5-door-hatchback-1797290 1.png"))
    p12.cover_image.attach(io: img, filename: "gray-5-door-hatchback-1797290 1.png")

    p13 = Problem.create(
      title: "Cultiver sans produits phytosanitaires",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "zero_emission",
      domain: "agriculture",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 13
    )
    img = File.open(Rails.root.join("app/assets/images/problems/action-adult-boots-boxes-209230 1.png"))
    p13.cover_image.attach(io: img, filename: "action-adult-boots-boxes-209230 1.png")

    p14 = Problem.create(
      title: "Restructurer les terres agricoles",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "energetical_efficacy",
      domain: "agriculture",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 14,
      home_displayed: true
    )
    img = File.open(Rails.root.join("app/assets/images/problems/agriculture-backyard-blur-close-up-296230 1.png"))
    p14.cover_image.attach(io: img, filename: "agriculture-backyard-blur-close-up-296230 1.png")

    p15 = Problem.create(
      title: "Réduire la part d’origine animale de la demande alimentaire",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "sobriety",
      domain: "agriculture",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 15
    )
    img = File.open(Rails.root.join("app/assets/images/problems/variety-of-fruits-890507 1.png"))
    p15.cover_image.attach(io: img, filename: "variety-of-fruits-890507 1.png")

    p16 = Problem.create(
      title: "Sécuriser et développer les puits de carbones naturels",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "captation",
      domain: "agriculture",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 16
    )
    img = File.open(Rails.root.join("app/assets/images/problems/bright-daylight-environment-forest-240040 1.png"))
    p16.cover_image.attach(io: img, filename: "bright-daylight-environment-forest-240040 1.png")

    p17 = Problem.create(
      title: "Construire sans ciment",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "zero_emission",
      domain: "building",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 17,
      home_displayed: true
    )
    img = File.open(Rails.root.join("app/assets/images/problems/selective-focus-photography-cement-2219024 1.png"))
    p17.cover_image.attach(io: img, filename: "selective-focus-photography-cement-2219024 1.png")

    p18 = Problem.create(
      title: "Chauffer et climatiser sans HFC ni combustibles fossiles",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "energetical_efficacy",
      domain: "building",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 18
    )
    img = File.open(Rails.root.join("app/assets/images/problems/house-on-green-landscape-against-sky-314937 1.png"))
    p18.cover_image.attach(io: img, filename: "house-on-green-landscape-against-sky-314937 1.png")

    p19 = Problem.create(
      title: "Rénover maisons et bâtiments",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "sobriety",
      domain: "building",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 19,
      home_displayed: true
    )
    img = File.open(Rails.root.join("app/assets/images/problems/person-writing-on-paper-on-top-of-table-544965 1.png"))
    p19.cover_image.attach(io: img, filename: "person-writing-on-paper-on-top-of-table-544965 1.png")

    p20 = Problem.create(
      title: "Utiliser des matériaux stockant du carbone",
      description: %(
        Lorem ipsum dolor sit amet,
        consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut
        labore et dolore magna aliqua.
        Ut enim ad minim veniam,
        quis nostrud exercitation ullamco
        laboris nisi ut aliquip ex ea commodo consequat.
        Duis aute irure dolor in reprehenderit in
        voluptate velit esse cillum dolore eu
        fugiat nulla pariatur.
        Excepteur sint occaecat cupidatat non proident,
        sunt in culpa qui officia deserunt
        mollit anim id est laborum.
      ),
      action_lever: "captation",
      domain: "building",
      full_content: "<p>Lorem ipsum for full content</p>",
      position: 20
    )
    img = File.open(Rails.root.join("app/assets/images/problems/wood-nature-pattern-texture-40973 1.png"))
    p20.cover_image.attach(io: img, filename: "wood-nature-pattern-texture-40973 1.png")
  end
end
