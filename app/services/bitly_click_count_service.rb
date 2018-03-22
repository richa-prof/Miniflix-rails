class BitlyClickCountService

  def initialize(url)
    @url = url
  end

  def call
    fetch_click_count(@url)
  end

  private

  def fetch_click_count(url)
    response_body = request_to_bitly(url)
    if(response_body["status_code"]==200)
      response_body["data"]["referring_domains"]
    else
      #if returing nil then its error on API
      return nil
    end
  end

  def request_to_bitly(url)
    response = open(bitly_link_count_url(url))
    JSON.parse(response.read)
  end

  def bitly_link_count_url(url)
    "https://api-ssl.bitly.com/v3/link/referring_domains?access_token=#{ENV['Bitly_access_token']}&link=#{url}"
  end

end
