module RailsMemoryProfiler
  module ApplicationHelper
    def inline_styles
      dir = RailsMemoryProfiler::Engine.root.join("app/assets/stylesheets/rails_memory_profiler")
      css = dir.glob("_*.css").sort.map(&:read).join("\n")
      content_tag(:style, css.html_safe)
    end

    def sort_th(label, column, current_sort, current_dir)
      active    = current_sort == column.to_s
      next_dir  = (active && current_dir == "asc") ? "desc" : "asc"
      indicator = active ? (current_dir == "asc" ? " ▲" : " ▼") : ""
      params    = request.query_parameters.merge("sort" => column, "direction" => next_dir)
      href      = "?" + params.to_query
      content_tag(:th) do
        link_to(
          "#{label}#{indicator}".html_safe,
          href,
          class: ["rmp-sort-link", ("rmp-sort-active" if active)].compact.join(" ")
        )
      end
    end

    def allocation_badge(count)
      css_class = if count < 5_000
        "rmp-badge--low"
      elsif count < 20_000
        "rmp-badge--mid"
      else
        "rmp-badge--high"
      end
      content_tag(:span, number_with_delimiter(count), class: "rmp-badge #{css_class}")
    end
  end
end
