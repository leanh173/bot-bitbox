class Bibox < Vet
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
      return {price: order["price"].to_f, volume: order["volume"].to_f} if order["price"].to_f * order["volume"].to_f * price > @min_money
    end
    nil
  end

  def find_good_ask order_list, big_coin
    price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
    order_list.sort_by{|a| a["price"].to_f}.each do |order|
      return {price: order["price"].to_f, volume: order["volume"].to_f} if order["price"].to_f * order["volume"].to_f * price > @min_money
    end
    nil
  end

  def get_eth_btc_ask_bid
    url = 'https://api.bibox.com/v1/mdata?cmd=depth&pair=ETH_BTC&size=1'
    response = JSON.parse(RestClient.get(url))["result"]
    eth_btc_ask = response["asks"].first["price"]
    eth_btc_bid = response["bids"].first["price"]
    [eth_btc_ask, eth_btc_bid]
  end

  def list_coin_checked
    ["BIX", "LTC", "BCH", "ETC", "EOS", "CMT", "BTM", "LEND", "RDN", "MANA", "HPB", "ELF", "MKR", "ITC", "GNX"]
  end
end