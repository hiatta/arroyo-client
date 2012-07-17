describe Arroyo::Client do
  describe 'spellcheck' do
    it 'gets spellchecking for a natural language query' do
      stub_faraday do |stub|
        stub.get('/nlpapi/products/spellcheck?query=burts%20bees') { response(total: 1, entities: [{ correction: "burt's bees", corrected: true }] ) }
      end
      matches = GoodGuide::NlpApi.spellcheck(:products, query: "burts bees")
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }
      matches.size.should == 1
            
      stub_faraday do |stub|
        stub.get('/nlpapi/companies/spellcheck?query=appl') { response(total: 1, entities: [{ correction: "apple", corrected: true }] ) }
      end
      matches = GoodGuide::NlpApi.spellcheck(:companies, query: "appl")
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }      
      matches.size.should == 1
            
      stub_faraday do |stub|
        stub.get('/nlpapi/ingredients/spellcheck?query=appl') { response(total: 1, entities: [{ correction: "apple", corrected: true }] ) }
      end
      matches = GoodGuide::NlpApi.spellcheck(:ingredients, query: "appl")
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }            
      matches.size.should == 1

      stub_faraday do |stub|
        stub.get('/nlpapi/ingredients/spellcheck?query=adsfasdfsafsadsdaf') { response(total: 0, entities: [{ corrected: false }] ) }
      end
      matches = GoodGuide::NlpApi.spellcheck(:ingredients, query: "adsfasdfsafsadsdaf")
      matches.size.should == 0
    end
  end


  describe 'morelikethis' do
    it 'gets morelikethis suggestions for a natural language query' do    
      stub_faraday do |stub|
        stub.get("/nlpapi/products/morelikethis?query=Kellogg's%20Mueslix%20Cereal&rows=1") { response(total: 1, entities: [{ name: "Kellogg's Mueslix Cereal", company: "Kellogg Company" }] ) }
      end
      matches = GoodGuide::NlpApi.morelikethis(:products, query: "Kellogg's Mueslix Cereal", rows: 1)            
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }      
      matches.size.should == 1

      stub_faraday do |stub|
        stub.get('/nlpapi/companies/morelikethis?query=apple&rows=1') { response(total: 1, entities: [{ name: "Apple Inc.", brands: ["Apple Computer"] }] ) }
      end
      matches = GoodGuide::NlpApi.morelikethis(:companies, query: "apple", rows: 1)            
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }      
      matches.size.should == 1

      stub_faraday do |stub|
        stub.get('/nlpapi/ingredients/morelikethis?query=apple&rows=1') { response(total: 1, entities: [{ name: "apple"}] ) }
      end
      matches = GoodGuide::NlpApi.morelikethis(:ingredients, query: "apple", rows: 1)            
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }      
      matches.size.should == 1
            
      stub_faraday do |stub|
        stub.get('/nlpapi/ingredients/morelikethis?query=adsfasdfsafsadsdaf') { response(total: 0, entities: [{ corrected: false }] ) }
      end
      matches = GoodGuide::NlpApi.morelikethis(:ingredients, query: "adsfasdfsafsadsdaf")
      matches.size.should == 0
    end
  end

  describe 'search' do
    it 'gets search results for a natural language query' do    
      stub_faraday do |stub|
        stub.get("/nlpapi/products/search?query=Kellogg's%20Mueslix%20Cereal&rows=1") { response(total: 1, entities: [{ name: "Kellogg's Mueslix Cereal", company: "Kellogg Company" }] ) }
      end
      matches = GoodGuide::NlpApi.search(:products, query: "Kellogg's Mueslix Cereal", rows: 1)            
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }      
      matches.size.should == 1


      stub_faraday do |stub|
        stub.get('/nlpapi/companies/search?query=apple&rows=1') { response(total: 1, entities: [{ name: "Apple Inc.", brands: ["Apple Computer"] }] ) }
      end
      matches = GoodGuide::NlpApi.search(:companies, query: "apple", rows: 1)            
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }      
      matches.size.should == 1

      stub_faraday do |stub|
        stub.get('/nlpapi/ingredients/search?query=apple&rows=1') { response(total: 1, entities: [{ name: "apple"}] ) }
      end
      matches = GoodGuide::NlpApi.search(:ingredients, query: "apple", rows: 1)            
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }      
      matches.size.should == 1
            
      stub_faraday do |stub|
        stub.get('/nlpapi/ingredients/search?query=adsfasdfsafsadsdaf') { response(total: 0, entities: [{ corrected: false }] ) }
      end
      matches = GoodGuide::NlpApi.search(:ingredients, query: "adsfasdfsafsadsdaf")
      matches.size.should == 0
    end

    it 'gets search results for a grouped query' do
      stub_faraday do |stub|
        stub.get("/nlpapi/products/search?query=shampoo&facet=true&result_grouping=brand_id") do
          response total: 1,
            entities: { 123 => [
              { name: 'Agree Shampoo, Normal Hair', id: 126331, root_rating: 5 },
              { name: 'Weleda Calendula Phyto Shampoo', id: 178692, root_rating: 7}
            ]}
        end
      end
      matches = GoodGuide::NlpApi.search(:products, query: "shampoo", facet: true, result_grouping: 'brand_id')
      matches.size.should == 1
      group_match = matches.first
      group_match.group_type.should == 'Brand'
      group_match.id.should == '123'
      group_match.matches.size.should == 2
    end
  end
  
  describe 'match' do
    it 'gets duplicate match results for a natural language query' do    
      stub_faraday do |stub|
        stub.get("/nlpapi/products/match?query=Kellogg's%20Mueslix%20Cereal&rows=1") { response(total: 1, entities: [{ name: "Kellogg's Mueslix Cereal", company: "Kellogg Company" }] ) }
      end
      matches = GoodGuide::NlpApi.match(:products, query: "Kellogg's Mueslix Cereal", rows: 1)            
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }      
      matches.size.should == 1


      stub_faraday do |stub|
        stub.get('/nlpapi/companies/match?query=apple&rows=1') { response(total: 1, entities: [{ name: "Apple Inc.", brands: ["Apple Computer"] }] ) }
      end
      matches = GoodGuide::NlpApi.match(:companies, query: "apple", rows: 1)            
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }      
      matches.size.should == 1

      stub_faraday do |stub|
        stub.get('/nlpapi/ingredients/match?query=apple&rows=1') { response(total: 1, entities: [{ name: "apple"}] ) }
      end
      matches = GoodGuide::NlpApi.match(:ingredients, query: "apple", rows: 1)            
      matches.each { |p| p.should be_a GoodGuide::NlpApi::Match }      
      matches.size.should == 1
            
      stub_faraday do |stub|
        stub.get('/nlpapi/ingredients/match?query=adsfasdfsafsadsdaf') { response(total: 0, entities: [{ corrected: false }] ) }
      end
      matches = GoodGuide::NlpApi.match(:ingredients, query: "adsfasdfsafsadsdaf")
      matches.size.should == 0
    end
  end  
end
