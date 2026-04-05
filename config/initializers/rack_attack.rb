class Rack::Attack
  # Let localhost through unconditionally
  safelist('allow-localhost') do |req|
    req.ip == '127.0.0.1' || req.ip == '::1'
  end

  # General request throttle: 300 requests per 5 minutes per IP
  throttle('req/ip', limit: 120, period: 2.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  # Login throttle by IP: 5 attempts per 20 seconds
  throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/session' && req.post?
  end

  # Login throttle by email (credential stuffing protection):
  # 5 attempts per email per minute
  throttle('logins/email', limit: 5, period: 60.seconds) do |req|
    if req.path == '/session' && req.post?
      req.params.dig('email_address')&.downcase&.strip
    end
  end
end
