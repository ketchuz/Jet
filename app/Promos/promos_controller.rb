require 'rho/rhocontroller'
require 'helpers/browser_helper'

class PromosController < Rho::RhoController
  include BrowserHelper

  def asynchttp
     Rho::AsyncHttp.get(
      :url => 'http://radiant-wildwood-5057.herokuapp.com/promos.json',
      # :headers  => {"Content-Type" => "application/json"},  
      :callback => (url_for :action => :httpget_callback),
      :callback_param => "" )   

     redirect :action => :viewhttp
  end

  def httpget_callback
    $httpresult = @params['body']
    $jsonresult = Rho::JSON.parse($httpresult)

    Promos.delete_all()

    $jsonresult.each do |promo| 
      myPromo = Promos.new
      myPromo.title = promo['title']
      myPromo.description = promo['description']
      myPromo.save
    end

    # $jsonresult.each do |promo|
    #   myPromo = Promos.new
    #   myPromo.title = promo.title
    #   myPromo.description = promo.description
    #   myPromo.save
    # end

    WebView.refresh
  end

  # GET /Promos
  def index
    @promoses = Promos.find(:all)
    render :back => '/app'
  end

  # GET /Promos/{1}
  def show
    @promos = Promos.find(@params['id'])
    if @promos
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Promos/new
  def new
    @promos = Promos.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Promos/{1}/edit
  def edit
    @promos = Promos.find(@params['id'])
    if @promos
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Promos/create
  def create
    @promos = Promos.create(@params['promos'])
    redirect :action => :index
  end

  # POST /Promos/{1}/update
  def update
    @promos = Promos.find(@params['id'])
    @promos.update_attributes(@params['promos']) if @promos
    redirect :action => :index
  end

  # POST /Promos/{1}/delete
  def delete
    @promos = Promos.find(@params['id'])
    @promos.destroy if @promos
    redirect :action => :index  
  end
end
