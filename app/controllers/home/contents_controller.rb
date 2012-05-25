class Home::ContentsController < Home::HomeController
  
  def index
    @contents = self.current_user.contents
  end
  
  def new
    @content = self.current_user.contents.build
  end
  
  def create
    @content = self.current_user.contents.build(params[:content])
    if @content.save
      redirect_to home_contents_path
    else
      render :new
    end
  end
  
  def show
    @content = self.current_user.contents.find_by_uuid(params[:id])
  end
  
  def edit
    @content = self.current_user.contents.find_by_uuid(params[:id])
  end
  
  def update
    @content = self.current_user.contents.find_by_uuid(params[:id])
    if @content.update_attributes(params[:content])
      redirect_to home_content_path(@content)
    else
      render :edit
    end
  end
  
end