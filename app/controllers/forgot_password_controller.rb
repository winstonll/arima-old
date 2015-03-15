class ForgotPasswordController < ApplicationController
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.forgot_password_email
      redirect_to root_path, :notice => "Email sent with password reset instructions."
    else
      redirect_to forgot_password_index_path, :notice => "Email cannot be found."
    end
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.update_attributes(user_params)
      redirect_to root_url, :notice => "Password has been reset!"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password)
  end

end
