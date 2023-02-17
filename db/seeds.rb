return if Rails.env.production?

puts "Destroy all data"

Content.destroy_all
Tag.destroy_all
Category.destroy_all
Badge.destroy_all
User.destroy_all
Individual.delete_all
SharesPurchase.delete_all
Company.destroy_all
Accomplishment.destroy_all
CurrentSituation.destroy_all
RoadmapTask.destroy_all
Role.destroy_all
AdminUser.destroy_all
ExternalLinkManager.destroy_all
Event.destroy_all
Innovation.destroy_all

puts "Seeds for external link manager"

FactoryBot.create(:external_link_manager)

puts "Seeds for categories"

Rake::Task['categories:create'].invoke

puts "Seeds for 20 problems"

Rake::Task['generate_20_problems:generate'].invoke

puts "Seeds for Current Situation"

CurrentSituation.create!(
  total_shareholders: 9
)

puts "Seeds for roadmap tasks"

short_done = RoadmapTask.create!(
  title: "100 000 EUR",
  text: "Lever 100 000 Eur",
  duration_type: "short",
  done_at: DateTime.now,
  status: "done",
  position: 1,
  category: "funding"
)

short_to_do = RoadmapTask.create!(
  title: "150 associé·es",
  text: "Atteindre 150 associé·es",
  duration_type: "short",
  done_at: nil,
  status: "to_do",
  position: 1,
  category: "structure"
)

medium_to_do = RoadmapTask.create!(
  title: "100 associés",
  text: "Regrouper au moins 100 associés",
  duration_type: "medium",
  status: "in_progress",
  position: 2,
  category: "community"
)

long_to_do = RoadmapTask.create!(
  title: "Passage en SCA",
  text: "Passer en SCA",
  duration_type: "long",
  status: "to_do",
  position: nil,
  category: "structure"
)

long_to_do.prerequisite_tasks = [short_done, short_to_do]
medium_to_do.prerequisite_tasks = [short_done]

puts "Seeds for badges"

badge1 = Badge.create!(
  description: 'Pour gagner ce badge, il faut posséder au moins 1 action Time for the Planet' +
    '<span class="brand">®</span>.',
  fun_description: "C’est pas la taille qui compte, c’est la fourmilière !",
  category: "financial",
  name: "Fourmi",
  position: 1,
  external_uid: "rec1"
)

badge1.picture_light.attach(
  io: File.open(Rails.root.join("app/assets/images/default-badge-light.png")),
  filename: "fourmi1.png"
)

badge2 = Badge.create!(
  description: 'Pour gagner ce badge, il faut posséder au moins 100 actions Time for the Planet' +
    '<span class="brand">®</span>.',
  fun_description: "Chacun fait sa part et ça compte !",
  category: "financial",
  name: "Colibri",
  position: 1,
  external_uid: "rec2"
)

badge2.picture_light.attach(
  io: File.open(Rails.root.join("app/assets/images/default-badge-light.png")),
  filename: "colibri.png"
)

badge3 = Badge.create!(
  description: 'Pour gagner ce badge, il faut posséder au moins 200 actions Time for the Planet' +
    '<span class="brand">®</span>.',
  fun_description: "Bien plus utile chez Time for the Planet que dans un broyeur !",
  category: "financial",
  name: "Poussin",
  position: 1,
  external_uid: "rec3"
)

badge3.picture_light.attach(
  io: File.open(Rails.root.join("app/assets/images/default-badge-light.png")),
  filename: "poussin.png"
)

puts "Seeds for users, companies and shares purchases"

investor_individual = Individual.create!(
  first_name: "Joe",
  last_name: "Doe",
  email: "joedoe@gmail.com",
  date_of_birth: "12/09/1990",
  city: "Lyon",
  phone: "0645859963",
  current_job: "Dev",
  is_displayed: true,
  description: "description",
  reasons_to_join: "no reason"
)
investor = User.create!(
  individual: investor_individual,
  password: "azerty123",
  pending: false,
  confirmed_at: DateTime.now
)

