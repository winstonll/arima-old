class SearchController < ApplicationController
  include DetermineUserAndUnits

  layout "application_fluid"

  def index
    if(cookies[:guest] == nil)
      check_guest()
    end

    data = params[:search_text].downcase

    stripped= data.split(" ")
    stripped -= %w{for and nor but or yet so either not only may neither both whether just as much rather why the is a this then than them their}
    stripped = stripped.join(" ")

    @all = Array.new()
    r = Regexp.new(Regexp.escape(data.downcase))

    unless(stripped.empty?)
      Question.find_each do |question|
        unless (r.match(question.label.downcase).to_s.empty?)
          @all << question
        end
      end
    end

    if (user_signed_in?)
      @answered         = @all & current_user.questions
      @unanswered       = @all - @answered
    else
      @guest            = User.where(id: cookies[:guest]).first
      @answered         = @all & @guest.questions
      @unanswered       = @all - @answered
    end

    if(@all.empty?)
      flash[:notice] = "Nothing matched your search."
    end
  end
end
