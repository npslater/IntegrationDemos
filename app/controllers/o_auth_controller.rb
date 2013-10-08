class OAuthController < ApplicationController

  def redirect_google
    self.render nothing: true, status: 200
  end

end