SharesPurchase.create!(
  amount: 400,
  completed_at: Date.today,
  individual: investor_individual,
  typeform_answer_uid: "rec60",
  form_completed_at: DateTime.now - 3.minutes,
  payment_method: "card_stripe"
)

SharesPurchase.create!(
  amount: 2400,
  completed_at: DateTime.now - 2.months,
  individual: investor_individual,
  typeform_answer_uid: "rec61",
  form_completed_at: DateTime.now - 3.months,
  payment_method: "transfer_ce"
)

SharesPurchase.create!(
  amount: 100,
  completed_at: DateTime.now - 2.days,
  individual: investor_individual,
  typeform_answer_uid: "rec62",
  form_completed_at: DateTime.now - 3.days,
  payment_method: "card_stripe"
)

SharesPurchase.create!(
  amount: 1000,
  completed_at: DateTime.now - 67.days,
  individual: investor_individual,
  typeform_answer_uid: "rec80",
  form_completed_at: DateTime.now - 68.days,
  payment_method: "transfer_ce",
  company_info: {name: "Nada 1067"}
)

SharesPurchase.create!(
  amount: 2000,
  completed_at: DateTime.now - 30.days,
  individual: investor_individual,
  typeform_answer_uid: "rec81",
  form_completed_at: DateTime.now - 31.days,
  payment_method: "card_stripe",
  company_info: {name: "56K Inc"}
)

company = Company.create!(
  name: "Nada 1067",
  address: "33 quai fulrichon",
  description: "description",
  is_displayed: true,
  admin: investor
)

beyonce = Individual.create!(
  email: "beyonce@gmail.com",
  first_name: "Beyonce",
  last_name: "Knowles",
  date_of_birth: "25/06/1990",
  employer_id: company.id,
  city: "Chicago",
  phone: "0645859963",
  current_job: "Queen of the world",
  is_displayed: true,
  description: "description",
  reasons_to_join: "no reason"
)

greta = Individual.create!(
  email: "greta@gmail.com",
  first_name: "Greta",
  last_name: "Thunberg",
  date_of_birth: "23/08/1995",
  employer_id: company.id,
  city: "Stockholm",
  phone: "0645859963",
  current_job: "Activist",
  is_displayed: true,
  description: "description",
  reasons_to_join: "no reason",
)

nils = Individual.create!(
  email: "nils@gmail.com",
  first_name: "Nils",
  last_name: "Frahm",
  date_of_birth: "31/07/1985",
  city: "Berlin",
  phone: "0645859963",
  current_job: "Musician",
  is_displayed: true,
  description: "description",
  reasons_to_join: "no reason"
)

alex = Individual.create!(
  email: "alex@gmail.com",
  first_name: "Alex",
  last_name: "Bouvier",
  date_of_birth: "04/06/1986",
  city: "Lyon",
  phone: "0612345678",
  current_job: "dev",
  is_displayed: true,
  description: "description",
  reasons_to_join: "no reason"
)

mehdi = Individual.create!(
  email: "mehdi@gmail.com",
  first_name: "Mehdi",
  last_name: "Coly",
  date_of_birth: "17/12/1986",
  city: "Lyon",
  phone: "0612345678",
  current_job: "entrepreneur",
  is_displayed: true,
  description: "description",
  reasons_to_join: "no reason"
)

laurent = Individual.create!(
  email: "laurent@gmail.com",
  first_name: "Laurent",
  last_name: "Morel",
  date_of_birth: "12/10/1986",
  city: "Lyon",
  phone: "0612345678",
  current_job: "entrepreneur",
  is_displayed: true,
  description: "description",
  reasons_to_join: "no reason"
)

SharesPurchase.create!(
  amount: 100,
  completed_at: DateTime.now,
  individual: greta,
  typeform_answer_uid: "rec12",
  form_completed_at: DateTime.now - 31.minutes,
  payment_method: "card_stripe"
)

