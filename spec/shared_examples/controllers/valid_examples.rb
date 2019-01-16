shared_examples 'when user is authorized' do
  include_context 'authorized user'
end

shared_examples 'when user is admin' do
  include_context 'authorized user is admin'
end

shared_examples 'when user is writer' do
  include_context 'authorized writer'
end

shared_examples 'when user is reader' do
  include_context 'authorized reader'
end

shared_examples 'when user' do
  include_context 'authorized user'
end
