require 'rho/rhocontroller'
require 'helpers/browser_helper'

class FacebookConnectController < Rho::RhoController
  include BrowserHelper

  # GET /FacebookConnect
  def index
    @facebookconnects = FacebookConnect.find(:all)
    render :back => '/app'
  end

  # GET /FacebookConnect/{1}
  def show
    @facebookconnect = FacebookConnect.find(@params['id'])
    if @facebookconnect
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /FacebookConnect/new
  def new
    @facebookconnect = FacebookConnect.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /FacebookConnect/{1}/edit
  def edit
    @facebookconnect = FacebookConnect.find(@params['id'])
    if @facebookconnect
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /FacebookConnect/create
  def create
    @facebookconnect = FacebookConnect.create(@params['facebookconnect'])
    redirect :action => :index
  end

  # POST /FacebookConnect/{1}/update
  def update
    @facebookconnect = FacebookConnect.find(@params['id'])
    @facebookconnect.update_attributes(@params['facebookconnect']) if @facebookconnect
    redirect :action => :index
  end

  # POST /FacebookConnect/{1}/delete
  def delete
    @facebookconnect = FacebookConnect.find(@params['id'])
    @facebookconnect.destroy if @facebookconnect
    redirect :action => :index  
  end

    #Originals
    # FB_API_ID = "121263761311760" 
    # FB_API_SECRET = "4eb7f3fa2cb42737d0a8b26b4fc5abf9"

    #Mine
    FB_API_ID = "270954766406717" 
    FB_API_SECRET = "6d33c89c1fa87aa64bb7cf005a8450ba"
    
    FB_AUTH_URL = "https://www.facebook.com/dialog/oauth"
    FB_GRAPH_URL = "https://graph.facebook.com"
    
    RHOMOBILE_FB_ID = "56638045891"
    
    RedirectServiceURL = "http://redirectme.to"

    token = nil
    
    def self.getRedirectURL(local_call_back_url)
      callback_url = RedirectServiceURL + "/" + '127.0.0.1:' + System.get_property('rhodes_port').to_s + local_call_back_url 
      return callback_url
    end
    
    def self.getFBAuthURL(local_call_back_url)
      call_back_url = getRedirectURL(local_call_back_url)
      #call_back_url goes unencoded since Facebook requires it to be like that, hence it goes at the end of the request
      url = "#{FB_AUTH_URL}?display=touch&client_id=#{FB_API_ID}&scope=user_likes&redirect_uri=#{call_back_url}"
      #url = "#{FB_AUTH_URL}?client_id=#{FB_API_ID}&scope=user_likes&redirect_uri=#{call_back_url}"
      return url
    end

    def self.getFBTokenURL(code, previous_call_back)
      call_back_url = getRedirectURL(previous_call_back) #This is not going to be called by facebook, it is just to certify you have access to the token by providing the SAME URL that was given when requesting the token
      #call_back_url goes unencoded since Facebook requires it to be like that, hence it goes at the end of the request
      url = "#{FB_GRAPH_URL}/oauth/access_token?client_id=#{FB_API_ID}&client_secret=#{FB_API_SECRET}&code=#{code}&redirect_uri=#{call_back_url}"
      return url
    end
      
    def self.getFBCheckLikeURL(token)
      # url = "#{FB_GRAPH_URL}/me/likes/#{RHOMOBILE_FB_ID}?access_token=#{token}"
      url = "#{FB_GRAPH_URL}/me?fields=name,picture&access_token=#{token}"
      return url
    end
    
    def index
      
    end

    def logout
      token = nil
     
      redirect :action => :index
    end
    
    def nothing
      
      return "{ }" #Empty json 
    end
    
    def connect_to_facebook
      local_callback_url = url_for(:action => :facebook_callback)
      url = FacebookConnectController.getFBAuthURL(local_callback_url)
      
      WebView.navigate(url)
    end
    
    def facebook_callback
      #This is to achieve the effect of the "connecting" page
      token_result = Rho::AsyncHttp.get(
      :url => 'http://127.0.0.1:' + System.get_property('rhodes_port').to_s + url_for(:action => :facebook_check, :query => {'code' => @params['code']}),
        :callback => url_for(:action => :nothing)
      )
      
      redirect :action => :connecting
    end
    
    def connecting
      
    end
    
    def facebook_check
      code = @params['code']
      
      token_url = FacebookConnectController.getFBTokenURL(code, url_for(:action => :facebook_callback))

      #Since the "connecting" view is being displayed, we do the calls synchronously      
      token_result = Rho::AsyncHttp.get(
        :url => token_url
      )
      
      if token_result['status'] == "ok"
        token = token_result['body'].split('&')[0].split('=')[1]
        likes_url = FacebookConnectController.getFBCheckLikeURL(token)
        likes_result = Rho::AsyncHttp.get(
          :url => likes_url
        )
        if likes_result['status'] == "ok"
          likes_data = Rho::JSON.parse(likes_result['body'])
          # Alert.show_popup( { 
          #             :message =>  likes_data['picture']['data']['url'],
          #             :title => 'Error contacting Facebook',
          #             :icon => :error,
          #             :buttons => ["OK"] } )

          WebView.navigate(url_for :action => :facebook_check_callback, :query => {'name' => likes_data['name'], 'pic' => likes_data['picture']['data']['url']})
          return
        end
      end

        
      Alert.show_popup( { 
                  :message =>  likes_result['body'],
                  :title => 'Error contacting Facebook',
                  :icon => :error,
                  :buttons => ["OK"] } )
      WebView.navigate ( url_for :action => :index )
    end
    
    def facebook_check_callback
      @name = nil
      @name = @params['name'].to_s

      @pic = nil
      pic_url = @params['pic'].to_s
      pic_url = pic_url.gsub("%2F", "/" )
      pic_url = pic_url.gsub("%3A", ":" )

      @pic = pic_url
      # if @params['likes'].to_s == 'true'
      #   @message = "You really like Rhomobile! Rock on!"
      # else
      #   @message = "You don't like Rhomobile! Why?"
      # end
    end
    

end
