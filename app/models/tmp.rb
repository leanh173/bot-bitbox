class Tmp < Vet
  def get_offer coin, big_coin
    url = "https://bleutrade.com/api/v2/public/getorderbook?type=ALL&market=#{coin}_#{big_coin}&depth=100"
    response = JSON.parse(RestClient.get(url))
    bid = find_good_bid response["result"]["buy"], big_coin
    ask = find_good_ask response["result"]["sell"], big_coin
    {bid: bid, ask: ask}
  end

  def find_good_bid order_list, big_coin
    price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
    order_list.sort_by{|a| -a["Rate"].to_f}.each do |order|
      return {price: order["Rate"].to_f, volume: order["Quantity"].to_f} if order["Rate"].to_f * order["Quantity"].to_f * price > MIN_USDT_TRANSACTION
    end
    nil
  end

  def find_good_ask order_list, big_coin
    price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
    order_list.sort_by{|a| a["Rate"].to_f}.each do |order|
      return {price: order["Rate"].to_f, volume: order["Quantity"].to_f} if order["Rate"].to_f * order["Quantity"].to_f * price > MIN_USDT_TRANSACTION
    end
    nil
  end

  # def get_eth_btc_ask_bid
  #   eth_btc = get_offer "BTC", coin_exchange
  #   [eth_btc[:ask][:price], eth_btc[:bid][:price]]
  # end

  # def coin_exchange #like ETH
  #   "DOGE"
  # end

  # def price_coin_exchange_usd
  #   0.01
  # end

  def list_coin_checked
    url = 'https://bleutrade.com/api/v2/public/getmarkets'
    response = JSON.parse(RestClient.get(url))["result"]
    response.select{|a| a["BaseCurrency"] == "ETH"}.map{|b| b["MarketCurrency"]}
  end
end