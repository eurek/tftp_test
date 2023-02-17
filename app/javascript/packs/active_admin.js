// Load Active Admin's styles into Webpacker,
// see `active_admin.scss` for customization.
import "../stylesheets/active_admin";

import "@activeadmin/activeadmin";
import "activeadmin_addons"
import "arctic_admin";
import "@fortawesome/fontawesome-free/css/all.css";
import { globalSearch } from './active_admin/global_search.js';
import { Application } from "@hotwired/stimulus";
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers";

window.Stimulus = Application.start();
const context = require.context("../controllers", true, /\.js$/);
Stimulus.load(definitionsFromContext(context));

document.addEventListener('DOMContentLoaded', (event) => {
  globalSearch();
});
