class SubmitQuestionsController < ApplicationController
  include ValidationHelper
  
 #  def send_question submit_question_data		
 #    current_user.subscribed_to_blog = submit_question_data.wants_subscription
 #    current_user.save!
	# 	UserMailer.submit_question_email(
 #      current_user,
 #      submit_question_data
 #    ).deliver!
	# 	redirect_to(request.referer)
	# 	return flash[:notice] = 'Thanks for your submission!'
	# end

  def create
    new_submission = SubmitQuestion.create!(
      :title => params[:submit_question_name],
      :category => params[:submit_question_category],
      :answer_type => params[:submit_question_answer_type],
      :answers => params[:answer_box_1],
      :wants_subscription => is_checked?(params[:checkbox_subscribe]),
      :user_id => current_user.id
    )      
    if new_submission.save
      redirect_to 'categories/new_submission[:category]'
    
    end

  end

  def show
    @question = SubmitQuestion.find(params[:category])
    

  end

  
end
