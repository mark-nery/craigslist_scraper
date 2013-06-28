require 'craigslist_scraper/craigslist'

describe CraigsList do
  let!(:craigslist) { CraigsList.new }
  
  describe ".search" do
    before { craigslist.stub(:open).and_return(File.read(File.dirname(__FILE__) + '/mock_craigslist_data.html')) }
    
    it "returns an array with all the items" do
      craigslist.search.length.should == 100
      craigslist.search[0].keys.should == [:data_id, :description, :url, :price]
    end
	
    it "has the right keys " do
      craigslist.search[0].keys.should == [:data_id, :description, :url, :price]
    end
	
    it "addes '+' to white space in queries" do
      craigslist.should_receive(:open).with("http://denver.craigslist.org/search/sss?query=iphone+5")
      
      craigslist.search(city: "denver" , query: "iphone 5")
    end
    
    it "adds title only filter to url" do
      craigslist.should_receive(:open).with("http://denver.craigslist.org/search/sss?query=iphone+5&srchType=T")
      craigslist.search(city: "denver" , query: "iphone 5" , title_only: true)
    end
	  
    it "doesn't filter when title only is false" do
      craigslist.should_receive(:open).with("http://denver.craigslist.org/search/sss?query=iphone+5")
      craigslist.search(city: "denver" , query: "iphone 5" , title_only: false )
    end
    
    it "exracts the price" do
      craigslist.search[0][:price].should == "70"
    end
    
    it "builds the correct reference url" do
      city = "shanghai"
      craigslist.search(city: city)[0][:url].should == "http://#{city}.craigslist.org/mob/3849318365.html"
    end

    it "returns [error: {}] if OpenURI::HTTPError is thrown" do
      exception_io = mock('io')
      exception_io.stub_chain(:status,:[]).with(0).and_return('302')          
      craigslist.stub(:open).with(anything).and_raise(OpenURI::HTTPError.new('',exception_io))

      craigslist.search(city: "somewhere").should ==  [{error: "error opening city: somewhere"} ]
    end
  end

  describe "dynamic method search_{cityname}_for" do
    it "calls search for a valid city" do
      CraigsList::CITIES.each do |city|
        craigslist.should_receive(:search).with(city: city , query: nil)
        
        craigslist.send("search_#{city}_for")
      end
    end
    
    it "doesn't call search for an invalid city" do
      expect { craigslist.search_yourmamaville_for }.to raise_error(NoMethodError)
    end

    it "passes a query" do
      craigslist.should_receive(:search).with(city: "dallas", query: "cowboy hats")
      
      craigslist.search_dallas_for("cowboy hats")
    end
  end

  
  describe "dynamic method search_titles_in_{cityname}_for" do
    
    it "calls search for a valid city" do
      CraigsList::CITIES.each do |city|
        craigslist.should_receive(:search).with(city: city , query: nil , title_only: true)
        
        craigslist.send("search_titles_in_#{city}_for")
      end
    end
    
    it "doesn't call search for an invalid city" do
      expect { craigslist.search_titles_in_yourmamaville_for }.to raise_error(NoMethodError)
    end
  end

  describe "Array#average_price" do

    it "returns the average price for a search with multiple items" do
      craigslist.stub(:search_denver_for).and_return([{price: "3"} , {price: "5"} , {price: "7"}])

      craigslist.search_denver_for("uranium").average_price.should == 5
    end

    it "returns 0 for search with no results" do
      craigslist.stub(:search_denver_for).and_return([])

      craigslist.search_denver_for("uranium").average_price.should == 0
    end

    it "returns average for a search with two items" do
      craigslist.stub(:search_denver_for).and_return([{price: "8"} , {price: "12"} ])

      craigslist.search_denver_for("uranium").average_price.should == 10
    end

    it "returns the price for a search with one item" do
      craigslist.stub(:search_denver_for).and_return([{price: 1}])

      craigslist.search_denver_for("uranium").average_price.should == 1
    end

    it "discards nil prices" do
      craigslist.stub(:search_denver_for).and_return([{price: 1} , {price: nil}])

      craigslist.search_denver_for("uranium").average_price.should == 1
    end

    

  end
  describe "Array#median_price" do

    it "returns the median price for a search with multiple items" do
      craigslist.stub(:search_denver_for).and_return([{price: "1"} , {price: "1000"} , {price: "5"}])
      craigslist.search_denver_for("uranium").median_price.should == 5
    end

    it "returns 0 for search with no results" do
      craigslist.stub(:search_denver_for).and_return([])
         craigslist.search_denver_for("uranium").median_price.should == 0
    end
   
    it "returns median for a search with two items" do
      craigslist.stub(:search_denver_for).and_return([{price: "8"} , {price: "12"} ])
   
      craigslist.search_denver_for("uranium").median_price.should == 10
    end

    it "returns the price for a search with one item" do
      craigslist.stub(:search_denver_for).and_return([{price: 1}])
   
      craigslist.search_denver_for("uranium").median_price.should == 1
    end

    it "returns the average of the two middle numbers for an even array" do
      craigslist.stub(:search_denver_for).and_return([{price: "1"} , {price: "5"} , {price: "15"} , {price: "10000"}])
      craigslist.search_denver_for("uranium").median_price.should == 10
    end
    
    it "discards nil prices" do
      craigslist.stub(:search_denver_for).and_return([{price: 1} , {price: nil}])
   
      craigslist.search_denver_for("uranium").median_price.should == 1
    end
  end

  describe ".search_all_cities_for" do
    
    it "returns [] for cities with no search results" do
      craigslist.stub(:search).with(city: "denver" , query:"something cool" ).and_return([])
      craigslist.stub(:search).with(city: "boulder", query:"something cool" ).and_return([])
      stub_const("Cities::CITIES",["denver","boulder"])
      
      craigslist.search_all_cities_for("something cool").should == []
    end

    it "returns concatenated items for cities with  search results" do
      craigslist.stub(:search).with(city: "denver" , query:"something cool" ).and_return([{in_denver: "something in denver"}])
      craigslist.stub(:search).with(city: "boulder", query:"something cool" ).and_return([{in_boulder: "something in boulder"}])
      stub_const("Cities::CITIES",["denver","boulder"])
      
      craigslist.search_all_cities_for("something cool").should == [{in_denver: "something in denver"}, {in_boulder: "something in boulder"}]
    end

  end
end

