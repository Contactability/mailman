require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '/spec_helper'))

describe ContactabilityMailman::Route::ToCondition do

  it 'should match an address' do
    ContactabilityMailman::Route::ToCondition.new('test').match(basic_message).should == [{}, []]
  end

  it 'should not match a non-matching address' do
    ContactabilityMailman::Route::ToCondition.new('foo').match(basic_message).should be_nil
  end

  it 'should not match a nil address' do
    ContactabilityMailman::Route::ToCondition.new('test').match(Mail.new).should be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    ContactabilityMailman::Route.new.to('test').conditions[0].class.should == ContactabilityMailman::Route::ToCondition
  end

end

describe ContactabilityMailman::Route::FromCondition do

  it 'should match an address' do
    ContactabilityMailman::Route::FromCondition.new('chunky').match(basic_message).should == [{}, []]
  end

  it 'should not match a non-matching address' do
    ContactabilityMailman::Route::FromCondition.new('foo').match(basic_message).should be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    ContactabilityMailman::Route.new.from('test').conditions[0].class.should == ContactabilityMailman::Route::FromCondition
  end

end

describe ContactabilityMailman::Route::SubjectCondition do

  it 'should match the subject' do
    ContactabilityMailman::Route::SubjectCondition.new('Hello').match(basic_message).should == [{}, []]
  end

  it 'should not match a non-matching subject' do
    ContactabilityMailman::Route::SubjectCondition.new('foo').match(basic_message).should be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    ContactabilityMailman::Route.new.subject('test').conditions[0].class.should == ContactabilityMailman::Route::SubjectCondition
  end

end

describe ContactabilityMailman::Route::BodyCondition do

  it 'should match the body' do
    ContactabilityMailman::Route::BodyCondition.new('email').match(basic_message).should == [{}, []]
  end

  it 'should not match a non-matching body' do
    ContactabilityMailman::Route::BodyCondition.new('foo').match(basic_message).should be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    ContactabilityMailman::Route.new.body('test').conditions[0].class.should == ContactabilityMailman::Route::BodyCondition
  end

end

describe ContactabilityMailman::Route::CcCondition do

  it 'should match an address' do
    ContactabilityMailman::Route::CcCondition.new('testing').match(basic_message).should == [{}, []]
  end

  it 'should not match a non-matching address' do
    ContactabilityMailman::Route::CcCondition.new('foo').match(basic_message).should be_nil
  end

  it 'should not match a nil address' do
    ContactabilityMailman::Route::CcCondition.new('testing').match(Mail.new).should be_nil
  end

  it 'should define a method on Route that is chainable and stores the condition' do
    ContactabilityMailman::Route.new.cc('testing').conditions[0].class.should == ContactabilityMailman::Route::CcCondition
  end

end
