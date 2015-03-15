module ValidationHelper
#Include this file on a page that performs validation checks
#if you want to use these functions.

  def valid_alphanum?(*input_data)
      for input in input_data
          if !(!!input.to_s.match(/^[A-Za-z0-9]/) || (true if Float(input) rescue false)) then
              return false
          end
      end
      return true
  end

  def valid_email?(email_string)
    return !!(email_string.match(/\w(.?)+\w+(@)\w(.?)\w(.)+[a-z]/))
  end

  def is_checked?(checkbox_element)
    return !checkbox_element.nil?
  end

end