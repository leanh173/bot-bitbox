require 'rest-client'
require 'json'
require 'hmac-md5'

BTC_USDT = 13000
ETH_USDT = 1300
MIN_USDT_TRANSACTION = 100 # $100

class BiBox
  attr_reader :log, :min_money, :list_coin

  def initialize(min_money=nil, list_coin=nil)
    @log = []
    @min_money = min_money || MIN_USDT_TRANSACTION
    @list_coin = list_coin || ["BIX", "GTC", "LTC", "BCH", "ETC", "TNB", "EOS", "CMT", "BTM", "LEND", "RDN", "MANA", "HPB", "SBTC", "ELF", "MKR", "ITC", "MOT", "GNX", "CAT", "CAG", "SHOW", "AIDOC", "AWR", "BTO", "AMM"]
  end

  def fetch_good_trade
    write_log "#{Time.now} : GO!"

    # write_log "loading list coin ......."

    # url = 'https://api.bibox.com/v1/mdata?cmd=marketAll'
    # response = JSON.parse(RestClient.get(url))["result"]
    # list_coin = response.map{ |coin| coin["coin_symbol"] }.uniq
    # list_coin = list_coin - ["ETH", "BTC"]

    #list_coin = ["BIX", "GTC", "LTC", "BCH", "ETC", "TNB", "EOS", "CMT", "BTM", "LEND", "RDN", "MANA", "HPB", "SBTC", "ELF", "MKR", "ITC", "MOT", "GNX", "CAT", "CAG", "SHOW", "AIDOC", "AWR", "BTO", "AMM"]

    # write_log "DONE"

    # write_log "loading eth btc price ....."

    url = 'https://api.bibox.com/v1/mdata?cmd=depth&pair=ETH_BTC&size=1'
    response = JSON.parse(RestClient.get(url))["result"]
    eth_btc_ask = response["asks"].first["price"]
    eth_btc_bid = response["bids"].first["price"]

    write_log eth_btc_ask
    write_log eth_btc_bid

    # write_log "DONE"

    # write_log "Get coin data in list"

    #fetch data coins

    btc_offer_bids = {}; btc_offer_asks = {}; eth_offer_bids = {}; eth_offer_asks = {}
    list_coin.each do |coin_name|
      #process_coin(coin_name, eth_btc_ask, eth_btc_bid)
      #write_log coin_name
      offer_coin_btc = get_offer coin_name, "BTC"
      btc_offer_bids[coin_name] = offer_coin_btc[:bid]
      btc_offer_asks[coin_name] = offer_coin_btc[:ask]

      offer_coin_eth = get_offer coin_name, "ETH"
      eth_offer_bids[coin_name] = offer_coin_eth[:bid]
      eth_offer_asks[coin_name] = offer_coin_eth[:ask]
    end

    # write_log "btc_offer_bids"
    # write_log btc_offer_bids
    # write_log "btc_offer_asks"
    # write_log btc_offer_asks
    # write_log "-------------------"
    # write_log "eth_offer_bids"
    # write_log eth_offer_bids
    # write_log "eth_offer_asks"
    # write_log eth_offer_asks

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

    write_log "================BTC======================"
    write_log btc_alt_eth_name
    write_log max_btc_alt_eth
    write_log volume_btc_alt_eth.to_s + " ~ $" + (volume_btc_alt_eth*btc_offer_asks[btc_alt_eth_name][:price]*BTC_USDT).to_i.to_s
    write_log 1/(eth_btc_ask.to_f)
    write_log 1/(eth_btc_bid.to_f)
    write_log "<<<<< SHIT! DO NOT TRADE HERE >>>>>" if max_btc_alt_eth < 1/(eth_btc_ask.to_f)

    write_log "BUY in BTC price < " + btc_offer_asks[btc_alt_eth_name][:price].to_s + " Volume " + volume_btc_alt_eth.to_s + " / " + btc_offer_asks[btc_alt_eth_name][:volume].to_s
    write_log "SELL in ETH price > " + eth_offer_bids[btc_alt_eth_name][:price].to_s + " Volume " + volume_btc_alt_eth.to_s + " / " + eth_offer_bids[btc_alt_eth_name][:volume].to_s
    write_log "======================================"

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

    write_log "==================ETH===================="
    write_log eth_alt_btc_name
    write_log max_eth_alt_btc
    write_log volume_eth_alt_btc.to_s + " ~ $" + (volume_eth_alt_btc*eth_offer_asks[eth_alt_btc_name][:price]*ETH_USDT).to_i.to_s
    write_log eth_btc_ask.to_f
    write_log eth_btc_bid.to_f
    write_log "<<<<<< SHIT! DO NOT TRADE HERE >>>>>" if max_eth_alt_btc < eth_btc_bid.to_f

    write_log "BUY in ETH price < " + eth_offer_asks[eth_alt_btc_name][:price].to_s + " Volume " + volume_eth_alt_btc.to_s + " / " + eth_offer_asks[eth_alt_btc_name][:volume].to_s
    write_log "SELL in BTC price > " + btc_offer_bids[eth_alt_btc_name][:price].to_s + " Volume " + volume_eth_alt_btc.to_s + " / " + btc_offer_bids[eth_alt_btc_name][:volume].to_s
    write_log "======================================"

    write_log "Estimated Profit: " + ((max_btc_alt_eth*max_eth_alt_btc - 1)*100).to_s + " %"
    # write_log "----------------------------------------"

    # write_log("All MONEY : " + get_all_btc.to_s + " BTC")
    # write_log("ETC: " + get_avaible_coin("ETH").to_s)

    write_log "#{Time.now} : END"
  end

  def write_log data
    @log << data
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
end