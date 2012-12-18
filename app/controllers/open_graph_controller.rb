class OpenGraphController < ApplicationController
  layout false
  
  def note
    @comment = Comment.find_by_uuid_ci(params[:uuid])
    raise ActionController::RoutingError.new('Not Found') if @comment.nil?
    redirect_to @comment.url.url unless request_is_facebook?
  end
  
  def webpage
    @url = Url.find_by_uuid_ci(params[:uuid])
    raise ActionController::RoutingError.new('Not Found') if @url.nil?
    redirect_to @url.url unless request_is_facebook?
  end
  
  private
  
  def request_is_facebook?
    user_agent = request.env['HTTP_USER_AGENT']
    user_agent and user_agent.start_with?('facebookexternalhit/')
  end
  
end
