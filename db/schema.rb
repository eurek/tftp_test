# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_02_09_102810) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "accomplishments", force: :cascade do |t|
    t.bigint "badge_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "entity_type"
    t.bigint "entity_id"
    t.index ["badge_id"], name: "index_accomplishments_on_badge_id"
    t.index ["entity_type", "entity_id"], name: "index_accomplishments_on_entity_type_and_entity_id"
  end

  create_table "action_domains", force: :cascade do |t|
    t.string "title", null: false
    t.jsonb "name_i18n", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "action_levers", force: :cascade do |t|
    t.string "title", null: false
    t.jsonb "name_i18n", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["checksum"], name: "index_active_storage_blobs_on_checksum"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "badges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0, null: false
    t.string "external_uid"
    t.string "category"
    t.jsonb "description_i18n", default: {}
    t.jsonb "fun_description_i18n", default: {}
    t.jsonb "name_i18n", default: {}
    t.index ["external_uid"], name: "index_badges_on_external_uid", unique: true
  end

  create_table "call_to_actions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "text_i18n", default: {}
    t.jsonb "button_text_i18n", default: {}
    t.jsonb "href_i18n", default: {}
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "name_i18n", default: {}
    t.jsonb "slug_i18n", default: {}
    t.jsonb "meta_title_i18n", default: {}
    t.jsonb "meta_description_i18n", default: {}
    t.jsonb "description_i18n", default: {}
    t.string "title"
    t.jsonb "body_i18n", default: {}
    t.string "slug"
    t.jsonb "published_i18n", default: {}
    t.index ["title"], name: "index_categories_on_title", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.text "address"
    t.text "description"
    t.text "co2_emissions_reduction_actions"
    t.string "linkedin"
    t.string "facebook"
    t.string "website"
    t.boolean "is_displayed", default: true
    t.string "open_corporates_company_number"
    t.string "open_corporates_jurisdiction_code"
    t.bigint "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.string "country"
    t.integer "creator_id"
    t.string "public_slug"
    t.string "legal_form"
    t.string "structure_size"
    t.string "city"
    t.string "zip_code"
    t.text "street_address"
    t.index ["admin_id"], name: "index_companies_on_admin_id"
    t.index ["created_at"], name: "index_companies_on_created_at"
    t.index ["is_displayed"], name: "index_companies_on_is_displayed", where: "is_displayed"
    t.index ["public_slug"], name: "index_companies_on_public_slug", unique: true
  end

  create_table "content_tags", force: :cascade do |t|
    t.bigint "content_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_content_tags_on_content_id"
    t.index ["tag_id"], name: "index_content_tags_on_tag_id"
  end

  create_table "contents", force: :cascade do |t|
    t.string "cover_image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "call_to_action_id"
    t.integer "weight", default: 0
    t.jsonb "title_i18n", default: {}
    t.jsonb "slug_i18n", default: {}
    t.jsonb "meta_title_i18n", default: {}
    t.jsonb "meta_description_i18n", default: {}
    t.jsonb "body_i18n", default: {}
    t.jsonb "cover_image_alt_i18n", default: {}
    t.jsonb "short_title_i18n", default: {}
    t.string "youtube_video_id"
    t.jsonb "status_i18n", default: {}
    t.bigint "category_id"
    t.string "slug"
    t.index ["call_to_action_id"], name: "index_contents_on_call_to_action_id"
    t.index ["category_id"], name: "index_contents_on_category_id"
  end

  create_table "current_situations", force: :cascade do |t|
    t.integer "total_shareholders"
    t.jsonb "description_i18n", default: {}
    t.jsonb "structure_i18n", default: {}
  end

  create_table "episodes", force: :cascade do |t|
    t.integer "number"
    t.integer "season_number"
    t.date "started_at"
    t.date "finished_at"
    t.integer "fundraising_goal"
    t.jsonb "title_i18n", default: {}
    t.jsonb "description_i18n", default: {}
    t.jsonb "body_i18n", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "evaluations", force: :cascade do |t|
    t.bigint "innovation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "individual_id"
    t.index ["individual_id"], name: "index_evaluations_on_individual_id"
    t.index ["innovation_id"], name: "index_evaluations_on_innovation_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "locale"
    t.string "category"
    t.text "description"
    t.datetime "date"
    t.string "venue"
    t.string "registration_link"
    t.string "external_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timezone"
    t.index ["external_uid"], name: "index_events_on_external_uid", unique: true
  end

  create_table "external_link_managers", force: :cascade do |t|
    t.jsonb "shares_purchase_form_i18n", default: {}
    t.jsonb "offer_shares_form_i18n", default: {}
    t.jsonb "company_offer_shares_form_i18n", default: {}
    t.jsonb "contact_form_i18n", default: {}
    t.jsonb "b2b_contact_form_i18n", default: {}
    t.jsonb "climate_deal_meeting_form_i18n", default: {}
    t.jsonb "innovation_proposal_form_i18n", default: {}
    t.jsonb "summary_information_document_i18n", default: {}
    t.jsonb "climate_deal_presentation_document_i18n", default: {}
    t.jsonb "climate_deal_simulator_form_i18n", default: {}
    t.jsonb "report_video_i18n", default: {}
    t.jsonb "galaxy_training_event_i18n", default: {}
    t.jsonb "company_shares_purchase_form_i18n", default: {}
    t.jsonb "use_gift_coupon_i18n", default: {}
    t.jsonb "galaxy_app_i18n", default: {}
    t.jsonb "time_app_i18n", default: {}
    t.jsonb "linkedin_i18n", default: {}
  end

  create_table "funded_innovations", force: :cascade do |t|
    t.date "funded_at"
    t.date "company_created_at"
    t.integer "amount_invested"
    t.jsonb "summary_i18n", default: {}
    t.jsonb "scientific_committee_opinion_i18n", default: {}
    t.string "video_link"
    t.bigint "innovation_id"
    t.jsonb "carbon_potential_i18n", default: {}
    t.bigint "funding_episode_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "website"
    t.string "development_stage"
    t.jsonb "pitch_deck_link_i18n", default: {}
    t.jsonb "co2_reduction"
    t.index ["funding_episode_id"], name: "index_funded_innovations_on_funding_episode_id"
    t.index ["innovation_id"], name: "index_funded_innovations_on_innovation_id"
  end

  create_table "highlighted_contents", force: :cascade do |t|
    t.boolean "published", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "associate_ids_i18n", default: {}
    t.jsonb "blog_content_id_i18n", default: {}
    t.jsonb "time_media_content_id_i18n", default: {}
    t.jsonb "reason_to_join_ids_i18n", default: {}
  end

  create_table "individuals", force: :cascade do |t|
    t.string "city"
    t.string "zip_code"
    t.string "country"
    t.bigint "employer_id"
    t.string "communication_language"
    t.string "nationality"
    t.string "department_number"
    t.boolean "is_100_club"
    t.string "stacker_role"
    t.bigint "funded_innovation_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "current_job"
    t.boolean "is_displayed", default: true, null: false
    t.text "reasons_to_join"
    t.string "external_uid"
    t.string "public_slug"
    t.string "locale", default: [], array: true
    t.text "first_name_ciphertext"
    t.string "first_name_bidx"
    t.text "last_name_ciphertext"
    t.string "last_name_bidx"
    t.text "email_ciphertext"
    t.string "email_bidx"
    t.text "phone_ciphertext"
    t.string "phone_bidx"
    t.text "date_of_birth_ciphertext"
    t.string "date_of_birth_bidx"
    t.text "address_ciphertext"
    t.text "linkedin_ciphertext"
    t.text "description_ciphertext"
    t.string "public_search_text"
    t.string "username"
    t.text "origin", default: [], array: true
    t.boolean "id_card_received", default: false, null: false
    t.float "latitude"
    t.float "longitude"
    t.index ["email_bidx"], name: "index_individuals_on_email_bidx", unique: true, where: "(email_bidx IS NOT NULL)"
    t.index ["employer_id"], name: "index_individuals_on_employer_id"
    t.index ["external_uid"], name: "index_individuals_on_external_uid"
    t.index ["funded_innovation_id"], name: "index_individuals_on_funded_innovation_id"
    t.index ["public_slug"], name: "index_individuals_on_public_slug"
  end

  create_table "innovations", force: :cascade do |t|
    t.jsonb "short_description_i18n", default: {}
    t.string "status", default: "assessed"
    t.date "submitted_at"
    t.integer "evaluations_amount"
    t.string "city"
    t.float "rating"
    t.bigint "action_lever_id"
    t.bigint "action_domain_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "external_uid"
    t.string "language"
    t.string "website"
    t.jsonb "problem_solved_i18n", default: {}
    t.jsonb "solution_explained_i18n", default: {}
    t.jsonb "potential_clients_i18n", default: {}
    t.jsonb "differentiating_elements_i18n", default: {}
    t.string "founders", array: true
    t.string "country"
    t.string "selection_period"
    t.string "displayed_on_home"
    t.bigint "submission_episode_id"
    t.index ["action_domain_id"], name: "index_innovations_on_action_domain_id"
    t.index ["action_lever_id"], name: "index_innovations_on_action_lever_id"
    t.index ["external_uid"], name: "index_innovations_on_external_uid", unique: true
    t.index ["submission_episode_id"], name: "index_innovations_on_submission_episode_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "subject_type"
    t.bigint "subject_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["subject_type", "subject_id"], name: "index_notifications_on_subject"
  end

  create_table "pages", force: :cascade do |t|
    t.jsonb "title_i18n", default: {}
    t.string "slug", null: false
    t.jsonb "body_i18n", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_pages_on_slug"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.text "database"
    t.text "user"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.bigint "calls"
    t.datetime "captured_at"
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "prerequisites", force: :cascade do |t|
    t.integer "dependent_id"
    t.integer "necessary_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dependent_id"], name: "index_prerequisites_on_dependent_id"
    t.index ["necessary_id"], name: "index_prerequisites_on_necessary_id"
  end

  create_table "problems", force: :cascade do |t|
    t.jsonb "title_i18n", default: "{}"
    t.jsonb "description_i18n", default: "{}"
    t.string "action_lever"
    t.string "domain"
    t.jsonb "full_content_i18n", default: "{}"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "home_displayed", default: false
  end

  create_table "roadmap_tasks", force: :cascade do |t|
    t.datetime "done_at"
    t.string "duration_type"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.string "status", default: "to_do"
    t.jsonb "title_i18n", default: {}
    t.jsonb "text_i18n", default: {}
    t.index ["category"], name: "index_roadmap_tasks_on_category"
    t.index ["duration_type"], name: "index_roadmap_tasks_on_duration_type"
    t.index ["status"], name: "index_roadmap_tasks_on_status"
  end

  create_table "role_attributions", force: :cascade do |t|
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "entity_type"
    t.bigint "entity_id"
    t.index ["entity_type", "entity_id"], name: "index_role_attributions_on_entity"
    t.index ["role_id"], name: "index_role_attributions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_uid"
    t.integer "position", default: 0, null: false
    t.jsonb "name_i18n", default: {}
    t.jsonb "description_i18n", default: {}
    t.string "attributable_to"
    t.index ["external_uid"], name: "index_roles_on_external_uid", unique: true
  end

  create_table "shares_purchases", force: :cascade do |t|
    t.integer "amount", null: false
    t.datetime "completed_at"
    t.bigint "company_id"
    t.string "temporary_company_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_uid"
    t.bigint "individual_id"
    t.string "typeform_answer_uid"
    t.text "admin_comments"
    t.datetime "form_completed_at"
    t.string "payment_method"
    t.datetime "paid_at"
    t.text "origin"
    t.string "shares_classes"
    t.string "transfer_reference"
    t.string "payment_status", default: "pending", null: false
    t.date "official_date"
    t.string "status", default: "pending", null: false
    t.boolean "sponsor", default: false, null: false
    t.string "typeform_language"
    t.jsonb "company_info"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.string "typeform_id"
    t.string "gift_coupon_buyer_typeform_answer_uid"
    t.integer "gift_coupon_amount"
    t.string "zoho_sign_request_id"
    t.boolean "is_a_duplicate", default: false, null: false
    t.index ["company_id"], name: "index_shares_purchases_on_company_id"
    t.index ["completed_at"], name: "index_shares_purchases_on_completed_at"
    t.index ["external_uid"], name: "index_shares_purchases_on_external_uid", unique: true
    t.index ["individual_id"], name: "index_shares_purchases_on_individual_id"
    t.index ["transfer_reference"], name: "index_shares_purchases_on_transfer_reference"
    t.index ["typeform_answer_uid"], name: "index_shares_purchases_on_typeform_answer_uid"
    t.index ["zoho_sign_request_id"], name: "index_shares_purchases_on_zoho_sign_request_id", unique: true
  end

  create_table "statistics", force: :cascade do |t|
    t.date "date", null: false
    t.integer "total_shareholders", default: 0
    t.integer "total_innovations_assessed", default: 0
    t.integer "total_innovations_assessors", default: 0
  end

  create_table "tags", force: :cascade do |t|
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "name_i18n", default: {}
    t.jsonb "slug_i18n", default: {}
    t.string "slug"
    t.jsonb "published_i18n", default: {}
    t.index ["category_id"], name: "index_tags_on_category_id"
  end

  create_table "temporary_banners", force: :cascade do |t|
    t.jsonb "headline_i18n", default: {}
    t.jsonb "cta_i18n", default: {}
    t.jsonb "link_i18n", default: {}
    t.jsonb "is_displayed_i18n", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "translations", force: :cascade do |t|
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "value_i18n", default: {}
    t.index ["key"], name: "index_translations_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pending", default: true
    t.boolean "first_password_changed", default: false
    t.integer "generated_visits", default: 0, null: false
    t.bigint "individual_id"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["individual_id"], name: "index_users_on_individual_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "companies", "users", column: "admin_id"
  add_foreign_key "companies", "users", column: "creator_id"
  add_foreign_key "contents", "categories"
  add_foreign_key "funded_innovations", "episodes", column: "funding_episode_id"
  add_foreign_key "individuals", "companies", column: "employer_id"
  add_foreign_key "innovations", "action_domains"
  add_foreign_key "innovations", "action_levers"
  add_foreign_key "innovations", "episodes", column: "submission_episode_id"
  add_foreign_key "tags", "categories"
end
