require 'rest-client'
require 'json'

class ElecardTest
  attr_accessor :tasks, :result

  def initialize
    @result = []

    get_tasks
    do_tests
  end

  private

  def get_tasks
    @tasks = request(method: 'GetTasks', request_obj: {})
  end

  def do_tests
    tasks.each do |circles|
      x_max = circles.max_by { |circle| circle['x'] + circle['radius'] }
      x_min = circles.min_by { |circle| circle['x'] - circle['radius'] }

      y_max = circles.max_by { |circle| circle['y'] + circle['radius'] }
      y_min = circles.min_by { |circle| circle['y'] - circle['radius'] }

      result << {
        left_bottom: {
          x: x_min['x'] - x_min['radius'],
          y: y_min['y'] - y_min['radius']
        },
        right_top: {
          x: x_max['x'] + x_max['radius'],
          y: y_max['y'] + y_max['radius']
        }
      }
    end

    response = request(method: 'CheckResults', request_obj: result)

    response.each_with_index do |answer, index|
      puts %(Test №#{index}, result is #{answer})
    end
  end

  def url
    'http://93.91.165.233:8081/api'
  end

  def key
    'bFaDsFFCQnvbZhvP7lSMCBO8uJoxo+X2mLK7/BcZsbaElCafqmx2lzvjO62PePQ6dyoNsnE2D83BAjGjz4TXRQ=='
  end

  def request(method:, request_obj:)
    params = { key: key, method: method, params: request_obj }.to_json

    JSON.parse(RestClient.post(url, params, { content_type: :json, accept: :json }).body)['result']
  end
end

ElecardTest.new
