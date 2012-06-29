class Home::DashboardController < Home::HomeController
  
  def index
    @clicks_given = {}
    current_user.clicks.order("created_at DESC").each do |click|
      button = Button.find(click.button_id)
      row = [
        click.created_at,
        button.user.email,
        click.referrer.blank? ? "None" : click.referrer
        ]
      @clicks_given[click.uuid] = row
    end
    
    puts @clicks_given.inspect
    
    @clicks_received = []
    
    button_ids = []
    current_user.buttons.each {|button| button_ids.push(button.id)}
    
    Click.find(:all, :conditions => {:button_id => button_ids}, :order => "created_at DESC").each do |click|
      row = [
        click.created_at,
        click.user.email,
        click.referrer.blank? ? "None" : click.referrer
        ]
      @clicks_received.push(row)
    end
  end
  
  def delete_click
    current_user.clicks.find_by_uuid(params[:click_id]).destroy
    render :nothing => true
  end
  
end
