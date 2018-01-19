namespace :bibox do
  desc "vet all transaction"
  task :vet => :environment do
    bi_box = BiBox.new(nil, nil, true)
    bi_box.fetch_good_trade
  end
end



# def send_request(api_path, cmds)
#   secret = '60c58b49a836bb0bdf3655cd0c4dc3052d20d614'
#   api_key = 'b528571ec79d846d192a7e3d8f7f6538a7066ef1'
#   sign = HMAC::MD5.new(secret).update(cmds).hexdigest
#   url = api_url(api_path)

#   params = {cmds: cmds, apikey: api_key, sign: sign}

#   response = JSON.parse(RestClient.post(url, params))
#   response
# end

# def api_url(api_path)
#   'https://api.bibox.com/' + api_path
# end

# def get_all_btc
#   api_path = "v1/transfer"
#   cmds = '[{"cmd":"transfer/assets","body":{}}]'
#   response = send_request(api_path, cmds)
#   response["result"].first["result"]["total_btc"].to_f
# end

# def get_avaible_coin coin_symbol
#   api_path = "v1/transfer"
#   cmds = '[{"cmd":"transfer/coinList","body":{}}]'
#   response = send_request(api_path, cmds)
#   response["result"].first["result"].find{|coin| coin["symbol"] == coin_symbol}["balance"].to_f
# end

#-------------------------------------------------------------------------------------

# def process_coin(coin_name, eth_btc_ask, eth_btc_bid)
#   #coin_eth_price_data = get_bid_ask coin_name, "ETH"
#   coin_eth_ask_price = coin_eth_price_data["asks"].first["price"].to_f
#   coin_eth_ask_volume = coin_eth_price_data["asks"].first["volume"].to_f

#   coin_eth_bid_price = coin_eth_price_data["bids"].first["price"].to_f
#   coin_eth_bid_volume = coin_eth_price_data["bids"].first["volume"].to_f


#   #coin_btc_price_data = get_bid_ask coin_name, "BTC"
#   coin_btc_ask_price = coin_btc_price_data["asks"].first["price"].to_f
#   coin_btc_ask_volume = coin_btc_price_data["asks"].first["volume"].to_f

#   coin_btc_bid_price = coin_btc_price_data["bids"].first["price"].to_f
#   coin_btc_bid_volume = coin_btc_price_data["bids"].first["volume"].to_f

#   checkerEthCoinPoint = (1/coin_eth_ask_price) * coin_btc_bid_price / eth_btc_ask.to_f
#   checkerBitCoinPoint = (1/coin_btc_ask_price) * coin_eth_bid_price * eth_btc_bid.to_f

#   money_btc = [coin_btc_ask_volume, coin_eth_bid_volume].min * coin_btc_ask_price * BTC_USDT
#   money_eth = [coin_eth_ask_volume, coin_btc_bid_volume].min * coin_eth_ask_price * ETH_USDT

#   if(checkerEthCoinPoint > 1.01 )
#     puts("GO ETH => " + coin_name + " Point: " + checkerEthCoinPoint.to_s + " --- Volume: [" + coin_eth_ask_price.to_s + " - " + coin_eth_ask_volume.to_s + " / " + coin_btc_bid_price.to_s + " - " + coin_btc_bid_volume.to_s + "] => $" + money_eth.to_i.to_s)
    
#   end

#   if (checkerBitCoinPoint > 1.0 )
#     puts("GO BTC => " + coin_name + " Point: " + checkerBitCoinPoint.to_s + " --- Volume:[" + coin_btc_ask_price.to_s + " - " + coin_btc_ask_volume.to_s + " / " + coin_eth_bid_price.to_s + coin_eth_bid_volume.to_s + "] => $" + money_btc.to_i.to_s)
#   end
# end

# éo đc chạy trên bibox
# def buy coin, big_coin, price, amount
#   api_path = "v1/orderpending"
#   body = {"pair": "#{coin}_#{big_coin}",
#           "account_type": 0,   #account type，0-regular account，1-margin account
#           "order_type": 2,     #order type，1-market order，2-limit order
#           "order_side": 1,     #order side，1-bid，2-ask
#           "pay_bix": true,        #whether using bix for transaction fee，0-no，1-yes
#           "price": price,          #price
#           "amount": amount,         #amount
#           "money": price*amount,          #money
#          }
#   cmds = '[{"cmd":"orderpending/trade","body":' + body.to_s + '}]'
#   binding.pry
#   # response = send_request(api_path, cmds)
#   # response["result"].first["result"]["total_btc"].to_f
# end
