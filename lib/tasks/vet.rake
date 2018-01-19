namespace :vet do
  desc "vet all exchange"
  task :go, [:exchange_name] => :environment do |t, args|
    klass_name = args[:exchange_name]
    bi_box = klass_name.constantize.new(nil, nil, true)
    bi_box.fetch_good_trade
  end
end