require 'rest-client'
require 'json'
require 'hmac-md5'

BTC_USDT = 13000
ETH_USDT = 1300
MIN_USDT_TRANSACTION = 100 # $100

namespace :bibox do
  desc "vet all transaction"
  task :vet => :environment do

    #puts send_request("v1/user", cmds)

    puts "#{Time.now} : GO!"

    puts "loading list coin ......."

    # url = 'https://api.bibox.com/v1/mdata?cmd=marketAll'
    # response = JSON.parse(RestClient.get(url))["result"]
    # list_coin = response.map{ |coin| coin["coin_symbol"] }.uniq
    # list_coin = list_coin - ["ETH", "BTC"]


    list_coin = ["BIX", "GTC", "LTC", "BCH", "ETC", "TNB", "EOS", "CMT", "BTM", "LEND", "RDN", "MANA", "HPB", "SBTC", "ELF", "MKR", "ITC", "MOT", "GNX", "CAT", "CAG", "SHOW", "AIDOC", "AWR", "BTO", "AMM"]

    puts "DONE"

    puts "loading eth btc price ....."

    url = 'https://api.bibox.com/v1/mdata?cmd=depth&pair=ETH_BTC&size=1'
    response = JSON.parse(RestClient.get(url))["result"]
    eth_btc_ask = response["asks"].first["price"]
    eth_btc_bid = response["bids"].first["price"]

    puts eth_btc_ask
    puts eth_btc_bid

    puts "DONE"

    puts "Get coin data in list"

    #fetch data coins
    btc_offer_bids = {}; btc_offer_asks = {}; eth_offer_bids = {}; eth_offer_asks = {}
    list_coin.each do |coin_name|
      #process_coin(coin_name, eth_btc_ask, eth_btc_bid)
      puts coin_name
      offer_coin_btc = get_offer coin_name, "BTC"
      btc_offer_bids[coin_name] = offer_coin_btc[:bid]
      btc_offer_asks[coin_name] = offer_coin_btc[:ask]

      offer_coin_eth = get_offer coin_name, "ETH"
      eth_offer_bids[coin_name] = offer_coin_eth[:bid]
      eth_offer_asks[coin_name] = offer_coin_eth[:ask]
    end

    # puts "btc_offer_bids"
    # puts btc_offer_bids
    # puts "btc_offer_asks"
    # puts btc_offer_asks
    # puts "-------------------"
    # puts "eth_offer_bids"
    # puts eth_offer_bids
    # puts "eth_offer_asks"
    # puts eth_offer_asks

    #caculate good btc offer
    max_btc_alt_eth = 0
    volume_btc_alt_eth = 0
    btc_alt_eth_name = ""
    list_coin.each do |coin_name|
    # btc -> altcoin -> eth
      if btc_offer_asks[coin_name] && eth_offer_bids[coin_name]
        num_eth_per_btc = 1/btc_offer_asks[coin_name][:price]*eth_offer_bids[coin_name][:price]
        if num_eth_per_btc > max_btc_alt_eth
          max_btc_alt_eth = num_eth_per_btc
          volume_btc_alt_eth = [btc_offer_asks[coin_name][:volume], eth_offer_bids[coin_name][:volume]].min
          btc_alt_eth_name = coin_name
        end
      end
    end

    puts "================BTC======================"
    puts btc_alt_eth_name
    puts max_btc_alt_eth
    puts volume_btc_alt_eth.to_s + " ~ $" + (volume_btc_alt_eth*btc_offer_asks[btc_alt_eth_name][:price]*BTC_USDT).to_i.to_s
    puts 1/(eth_btc_ask.to_f)
    puts 1/(eth_btc_bid.to_f)
    puts "SHIT! DO NOT GO HERE" if max_btc_alt_eth < 1/(eth_btc_ask.to_f)

    puts "BUY in BTC price < " + btc_offer_asks[btc_alt_eth_name][:price].to_s + " Volume " + volume_btc_alt_eth.to_s + " / " + btc_offer_asks[btc_alt_eth_name][:volume].to_s
    puts "SELL in ETH price > " + eth_offer_bids[btc_alt_eth_name][:price].to_s + " Volume " + volume_btc_alt_eth.to_s + " / " + eth_offer_bids[btc_alt_eth_name][:volume].to_s
    puts "======================================"

    #caculate good eth offer

    max_eth_alt_btc = 0
    volume_eth_alt_btc = 0
    eth_alt_btc_name = ""
    list_coin.each do |coin_name|
    # btc -> altcoin -> eth
      if eth_offer_asks[coin_name] && btc_offer_bids[coin_name]
        num_btc_per_eth = 1/eth_offer_asks[coin_name][:price]*btc_offer_bids[coin_name][:price]
        if num_btc_per_eth > max_eth_alt_btc
          max_eth_alt_btc = num_btc_per_eth
          volume_eth_alt_btc = [eth_offer_asks[coin_name][:volume], btc_offer_bids[coin_name][:volume]].min
          eth_alt_btc_name = coin_name
        end
      end
    end

    puts "==================ETH===================="
    puts eth_alt_btc_name
    puts max_eth_alt_btc
    puts volume_eth_alt_btc.to_s + " ~ $" + (volume_eth_alt_btc*eth_offer_asks[eth_alt_btc_name][:price]*ETH_USDT).to_i.to_s
    puts eth_btc_ask.to_f
    puts eth_btc_bid.to_f
    puts "SHIT! DO NOT GO HERE" if max_eth_alt_btc < eth_btc_bid.to_f

    puts "BUY in ETH price < " + eth_offer_asks[eth_alt_btc_name][:price].to_s + " Volume " + volume_eth_alt_btc.to_s + " / " + eth_offer_asks[eth_alt_btc_name][:volume].to_s
    puts "SELL in BTC price > " + btc_offer_bids[eth_alt_btc_name][:price].to_s + " Volume " + volume_eth_alt_btc.to_s + " / " + btc_offer_bids[eth_alt_btc_name][:volume].to_s
    puts "======================================"

    puts "Estimated Profit: " + ((max_btc_alt_eth*max_eth_alt_btc - 1)*100).to_s + " %"


    # puts "----------------------------------------"

    # puts("All MONEY : " + get_all_btc.to_s + " BTC")
    # puts("ETC: " + get_avaible_coin("ETH").to_s)

    puts "#{Time.now} : END"
  end
