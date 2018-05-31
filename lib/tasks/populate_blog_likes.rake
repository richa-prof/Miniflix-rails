namespace :populate_blog_likes do
  desc 'generate random blog likes and save'
  task generate_random_blog_likes: :environment do
    r = Random.new
    Blog.all.each do |blog|
      random_num = r.rand(5...20)
      (0..random_num).each do |num|
        like = blog.likes.new
        like.save
      end
    end
  end

end

#rake populate_blog_likes:generate_random_blog_likes
