namespace :individuals do
  desc "Decrypt coordinates"
  task decrypt: :environment do
    Individual.find_each.with_index do |individual, index|
      puts index if index % 100 == 0

      individual.update(
        decrypted_latitude: individual.latitude,
        decrypted_longitude: individual.longitude
      )
    end
  end
end
