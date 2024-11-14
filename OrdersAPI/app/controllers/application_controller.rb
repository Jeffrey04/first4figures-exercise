require "base64"
require "jwt"

class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    token = request.headers["Authorization"]

    unless valid_token?(token)
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def valid_token?(token)
    # Hardcoded token for this exercise
    # parts:
    #   {"alg":"HS256","typ":"JWT"}
    #   {"name":"Jeffrey04"}
    #   HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), "hello")
    #token == "Bearer eyJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiamVmZnJleTA0In0.gg9FblqVWREIVP4Dc34aUDTRP9fcx7IZBy8ifBKW3us"
    begin
      payload, _header = JWT.decode(token.split(" ")[-1], "hello", true, { algorithm: "HS256" })

      payload["name"] == "jeffrey04"
    rescue => _e
      false
    end
  end
end
