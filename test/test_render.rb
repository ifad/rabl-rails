require 'helper'
require 'pathname'
require 'tmpdir'

class TestRender < Minitest::Test
  @@tmp_path = Pathname.new(Dir.mktmpdir)

  def setup
    @user = User.new(1, 'Marty')
    @tmp_path = @@tmp_path
  end

  def test_load_source_from_file
    File.open(@tmp_path + "show.json.rabl", "w") do |f|
      f.puts %q{
        object :@user
        attributes :id, :name
      }
    end
    assert_equal %q({"user":{"id":1,"name":"Marty"}}), RablRails.render(@user, 'show', view_path: @tmp_path)
  end

  def test_template_not_found
    assert_raises() { RablRails.render(@user, 'not_found') }
  end

  def test_extend_with_view_path
    File.open(@tmp_path + "extend.json.rabl", "w") do |f|
      f.puts %q{
        object :@user
        extends 'base'
      }
    end

    File.open(@tmp_path + "base.rabl", "w") do |f|
      f.puts %q{
        attribute :name, as: :extended_name
      }
    end

    assert_equal %q({"user":{"extended_name":"Marty"}}), RablRails.render(@user, 'extend', view_path: @tmp_path)
  end
end
