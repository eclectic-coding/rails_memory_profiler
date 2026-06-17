return unless Rails.env.development?

Rails.application.config.after_initialize do
  next if RailsMemoryProfiler::ReportStore.size > 0

  seed_reports = [
    { controller: "posts",    action: "index",   path: "/posts",             method: "GET",  allocated_objects: 2_340,  retained_objects: 12,  duration_ms: 8.2  },
    { controller: "posts",    action: "show",    path: "/posts/1",           method: "GET",  allocated_objects: 1_870,  retained_objects: 0,   duration_ms: 5.6  },
    { controller: "posts",    action: "create",  path: "/posts",             method: "POST", allocated_objects: 3_120,  retained_objects: 48,  duration_ms: 22.1 },
    { controller: "users",    action: "index",   path: "/users",             method: "GET",  allocated_objects: 9_450,  retained_objects: 88,  duration_ms: 34.7 },
    { controller: "users",    action: "show",    path: "/users/42",          method: "GET",  allocated_objects: 6_230,  retained_objects: 30,  duration_ms: 18.3 },
    { controller: "users",    action: "update",  path: "/users/42",          method: "PATCH", allocated_objects: 7_890, retained_objects: 55,  duration_ms: 41.0 },
    { controller: "articles", action: "index",   path: "/articles",          method: "GET",  allocated_objects: 24_100, retained_objects: 310, duration_ms: 87.4 },
    { controller: "articles", action: "show",    path: "/articles/rails-7",  method: "GET",  allocated_objects: 18_750, retained_objects: 204, duration_ms: 63.2 },
    { controller: "articles", action: "create",  path: "/articles",          method: "POST", allocated_objects: 31_400, retained_objects: 420, duration_ms: 112.8 },
    { controller: "articles", action: "destroy", path: "/articles/old-post", method: "DELETE", allocated_objects: 15_200, retained_objects: 95, duration_ms: 55.9 },
    { controller: "dashboard", action: "index",  path: "/dashboard",         method: "GET",  allocated_objects: 44_800, retained_objects: 590, duration_ms: 143.2 },
    { controller: "search",   action: "index",   path: "/search?q=rails",    method: "GET",  allocated_objects: 52_300, retained_objects: 780, duration_ms: 201.5 },
    { controller: "api/v1/posts", action: "index", path: "/api/v1/posts",   method: "GET",  allocated_objects: 11_200, retained_objects: 140, duration_ms: 29.6 },
    { controller: "api/v1/users", action: "show",  path: "/api/v1/users/7", method: "GET",  allocated_objects: 4_560,  retained_objects: 20,  duration_ms: 12.1 },
    { controller: "pages",    action: "home",    path: "/",                  method: "GET",  allocated_objects: 1_200,  retained_objects: 5,   duration_ms: 3.4  },
  ]

  seed_reports.each_with_index do |attrs, i|
    payload = attrs.merge(recorded_at: i.minutes.ago)

    # Attach sample detail breakdowns to every third report
    if i % 3 == 0
      payload[:detail] = {
        allocated_by_gem:      [
          { name: "activesupport", count: (attrs[:allocated_objects] * 0.35).to_i },
          { name: "activerecord",  count: (attrs[:allocated_objects] * 0.28).to_i },
          { name: "actionpack",    count: (attrs[:allocated_objects] * 0.18).to_i },
          { name: "other",         count: (attrs[:allocated_objects] * 0.19).to_i }
        ],
        allocated_by_class:    [
          { name: "String",  count: (attrs[:allocated_objects] * 0.42).to_i },
          { name: "Hash",    count: (attrs[:allocated_objects] * 0.22).to_i },
          { name: "Array",   count: (attrs[:allocated_objects] * 0.15).to_i },
          { name: "Proc",    count: (attrs[:allocated_objects] * 0.08).to_i },
          { name: "other",   count: (attrs[:allocated_objects] * 0.13).to_i }
        ],
        allocated_by_file:     [
          { name: "activesupport/lib/active_support/core_ext/string.rb", count: (attrs[:allocated_objects] * 0.20).to_i },
          { name: "activerecord/lib/active_record/relation.rb",           count: (attrs[:allocated_objects] * 0.18).to_i },
          { name: "app/models/post.rb",                                   count: (attrs[:allocated_objects] * 0.12).to_i }
        ],
        allocated_by_location: [
          { name: "activesupport/lib/active_support/core_ext/string.rb:42", count: (attrs[:allocated_objects] * 0.10).to_i },
          { name: "activerecord/lib/active_record/relation.rb:198",          count: (attrs[:allocated_objects] * 0.08).to_i }
        ],
        retained_by_gem:       [
          { name: "activesupport", count: (attrs[:retained_objects] * 0.60).to_i },
          { name: "other",         count: (attrs[:retained_objects] * 0.40).to_i }
        ],
        retained_by_class:     [
          { name: "String", count: (attrs[:retained_objects] * 0.55).to_i },
          { name: "Hash",   count: (attrs[:retained_objects] * 0.45).to_i }
        ],
        retained_by_file:      [],
        retained_by_location:  []
      }
    end

    RailsMemoryProfiler::ReportStore.push(payload)
  end
end