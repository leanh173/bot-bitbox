class Binance < Vet
  BTC_USDT = 11000
  ETH_USDT = 14
  MIN_USDT_TRANSACTION = 200 # $100

  def get_offer coin, big_coin
    url = "https://www.binance.com/api/v1/depth?symbol=#{coin}#{big_coin}"
    response = JSON.parse(RestClient.get(url))
    bid = find_good_bid response["bids"], big_coin
    ask = find_good_ask response["asks"], big_coin
    {bid: bid, ask: ask}
  end

  def find_good_bid order_list, big_coin
    price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
    order_list.sort_by{|a| -a[0].to_f}.each do |order|
      return {price: order[0].to_f, volume: order[1].to_f} if order[0].to_f * order[1].to_f * price > MIN_USDT_TRANSACTION
    end
    nil
  end

  def find_good_ask order_list, big_coin
    price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
    order_list.sort_by{|a| a[0].to_f}.each do |order|
      return {price: order[0].to_f, volume: order[1].to_f} if order[0].to_f * order[1].to_f * price > MIN_USDT_TRANSACTION
    end
    nil
  end

  def coin_exchange #default ETH
    "BNB"
  end

  def list_coin_checked
    url = 'https://www.binance.com/exchange/public/product'
    response = JSON.parse(RestClient.get(url))["data"]
    response.select{|a| a["quoteAssetName"] == "Binance"}.map{|b| b["baseAsset"]}
  end
end