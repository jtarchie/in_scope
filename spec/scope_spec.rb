require 'spec_helper'
require 'active_record'
require 'with_model'
require 'in_scope'
require 'benchmark'

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => ":memory:"
)

describe "with scopes on ActiveRecord model" do
  extend WithModel

  with_model(:Post) do
    table do |t|
      t.string :name
      t.boolean :runs
      t.timestamps
    end

    model do
      include InScope
      scope :physically_active, where(runs: true)

      def sql_physically_active?
        in_scope?(self.class.physically_active)
      end

      def ruby_physically_active?
        runs == true
      end
    end
  end

  context "with the scope" do
    let!(:post) { Post.create(runs: true) }

    it "returns the active post" do
      Post.physically_active.should == [post]
    end

    it "returns true that its active" do
      post.should be_sql_physically_active
      post.should be_ruby_physically_active
    end
  end

  pending "a benchmark" do
    let!(:post) { Post.create(runs: true) }
    it "has a benchmark to show how fast it is" do
      iterations = 10000
      Benchmark.bmbm do |x|
        x.report("ruby") { iterations.times { post.sql_physically_active? } }
        x.report("sql") { iterations.times { post.ruby_physically_active? } }
      end
    end
  end
end