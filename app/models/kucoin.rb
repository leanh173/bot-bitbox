class Kucoin < Vet
  def get_offer coin, big_coin
    url = "https://kitchen.kucoin.com/v1/open/orders-buy?symbol=#{coin}-#{big_coin}&limit=10&c=&lang=en_US"
    response = JSON.parse(RestClient.get(url))
    bid = find_good_bid response["data"], big_coin

    url = "https://kitchen.kucoin.com/v1/open/orders-sell?symbol=#{coin}-#{big_coin}&limit=10&c=&lang=en_US"
    response = JSON.parse(RestClient.get(url))
    ask = find_good_ask response["data"], big_coin
    {bid: bid, ask: ask}
  end

  def find_good_bid order_list, big_coin
    price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
    order_list.sort_by{|a| -a[2].to_f}.each do |order|
      return {price: order[0].to_f, volume: order[1].to_f} if order[0].to_f * order[1].to_f * price > @min_money
    end
    nil
  end

  def find_good_ask order_list, big_coin
    price = (big_coin == "BTC" ? BTC_USDT : ETH_USDT)
    order_list.sort_by{|a| a[2].to_f}.each do |order|
      return {price: order[0].to_f, volume: order[1].to_f} if order[0].to_f * order[1].to_f * price > @min_money
    end
    nil
  end

  def get_eth_btc_ask_bid
    url = "https://kitchen.kucoin.com/v1/open/orders-buy?symbol=ETH-BTC&limit=1&c=&lang=en_US"
    response = JSON.parse(RestClient.get(url))["data"]
    eth_btc_bid = response.first.first

    url = "https://kitchen.kucoin.com/v1/open/orders-sell?symbol=ETH-BTC&limit=1&c=&lang=en_US"
    response = JSON.parse(RestClient.get(url))["data"]
    eth_btc_ask = response.first.first
    [eth_btc_ask, eth_btc_bid]
  end

  def list_coin_checked
    # url = "https://kitchen.kucoin.com/v1/market/open/symbols?market=ETH&c=&lang=en_US"
    # response = JSON.parse(RestClient.get(url))["data"]
    # response.map{|coin| coin["coinType"]}

    ["NEO", "KCS", "TMT", "TFD", "ZINC", "CBC", "DAG", "DCC", "EDR", "LALA", "AOA", "CS", "DOCK", "ETN", "IHT", "KICK", "WAN", "APH", "BAX", "DATX", "DEB",
     "ELEC", "GO", "IOTX", "LOOM", "LYM", "MOBI", "OMX", "ONT", "OPEN", "QKC", "SHL", "SOUL", "SPHTX", "SRN", "TOMO", "TRAC", "COV", "DADI", "ELF", "MAN",
     "STK", "ZIL", "ZPT", "BPT", "CAPP", "POLY", "TKY", "TNC", "XRB", "AXP", "COFI", "CXO", "DTA", "ING", "MTN", "OCN", "PARETO", "SNC", "TEL", "WAX", "ADB",
     "BOS", "HAT", "HKN", "HPB", "IOST", "ARY", "DBC", "KEY", "GAT", "RPX", "ACAT", "CV", "DRGN", "LTC", "QLC", "R", "TIO", "ITC", "AGI", "EXY", "MWAT", "DENT",
     "J8T", "LOCI", "CAT", "ACT", "ARN", "BCH", "CAN", "EOS", "ETC", "JNT", "PLAY", "CHP", "DASH", "DNA", "EBTC", "FOTA", "PRL", "PURA", "UTK", "CAG", "GLA",
     "HAV", "SPF", "TIME", "ABT", "BNTY", "ELIX", "ENJ", "AIX", "VEN", "AION", "DAT", "DGB", "SNOV", "BRD", "AMB", "BTM", "MANA", "RHOC", "XLR", "XAS", "CHSB",
     "UKG", "POLL", "FLIXX", "INS", "OMG", "TFL", "WPR", "LEND", "KNC", "BCD", "LA", "ONION", "POWR", "SNM", "BTG", "HSR", "PBL", "MOD", "PPT", "BCPT", "GVT",
     "HST", "SNT", "SUB", "NEBL", "CVC", "MTH", "NULS", "PAY", "RDN", "REQ", "QSP"]
  end
end