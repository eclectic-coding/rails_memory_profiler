import { application } from "rails_memory_profiler/controllers/application"
import FilterController  from "rails_memory_profiler/controllers/filter_controller"
import CompareController from "rails_memory_profiler/controllers/compare_controller"

application.register("filter",  FilterController)
application.register("compare", CompareController)