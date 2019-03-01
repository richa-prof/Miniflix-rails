class Episode < Movie
  default_scope  { where(kind: 'episode')}
end