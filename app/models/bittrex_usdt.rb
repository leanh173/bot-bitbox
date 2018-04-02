class BittrexUsdt < Vet
  BTC_USDT = 11000
  ETH_USDT = 1
  MIN_USDT_TRANSACTION = 200 # $100

  def get_offer coin, big_coin
    url = "https://bittrex.com/api/v1.1/public/getorderbook?market=#{big_coin}-#{coin}&type=both"
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

  def get_eth_btc_ask_bid
    eth_btc = get_offer "BTC", coin_exchange
    [eth_btc[:ask][:price], eth_btc[:bid][:price]]
  end

  def coin_exchange #like ETH
    "USDT"
  end

  def list_coin_checked
    ["XRP", "ETH", "NEO", "ETC", "XVG", "ADA", "BCC", "LTC", "NXT", "OMG", "BTG", "XMR", "DASH","ZEC"]
  end
end