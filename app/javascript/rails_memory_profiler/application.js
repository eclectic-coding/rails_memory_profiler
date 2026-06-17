import "@hotwired/turbo"
import { Application } from "@hotwired/stimulus"
import FilterController  from "rails_memory_profiler/controllers/filter_controller"
import CompareController from "rails_memory_profiler/controllers/compare_controller"

const application = Application.start()
application.register("filter",  FilterController)
application.register("compare", CompareController)