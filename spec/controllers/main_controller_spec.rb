require 'spec_helper'

describe MainController do
  it "should rendex index page if a user is not logged in" do
    get 'index'
    response.should render_template('main/index')
  end
end
