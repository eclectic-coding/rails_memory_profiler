import "@hotwired/turbo"
import { Application } from "@hotwired/stimulus"
import FilterController from "rails_memory_profiler/filter_controller"

const application = Application.start()
application.register("filter", FilterController)