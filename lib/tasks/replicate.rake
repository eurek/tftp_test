Bundler.require(:rake)

namespace :replicate do
  desc "Copy production environment to staging"
  task prod_to_staging: [:environment] do
    copy_s3("s3://time-planet", "s3://staging-time-planet", delete: false)
    copy_db_to_heroku_app("time-planet::DATABASE_URL", "staging-time-planet")
  end

  desc "Copy prod environment to development (local)"
  task prod_to_dev: [:environment] do
    copy_s3("s3://time-planet", "s3://dev-time-planet", delete: true)
    copy_heroku_db_to_dev_db("time-planet", "time-planet_development")
  end

  desc "Copy prod environment to development (local)"
  task db_prod_to_dev: [:environment] do
    copy_heroku_db_to_dev_db("time-planet", "time-planet_development")
  end

  desc "Copy staging environment to development (local)"
  task staging_to_dev: [:environment] do
    copy_s3("s3://staging-time-planet", "s3://dev-time-planet", delete: true)
    copy_heroku_db_to_dev_db("staging-time-planet", "time-planet_development")
  end

  def step_log(message)
    puts ""
    puts "-------------------------------------"
    puts "> #{message}"
    puts "-------------------------------------"
    puts ""
  end

  def copy_s3(source, destination, delete:, ask: true)
    return unless !ask || HighLine.new.agree("Do you want to sync S3 files? [y/n]")

    # If you have a fast internet connection you can speed this up by updating your AWS CLI config
    #   aws configure set default.s3.max_concurrent_requests 50
    #   aws configure set default.s3.max_queue_size 5000

    # delete flag: will delete data in the destination that doesn't exist in the source. useful to cleanup
    # staging and dev buckets from temporary data

    env = {
      "AWS_ACCESS_KEY_ID" => Rails.application.credentials.dig(:aws, :sync, :access_key_id),
      "AWS_SECRET_ACCESS_KEY" => Rails.application.credentials.dig(:aws, :sync, :secret_access_key)
    }

    delete = delete ? "--delete" : ""

    step_log "Synchronizing S3 data, from #{source} to #{destination}"

    system(env, "aws s3 sync #{delete} #{source} #{destination}", exception: true) || raise("Stopping...")
  rescue Errno::ENOENT => e
    puts "An error occurred, the AWS CLI tools don't seem to be installed, see" \
      "https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html: #{e}"
  rescue => e
    puts "An error occurred: #{e}"
  end

  def copy_heroku_db_to_dev_db(heroku_app, destination_database)
    step_log "Copying Heroku database for app #{heroku_app} into local database #{destination_database}"

    env = {
      "RAILS_ENV" => "development",
      "RAILS_LOG_TO_STDOUT" => "1",
      "LOG_LEVEL_ACTIVE_RECORD" => "WARN"
    }

    step_log "- dropping current dev database"
    system(env, "bundle exec rake db:drop") || raise("Stopping...")

    step_log "- copying heroku db"
    system(env,
      "heroku pg:pull DATABASE_URL #{destination_database} --app #{heroku_app} > /dev/null") || raise("Stopping...")

    step_log "- migrating"
    system(env, "bundle exec rake db:migrate") || raise("Stopping...")

    step_log "- setting db environment"
    system(env, "bundle exec rake db:environment:set") || raise("Stopping...")

    step_log "- fixing URLs"
    system(env, "bundle exec rake urls:match_environment") || raise("Stopping...")

    step_log "- fixing active storage service_name in db"
    ActiveStorage::Blob.update_all(service_name: :amazon_dev)

    env = {
      "RAILS_ENV" => "test"
    }

    step_log "- recreating test db"
    system(env, "bundle exec rake db:drop db:create db:migrate > /dev/null") || raise("Stopping...")
  rescue Errno::ENOENT => e
    puts "An error occurred, the Heroku CLI tools don't seem to be installed, see " \
      "https://devcenter.heroku.com/articles/heroku-cli: #{e}"
  rescue => e
    puts "An error occurred: #{e}"
  end

  def copy_db_to_heroku_app(heroku_source, destination_app)
    step_log "Copying heroku DB from #{heroku_source} to #{destination_app}"
    system("heroku pg:copy #{heroku_source} DATABASE_URL --app #{destination_app}")

    step_log "- setting db environment"
    system("heroku run bundle exec rake db:environment:set --app #{destination_app}") || raise("Stopping...")

    step_log "- fixing URLs"
    system("heroku run bundle exec rake urls:match_environment --app #{destination_app}") || raise("Stopping...")

    step_log "- fixing active storage service_name in db"
    system("heroku run bundle exec rake urls:service_match_environment --app #{destination_app}") ||
      raise("Stopping...")
  rescue Errno::ENOENT => e
    puts "An error occurred, the Heroku CLI tools don't seem to be installed, see " \
      "https://devcenter.heroku.com/articles/heroku-cli: #{e}"
  rescue => e
    puts "An error occurred: #{e}"
  end
end
