module ApplicationHelper

  #Enables the Devise signup form
  def resource_name
    :user
  end

  def resource
    @resource ||=User.new
  end

  def devise_mapping
    @devise_mapping ||=Devise.mappings[:user]
  end

  #used to fetch total questions in footer  
  def all_answers_submitted
    db_connection = ActiveRecord::Base.connection
    #each date corresponds to an answer
    total_answers = db_connection.execute("SELECT COUNT(DISTINCT created_at) FROM answers")
    total_answers.values()[0][0].to_i
  end
  
  def full_title(page_title)
    # Shout out M.Hartl for reference
    base_title = "Arima"
    page_title.empty? ? base_title : "#{base_title} | #{page_title}"
  end

end
