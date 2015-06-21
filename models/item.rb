class Item
  attr_accessor :seller_id, :buyer_id, :price, :image, :name, :description, :locker_id, :city, :sold
  def initialize( seller_id, locker_id, city, name, description, price, image="", buyer_id="", sold=false)
    @seller_id = seller_id
    @locker_id = locker_id
    @city = city
    @name = name
    @description = description
    @price = price
    @image = image
    @buyer_id = buyer_id
    @sold = sold
  end
end
