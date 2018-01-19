namespace :bibox do
  desc "vet all transaction"
  task :vet => :environment do
    bi_box = BiBox.new(nil, nil, true)
    bi_box.fetch_good_trade
  end
end