SharesPurchase.create!(
  amount: 600,
  completed_at: DateTime.now,
  individual: beyonce,
  typeform_answer_uid: "rec13",
  form_completed_at: DateTime.now - 4.minutes,
  payment_method: "card_stripe"
)

SharesPurchase.create!(
  amount: 60,
  completed_at: DateTime.now,
  individual: nils,
  typeform_answer_uid: "rec14",
  form_completed_at: DateTime.now - 4.minutes,
  payment_method: "card_stripe"
)

SharesPurchase.create!(
  amount: 60,
  completed_at: DateTime.now,
  individual: nils,
  typeform_answer_uid: "rec15",
  form_completed_at: DateTime.now - 4.minutes,
  payment_method: "card_stripe"
)

SharesPurchase.create!(
  amount: 60,
  completed_at: DateTime.now,
  individual: mehdi,
  typeform_answer_uid: "rec16",
  form_completed_at: DateTime.now - 4.minutes,
  payment_method: "card_stripe"
)

SharesPurchase.create!(
  amount: 60,
  completed_at: DateTime.now,
  individual: laurent,
  typeform_answer_uid: "rec17",
  form_completed_at: DateTime.now - 4.minutes,
  payment_method: "card_stripe"
)

puts "Seeds for Accomplishment"

accomplishment = Accomplishment.create!(
  badge_id: badge1.id,
  entity: investor_individual
)

puts "Seeds for Role"

role_1 = Role.create!(name: "Actionnaire", description: "Actionnaire", external_uid: "rec1")
role_2 = Role.create!(name: "Quark", description: "Quark", external_uid: "rec2")
Role.create!(name: "Gluon", description: "Gluon", external_uid: "rec3")
Role.create!(name: "Ambassadeur", description: "Ambassadeur", external_uid: "rec4")
Role.create!(name: "Leader", description: "Leader", external_uid: "rec5")

investor_individual.roles << [role_1, role_2]

puts "Seeds for AdminUser"

AdminUser.create!(
  email: "admin@example.com",
  password: "password",
)
AdminUser.create!(
  email: "alex@gmail.com",
  password: "password",
)
AdminUser.create!(
  email: "medhi@gmail.com",
  password: "password",
)
AdminUser.create!(
  email: "laurent@gmail.com",
  password: "password",
)

puts "Seeds for Tag"

Tag.create!(category: Category.last, name_i18n: {fr: "Tag name"}, slug: "slug")

puts "Seeds for Content"

Content.create!(
  cover_image_url: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Logo-time-planet-b6f6724079b63c886d5fd14e3850482d54707f81f3cabe25e7eae48caf0c5cac_%281%29.png/600px-Logo-time-planet-b6f6724079b63c886d5fd14e3850482d54707f81f3cabe25e7eae48caf0c5cac_%281%29.png",
  status: "published",
  title_i18n: {fr: "toto"},
  slug: "toto",
  meta_title_i18n: {fr: "toto"},
  meta_description_i18n: {fr: "toto"},
  body_i18n: {fr: "toto"},
  cover_image_alt_i18n: {fr: "toto"},
  short_title_i18n: {fr: "toto"},
  youtube_video_id: "https://www.youtube.com/watch?v=USDcHXlhsc0&ab_channel=TimeForThePlanet",
  category: Category.find_by(title: Category::MEDIA_TITLE)
)

Content.create!(
  status: "published",
  title_i18n: {fr: "Petites actions"},
  slug: "petites-action",
  category: Category.first,
  id: Content::QUICK_ACTIONS
)

Content.create!(
  status: "published",
  title_i18n: {fr: "Devenir évaluateur"},
  slug: "become-evaluator",
  category: Category.first,
  id: Content::EVALUATOR_CONTENT_ID
)

