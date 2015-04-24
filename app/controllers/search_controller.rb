class SearchController < ApplicationController
  include DetermineUserAndUnits

  layout "application_fluid"

  def index
    data = params[:search_text].downcase

    stripped= data.split(" ")
    stripped -= %w{for and nor but or yet so either not only may neither both whether just as much rather why the is a this then than them their}
    stripped = stripped.join(" ")

    @result = Array.new()
    r = Regexp.new(Regexp.escape(data.downcase))

    unless(stripped.empty?)
      Question.find_each do |question|
        unless (r.match(question.label.downcase).to_s.empty?)
          @result << question
        end
      end
    end

    if(@result.empty?)
      flash[:notice] = "Nothing matched your search."
    end
  end
end
