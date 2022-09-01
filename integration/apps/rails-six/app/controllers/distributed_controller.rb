class DistributedController < ApplicationController
  def origin
    OpenTracing.start_active_span('origin.span') do |scope|
      span = scope.span
      headers = {}
      OpenTracing.inject(span.context, OpenTracing::FORMAT_RACK, headers)

      conn = Faraday.new('http://app', headers: headers, request: { timeout: 600 })
      response = conn.get('distributed/intermediate')

      render json: { status: response.status }
    end
  end

  def intermediate
    OpenTracing.start_active_span('intermediate.span') do |scope|
      span = scope.span
      headers = {}
      OpenTracing.inject(span.context, OpenTracing::FORMAT_RACK, headers)

      conn = Faraday.new('http://app', headers: headers, request: { timeout: 600 })
      response = conn.get('distributed/destination')

      render json: { status: response.status }
    end
  end

  def destination
    OpenTracing.start_active_span('destination.span') do |scope|
      span = scope.span
      headers = {}
      OpenTracing.inject(span.context, OpenTracing::FORMAT_RACK, headers)

      render json: { status: 200 }
    end
  end
end
