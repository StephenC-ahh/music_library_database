require "spec_helper"
require "rack/test"
require_relative '../../app'
def reset_albums_table
  seed_sql = File.read('spec/seeds/albums_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'music_library_test' })
  connection.exec(seed_sql)
end

describe Application do
  before(:each) do 
    reset_albums_table
  end
end
describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }
  
  context 'GET /albums' do
    it 'should include header of albums' do
      response = get('/albums')
      expect(response.body).to include('<h1>Albums</h1>')
    end
  end

  context 'GET /albums' do
    it 'returns a list of albums including Surfer Rosa' do
      response = get('/albums')
      expect(response.status)
      expect(response.body).to include('Surfer Rosa')
      expect(response.body).to include('Released: 1988')
    end
  end

  context 'GET /albums' do
    it 'should also return waterloo with release year 1974' do
      response = get('/albums')
      expect(response.body).to include('Waterloo')
      expect(response.body).to include('Released: 1974')
    end
  end

  context 'Get /albums/:id' do
    it 'should return info about album 2' do
      response = get('/albums/2')
      expect(response.status).to eq 200
      expect(response.body).to include ('<h1>Surfer Rosa </h1>')
      expect(response.body).to include ('Release year: 1988')
      expect(response.body).to include ('Artist: Pixies')
    end
  end

  context 'POST /albums' do
    it 'should validate album parameters' do
      response = post('/albums', invalid_title: 'Voyage', invalid_release_year: '2022')
      expect(response.status).to eq 400
    end

    it 'creates a new album and returns 200 ok' do
      response = post(
        '/albums',
        title: 'Voyage',
        release_year: '2022',
        artist_id: '2'
      )
      expect(response.status).to eq 200
      expect(response.body).to eq ''
      response = get('/albums')
      expect(response.body).to include 'Voyage'
    end
  end

  context "GET /albums/new" do
    it "returns the HTML form to create a new album" do
      response = get('/albums/new')
      expect(response.status).to eq(200)
      expect(response.body).to include("<form method='POST' action='/albums'>")
      expect(response.body).to include("<input type='text' name='title'/>")
      expect(response.body).to include("<input type='text' name='release_year'/>")
      expect(response.body).to include("<input type='text' name='artist_id'/>")
    end
  end

  context 'Get /artists/:id' do
    it 'should return info about artist 1' do
      response = get('/artists/1')
      expect(response.status).to eq 200
      expect(response.body).to include ('Pixies')
      expect(response.body).to include ('Genre: Rock')
    end
  end

  context 'Get /artists/:id' do
    it 'should return info about artist 2' do
      response = get('/artists/2')    
      expect(response.status).to eq 200
      expect(response.body).to include ('ABBA')
      expect(response.body).to include ('Genre: Pop')
    end
  end

  context 'GET /artists' do
    it 'should include header of artists' do
      response = get('/artists')
      expect(response.body).to include('<h1>Artists</h1>')
    end
  end

  context 'GET /artists' do
    it 'should return a list of artists including Pixies' do
      response = get('/artists')
      expect(response.body).to include('Pixies')
      expect(response.body).to include('Genre: Rock')
    end
  end
  # context 'GET /albums' do
  #   it 'should return the list of albums' do
  #     response = get('/albums')
  #     expect(response.status).to eq 200
  #     expected_response = 'Surfer Rosa, Waterloo, Super Trouper, Bossanova, Lover, Folklore, I Put a Spell on You, Baltimore, Here Comes the Sun, Fodder on My Wings, Ring Ring'
  #     expect(response.body).to eq  (expected_response)
  #   end
  # end

  # context 'GET albums/id' do
  #   it "should return an album title with id of 2" do
  #     response = get('albums/id?id=2')
  #     expect(response.status).to eq 200
  #     expect(response.body).to eq "Surfer Rosa"
  #   end
  # end

  # context 'GET albums/id' do
  #   it "should return an album title with id of 3" do
  #     response = get('albums/id?id=3')
  #     expect(response.status).to eq 200
  #     expect(response.body).to eq "Waterloo"
  #   end
  # end

  context 'POST /albums' do
    it "should create a new album" do
      response = post('/albums', 
        title: "Voyage", 
        release_year: '2022', 
        artist_id: '2'
      )
      
      expect(response.status).to eq 200
      expect(response.body).to eq ''

      response = get('/albums')

      expect(response.body).to include ('Voyage')
    end
  end

  # context 'GET /artists' do
  #   it "returns a list of artists" do
  #     response = get('/artists')
  #     expect(response.status).to eq 200
  #     expect(response.body).to eq "Pixies, ABBA, Taylor Swift, Nina Simone, Kiasmos"
  #   end
  # end

  context 'POST /artists' do
    it 'creates a new artist' do
      response = post('/artists', name: "Wild Nothing", genre: "Indie")

      expect(response.status).to eq 200
      expect(response.body).to eq ''

      response = get('/artists')
      expect(response.body).to include 'Wild Nothing'
    end
  end
end
