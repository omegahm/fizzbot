require 'faraday'
require 'json'

BASE_URL = 'https://api.noopschallenge.com'

def fizzbuzz(numbers, rules = [{ number: 3, response: 'Fizz' }, { number: 5, response: 'Buzz' }])
  numbers.map do |num|
    responses = rules.select do |rule|
      num % rule['number'] == 0
    end

    if responses.empty?
      num
    else
      responses.map { |r| r['response'] }.join
    end
  end.join(' ')
end

conn = Faraday.new(url: BASE_URL)
res = conn.post('/fizzbot/questions/1') do |req|
  req.headers['Content-Type'] = 'application/json'
  req.body = '{ "answer": "Ruby" }'
end

while url = JSON.parse(res.body)['nextQuestion']
  res = conn.get(url)
  json = JSON.parse(res.body)
  res = conn.post(url) do |req|
    req.headers['Content-Type'] = 'application/json'
    req.body = { answer: fizzbuzz(json['numbers'], json['rules']) }.to_json
  end
end

JSON.parse(res.body).each do |key, value|
  puts "#{key.capitalize}: #{value}"
end
