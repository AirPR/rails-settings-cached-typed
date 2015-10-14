require 'spec_helper'

describe RailsSettings::CachedSettings do
  describe '.cache_key' do
    it 'should work with instance method' do
      obj = Setting.unscoped.first
      expect(obj.cache_key).to eq("rails_settings_cached:#{obj.var}")
    end

    it 'should work with class method' do
      expect(Setting.cache_key('abc', nil)).to eql("rails_settings_cached:abc")
    end

    it 'should work with class method and scoped object' do
      obj = User.first
      expect(Setting.cache_key('abc', obj)).to eql("rails_settings_cached:User-1:abc")
    end
  end

  describe '.cache_prefix' do
    it 'sets cache key prefix' do
      described_class.cache_prefix { "stuff" }
      expect(described_class.cache_key('abc', nil)).to eql("rails_settings_cached:stuff:abc")
    end
  end

  describe 'Unscoped' do
    it 'should set a key and fetch with one query' do
      expect(Setting.test_cache).to eq(nil)
      Setting.test_cache = 123
      queries_count = count_queries do
        expect(Setting.test_cache).to eq(123)
        expect(Setting.test_cache).to eq(123)
        expect(Setting.test_cache).to eq(123)
      end
      expect(queries_count).to eq(0)
      Setting.test_cache = 321
      expect(Setting.test_cache).to eq(321)
    end
  end

  it "caches unscoped settings" do
    queries_count = count_queries do
      expect(described_class["gender"]).to be nil
      described_class["gender"] = "female"
      expect(described_class["gender"]).to eq("female")
      expect(described_class["gender"]).to eq("female")
    end
    expect(queries_count).to eq(5)
  end

  it "caches scoped settings" do
    user = User.create!(login: 'another_test', password: 'foobar')

    queries_count = count_queries do
      expect(user.settings["gender"]).to be nil
      user.settings["gender"] = "male"
      expect(user.settings["gender"]).to eq("male")
      expect(user.settings["gender"]).to eq("male")
    end
    expect(queries_count).to eq(6)
  end

  it "caches values from db" do
    described_class["some_random_key"] = "asd"
    Rails.cache.clear

    queries_count = count_queries do
      expect(described_class["some_random_key"]).to eq("asd")
      expect(described_class["some_random_key"]).to eq("asd")
      expect(described_class["another_random_key"]).to be nil
      expect(described_class["another_random_key"]).to be nil
    end
    expect(queries_count).to eq(3)
  end
end
