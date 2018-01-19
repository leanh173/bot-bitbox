class Bitso < Vet
  BTC_USDT = 13000
  ETH_USDT = 0.0532
  MIN_USDT_TRANSACTION = 100 # $100

  def get_offer coin, big_coin
    url = "https://api.bitso.com/v3/order_book?book=#{coin}_#{big_coin}"
    response = JSON.parse(RestClient.get(url))
    bid = find_good_bid response["payload"]["bids"], big_coin
    ask = find_good_ask response["payload"]["asks"], big_coin
    {bid: bid, ask: ask}
  rescue
    {bid: nil, ask: nil}
  end

  def find_good_bid order_list, big_coin
    price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
    order_list.sort_by{|a| -a["price"].to_f}.each do |order|
      return {price: order["price"].to_f, volume: order["amount"].to_f} if order["price"].to_f * order["amount"].to_f * price > @min_money
    end
    nil
  end

  def find_good_ask order_list, big_coin
    price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
    order_list.sort_by{|a| a["price"].to_f}.each do |order|
      return {price: order["price"].to_f, volume: order["amount"].to_f} if order["price"].to_f * order["amount"].to_f * price > @min_money
    end
    nil
  end

  def coin_exchange #default ETH
    "mxn"
  end

  def get_eth_btc_ask_bid
    eth_btc = get_offer "BTC", coin_exchange
    [eth_btc[:ask][:price], eth_btc[:bid][:price]]
  end

  def list_coin_checked
    ["xrp", "eth", "ltc"]
  end
end