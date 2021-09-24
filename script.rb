require 'net/http'
require 'uri'
require 'json'
require 'csv'
require './constants.rb'

def make_call(url, method, type, update_amount="")
  
  uri = URI(url)

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  
  if method == "post"
    request = Net::HTTP::Post.new(uri)
  end
  if method == "get"
    request = Net::HTTP::Get.new(uri)
  end
  if method == "patch"
    request = Net::HTTP::Patch.new(uri)
    request.body = "{\r\n  \"category\": {\r\n    \"budgeted\": " + update_amount.to_s + "\r\n  }\r\n}"
  end
  if type == "dropbox"
    request["Dropbox-API-Arg"] = "{\"path\": \"" + DROPBOX_PATH  + "\"}"
    request["Authorization"] = "Bearer " + DROPBOX_TOKEN
    request["Content-Type"] = "text/plain"
  end
  if type == "ynab"
    request["Authorization"] = "Bearer " + YNAB_TOKEN
    request["Content-Type"] = "application/json"
  end

  https.request(request)
end

response = make_call(DROPBOX_URL, "post", "dropbox")
csv =  response.read_body
days = CSV.parse(csv, headers: true)
streak = 0
last_entry_type = ""
days.each do |day|
  last_entry_type = day["entry_type"]
  if day["entry_type"].include? "completed"
    streak += 1
  else
    streak = 0
  end
end
if last_entry_type.include? "completed"
  streak += 1
end



#get budget
budget_response = make_call("https://api.youneedabudget.com/v1/budgets", "get", "ynab")
budget_response = budget_response.read_body
budget_json = JSON.parse(budget_response)
budget_id =  budget_json["data"]["budgets"][0]["id"]

#get category
category_id = ""
spent_amount = 0
category_response = make_call("https://api.youneedabudget.com/v1/budgets/" + budget_id  +  "/categories", "get", "ynab")
category_response = category_response.read_body
category_json = JSON.parse(category_response)
category_json["data"]["category_groups"].each do |group|
  group["categories"].each do |category|
    if category["name"].include? YNAB_CATEGORY_NAME
      spent_amount =  category["activity"] * -1
      category_id = category["id"]
    end
  end
end

#update category
budget_month =  Date.today.strftime("%Y-%m-01")
update_url = "https://api.youneedabudget.com/v1/budgets/" + budget_id  + "/months/" + budget_month  + "/categories/" + category_id
update_amount = streak * (DOLLARS_PER_DAY * 1000)
if update_amount > spent_amount
  make_call(update_url, "patch", "ynab", update_amount)
else
  make_call(update_url, "patch", "ynab", spent_amount)
end