Content.create!(
  status: "published",
  title_i18n: {fr: "Comptes annuels de la société"},
  slug: "annual-accounts",
  category: Category.find_by(title: "legal_documents"),
  id: Content::ANNUAL_ACCOUNTS_ID
)

Content.create!(
  status: "published",
  title_i18n: {fr: "Dossier d'investissement"},
  slug: "investment-brief",
  category: Category.find_by(title: "files"),
  id: Content::INVESTMENT_BRIEF_ID
)

puts "Seeds for events"

FactoryBot.create(
  :event,
  title: "Séances Questions/Réponses avec les Keepers de Time for the Planet",
  date: Time.now + 2.days,
  external_uid: "aaa"
)

FactoryBot.create(
  :event,
  title: "Soirée de clôture de la comète présélection des innovations T1 2021",
  date: Time.now + 10.days,
  external_uid: "bbb"
)

FactoryBot.create(
  :event,
  title: "La Fresque du Climat embarque les associés Time for the Planet !",
  date: Time.now - 3.days,
  external_uid: "ccc"
)

FactoryBot.create(
  :event,
  title: "Lancement de Time for the Planet en Bretagne",
  date: Time.now - 9.days,
  external_uid: "ddd"
)

puts "Seeds for innovations"

FactoryBot.create(
  :innovation,
  name: "Etendage à linge",
  short_description_i18n: {fr: "Combine technologie solaire et éolienne."},
  submitted_at: 10.days.ago,
  evaluations_amount: 560,
  rating: 3.6,
  country: "ESP",
  city: "Madrid",
  status: "submitted_to_evaluations",
  founders: ["Michèle Doe", "Jean-Michel Inconnu"],
  problem_solved_i18n: {fr: "Le séchoir à linge ça consomme de l'énergie."},
  solution_explained_i18n: {fr: "On place le linge mouillé sur une structure métallique filaire,
    et sous l'action de l'énergie solaire et éolienne bah le linge y sèche. C'est révolutionnaire."},
  potential_clients_i18n: {fr: "Tous les gens qui peuvent attendre un peu que leurs chaussettes sèchent."},
  differentiating_elements_i18n: {fr: "On est les premiers à y penser, enfin je crois."}
)

FactoryBot.create(
  :innovation,
  name: "Marcher",
  short_description_i18n: {fr: "Transport disruptif 0 émissions."},
  submitted_at: 15.days.ago,
  evaluations_amount: 200,
  rating: 2,
  country: "SEN",
  city: "Dakar",
  status: "submitted_to_general_assembly"
)

FactoryBot.create(
  :innovation,
  name: "Gros pull de Mamie",
  short_description_i18n: {fr: "Améliorer l'isolation thermique individuelle."},
  submitted_at: 2.days.ago,
  evaluations_amount: 54,
  rating: 1.3,
  country: "USA",
  city: "Chicago",
  status: "submitted_to_evaluations"
)

FactoryBot.create(
  :innovation,
  name: "Bateau à voile",
  short_description_i18n: {fr: "Transport maritime avec un très grand kite surf."},
  submitted_at: 3.months.ago,
  evaluations_amount: 642,
  rating: 5,
  country: "CHN",
  city: "Beijing",
  status: "submitted_to_evaluations"
)

FactoryBot.create(
  :innovation,
  name: "Perceuse du voisin",
  short_description_i18n: {fr: "Solution de hardware sharing participatif communautaire."},
  submitted_at: 20.days.ago,
  evaluations_amount: 167,
  rating: 4.2,
  country: "CHL",
  city: "Santiago",
  status: "submitted_to_economical_tests"
)

FactoryBot.create(
  :innovation,
  name: "Pisser sous la douche",
  short_description_i18n: {fr: "En plus c'est vraiment rigolo."},
  submitted_at: 7.months.ago,
  evaluations_amount: 862,
  rating: 5,
  country: "FRA",
  city: "Lyon",
  status: "star",
  displayed_on_home: "in_funded_section"
)
FactoryBot.create(:funded_innovation, innovation: Innovation.last)
