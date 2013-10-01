log node['foo']['bar']

cookbook_file '/Users/coderanger/src/chef/test.txt' do
  source 'test.txt'
  backup 0
end

cookbook_file '/Users/coderanger/src/chef/test2.txt' do
  source 'test2.txt'
  backup 0
end

cookbook_file '/Users/coderanger/src/chef/test3.txt' do
  source ['test2.txt', 'test.txt', 'default/test2.txt']
  backup 0
end
