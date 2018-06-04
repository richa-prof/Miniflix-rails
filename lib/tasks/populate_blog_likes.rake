namespace :populate_blog_likes do
  desc 'generate random blog likes and save'
  task generate_random_blog_likes: :environment do
    r = Random.new
    Blog.all.each do |blog|
      random_num = r.rand(5...20)
      likes_count = blog.likes.count
      if likes_count <= 5
        (0..random_num).each do |num|
          like = blog.likes.new
          like.save
        end
      end
    end
  end

end

# RAILS_ENV=production bundle exec rake populate_blog_likes:generate_random_blog_likes