end



def send_request(api_path, cmds)
  secret = '60c58b49a836bb0bdf3655cd0c4dc3052d20d614'
  api_key = 'b528571ec79d846d192a7e3d8f7f6538a7066ef1'
  sign = HMAC::MD5.new(secret).update(cmds).hexdigest
  url = api_url(api_path)

  params = {cmds: cmds, apikey: api_key, sign: sign}

  response = JSON.parse(RestClient.post(url, params))
  response
end

def api_url(api_path)
  'https://api.bibox.com/' + api_path
end

def get_all_btc
  api_path = "v1/transfer"
  cmds = '[{"cmd":"transfer/assets","body":{}}]'
  response = send_request(api_path, cmds)
  response["result"].first["result"]["total_btc"].to_f
end

def get_avaible_coin coin_symbol
  api_path = "v1/transfer"
  cmds = '[{"cmd":"transfer/coinList","body":{}}]'
  response = send_request(api_path, cmds)
  response["result"].first["result"].find{|coin| coin["symbol"] == coin_symbol}["balance"].to_f
end

def get_offer coin, big_coin
  url = "https://api.bibox.com/v1/mdata?cmd=depth&pair=#{coin}_#{big_coin}&size=10"
  response = JSON.parse(RestClient.get(url))
  bid = find_good_bid response["result"]["bids"], big_coin
  ask = find_good_ask response["result"]["asks"], big_coin
  {bid: bid, ask: ask}
end

def find_good_bid order_list, big_coin
  price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
  order_list.sort_by{|a| -a["price"].to_f}.each do |order|
    return {price: order["price"].to_f, volume: order["volume"].to_f} if order["price"].to_f * order["volume"].to_f * price > MIN_USDT_TRANSACTION
  end
  nil
end

def find_good_ask order_list, big_coin
  price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
  order_list.sort_by{|a| a["price"].to_f}.each do |order|
    return {price: order["price"].to_f, volume: order["volume"].to_f} if order["price"].to_f * order["volume"].to_f * price > MIN_USDT_TRANSACTION
  end
  nil
end


#-------------------------------------------------------------------------------------

def process_coin(coin_name, eth_btc_ask, eth_btc_bid)
  #coin_eth_price_data = get_bid_ask coin_name, "ETH"
  coin_eth_ask_price = coin_eth_price_data["asks"].first["price"].to_f
  coin_eth_ask_volume = coin_eth_price_data["asks"].first["volume"].to_f

  coin_eth_bid_price = coin_eth_price_data["bids"].first["price"].to_f
  coin_eth_bid_volume = coin_eth_price_data["bids"].first["volume"].to_f


  #coin_btc_price_data = get_bid_ask coin_name, "BTC"
  coin_btc_ask_price = coin_btc_price_data["asks"].first["price"].to_f
  coin_btc_ask_volume = coin_btc_price_data["asks"].first["volume"].to_f

  coin_btc_bid_price = coin_btc_price_data["bids"].first["price"].to_f
  coin_btc_bid_volume = coin_btc_price_data["bids"].first["volume"].to_f

  checkerEthCoinPoint = (1/coin_eth_ask_price) * coin_btc_bid_price / eth_btc_ask.to_f
  checkerBitCoinPoint = (1/coin_btc_ask_price) * coin_eth_bid_price * eth_btc_bid.to_f

  money_btc = [coin_btc_ask_volume, coin_eth_bid_volume].min * coin_btc_ask_price * BTC_USDT
  money_eth = [coin_eth_ask_volume, coin_btc_bid_volume].min * coin_eth_ask_price * ETH_USDT

  if(checkerEthCoinPoint > 1.01 )
    puts("GO ETH => " + coin_name + " Point: " + checkerEthCoinPoint.to_s + " --- Volume: [" + coin_eth_ask_price.to_s + " - " + coin_eth_ask_volume.to_s + " / " + coin_btc_bid_price.to_s + " - " + coin_btc_bid_volume.to_s + "] => $" + money_eth.to_i.to_s)
    
  end

  if (checkerBitCoinPoint > 1.0 )
    puts("GO BTC => " + coin_name + " Point: " + checkerBitCoinPoint.to_s + " --- Volume:[" + coin_btc_ask_price.to_s + " - " + coin_btc_ask_volume.to_s + " / " + coin_eth_bid_price.to_s + coin_eth_bid_volume.to_s + "] => $" + money_btc.to_i.to_s)
  end
end

# éo đc chạy trên bibox
def buy coin, big_coin, price, amount
  api_path = "v1/orderpending"
  body = {"pair": "#{coin}_#{big_coin}",
          "account_type": 0,   #account type，0-regular account，1-margin account
          "order_type": 2,     #order type，1-market order，2-limit order
          "order_side": 1,     #order side，1-bid，2-ask
          "pay_bix": 1,        #whether using bix for transaction fee，0-no，1-yes
          "price": price,          #price
          "amount": amount,         #amount
          "money": price*amount,          #money
         }
  cmds = '[{"cmd":"orderpending/trade","body":' + body.to_s + '}]'
  binding.pry
  # response = send_request(api_path, cmds)
  # response["result"].first["result"]["total_btc"].to_f
end
