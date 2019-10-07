class ItemsController < ApplicationController
  require 'payjp'

  def index
  end

  def new
    @item = Item.new
    10.times {@item.images.build}
  end

  def create
    @item = Item.new(item_params)

    # usrは仮置き userログイン機能実装後は削除
    @item.user_id = 1

    if @item.save
      redirect_to root_path
    else
      10.times {@item.images.build}
      render :new
    end
  end

  def show
  end

  def edit
  end

  def destroy
  end

  def purchase
    @item = Item.find(params[:id])
  end
  
  def buy
    # userが登録機能がついたらコメントアウトの方に切り替え
    card = Card.where(user_id: 1).first
    # card = current_user.credit_card
    if card.blank?
      redirect_to new_card_path
      flash[:alert] = '購入にはクレジットカード登録が必要です'
    else
      @item = Item.find(params[:id])


      Payjp.api_key = Rails.application.credentials.PAYJP_PRIVATE_KEY
      Payjp::Charge.create(
      amount: @item.price,
      customer: card.customer_id,
      currency: 'jpy',
      )

      # userが登録機能がついたらコメントアウトの方に切り替え
      if @item.update(status: 1, buyer_id: 1)
      # if @item.update(status: 1, buyer_id: current_user.id)
        flash[:notice] = '購入しました。'
        redirect_to controller: "items", action: 'show'
      else
        flash[:alert] = '購入に失敗しました。'
        redirect_to controller: "items", action: 'show'
      end
    end
  end

  private

  def item_params
    params.require(:item).permit(
      :name, 
      :text, 
      :size_id, 
      :category_id, 
      :damage, 
      :postage_side, 
      :prefecture_id, 
      :delivery_method, 
      :arrival, 
      :price, 
      images_attributes: [
        :name
      ]
    )

    # userログイン機能実装後は下記に変更予定
    # params.require(:item).permit(
    #   :name, 
    #   :text, 
    #   :size_id, 
    #   :category_id, 
    #   :damage, 
    #   :postage_side, 
    #   :prefecture_id, 
    #   :delivery_method, 
    #   :arrival, 
    #   :price, 
    #   images_attributes: [
    #     :name
    #   ]
    # ).merge(user_id: current_user.id)
  end

  
end
