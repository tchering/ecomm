// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application";
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";
eagerLoadControllersFrom("controllers", application);

import PasswordToggleController from "./auth/password_toggle_controller";
import FormTransitionController from "./auth/form_transition_controller";

application.register("auth--password-toggle", PasswordToggleController);
application.register("auth--form-transition", FormTransitionController);
