class GreetingsController < ApplicationController
  def hello
    list_coin = params[:list_coins] ? params[:list_coins].split(",").map{|a| a.upcase} : nil
    money = params[:money] ? params[:money].to_i : nil
    klass_name = params[:exchange] || "Bibox"
    bi_box = klass_name.constantize.new(money, list_coin)
    bi_box.fetch_good_trade
    @result = bi_box.log
  end
end
