class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show update destroy]

  def index
    @products = Product.where(status: 'active').order(created_at: :desc)

    render json: @products
  end

  def show
    render json: @product
  end

  def approval_queue
    @approval = Approval.order(created_at: :asc)
    render json: @approval
  end
 
  def destroy
    @product = Product.find(params[:id])
    @approval = Approval.create(name: @product.name, price: @product.price, status: @product.status)
    @product.destroy
    render json: { message: 'Product was successfully deleted.' }, status: :ok
  end

  def create

      @product = Product.new(product_params)
      if(@product.price > 10000)
        render json: { error: "Price is more than $10,000 limit.Product cant be addded" }, status: :unprocessable_entity
      else
        if product_params["price"]<5000 
          if @product.save
            render json: @product, status: :created, location: @product
          else
            render json: @product.errors, status: :unprocessable_entity
          end
        else
          @approval =Approval.create(product_params)
          if @approval.save
           render json: @approval, status: :created, location: @approval
          else
            render json: @approval.errors, status: :unprocessable_entity
          end
        end
      end
    
  end

  def approve
 
    approval = Approval.find(params[:id])
    approval.update(status: 'approved')
    if approval.update(status: 'approved')
      render json: { message: 'Product approved successfully', approval: approval }, status: :ok
      @approval = Approval.find(params[:id])
      @approval.destroy
    else
      render json: { error: 'Failed to approve product', errors: approval.errors }, status: :unprocessable_entity
    end
   
  end

  def reject
    @approval = Approval.find(params[:id])
    @approval.destroy
    render json: { message: 'Product removed successfully'}, status: :ok
  end
   
  def update
    newprice = product_params[:price]
    newname = product_params[:name]
    newstatus = product_params[:status]
    if @product.present? && newprice > 1.5*@product.price 

      if @product.save
        approval = Approval.create(name: newname, price: newprice, status: newstatus)
        @product.destroy
        render json: { message: "Product price exceeds threshold and has been added to the approval table", product: approval }, status: :ok 
     else
       render json: { error: "Failed to add product to the approval table", errors: approval.errors }, status: :unprocessable_entity
     end

    else
      if @product.update(product_params)
        render json: { message: "Product updated successfully", product: @product }, status: :ok
      else
        render json: { error: "Failed to update product", errors: @product.errors }, status: :unprocessable_entity
      end
    end
  
  end

  def search
    query = params[:query]
    @products = Product.where(nil)
    if query.include?('-') 
      range = query.split('-')
      if range.size == 2
        minprice, maxprice = range.map(&:to_i)
        @products = Product.where(price: minprice..maxprice)
      elsif range.size == 3 
        startdate = Date.parse(range[0])
        enddate = Date.parse(range[1])
        @products = Product.where(created_at: startdate.beginning_of_day..enddate.end_of_day)
      end
    else 
      @products = Product.where(name: query)
    end
    render json: @products
  end

  private

    def set_product
      @product = Product.find(params[:id])

    end

    def product_params
      params.require(:product).permit(:name,:status,:price)
      
    end
end
