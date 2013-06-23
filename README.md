# CraigslistScraper

A gem to scrape craiglist data , use at own risk.  

####Warning

This gem does not work if hosted on heroku or ec2 , it appears [craiglist blocks requests coming from them.](http://stackoverflow.com/questions/14328955/http-get-on-craigslist-blocked)

## Installation

Add this line to your application's Gemfile:

    gem 'craigslist_scraper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install craigslist_scraper

## Usage

### search example
    
    craigslist = CraigsList.new
    craigslist.search_boulder_for "vegan flip flops"

> defaults to searching the entire post
> you can also search in just the titles

`craigslist.search_titles_in_denver_for "vegan flip flops"`

#### returns

     [{
        data_id: "314159265359",
        decsription: "vegan flip flops made out of tofu",
        url: "http://denver.craigslist.org/42.html,
        price: 5
     }]      

### Data calculations
#### average price

    craigslist = CraigsList.new
    craigslist.search_miami_for "white aligator shoes".average_price #=> 200

#### median price

    craigslist = CraigsList.new
    craigslist.search_miami_for "white aligator shoes".median_price #=> 200

### You can search most valid craigslist cities
#### example
    craigslist.search_dallas_for "a NoBama bumper sticker"

    craigslist.search_lasvegas_for "gold chains and workout jumpsuit"


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Make sure all tests pass
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

