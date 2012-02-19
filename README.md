Tag Github
=================

Simple manage app to tag watched Github repositories for futhur inspect.

* Utilizing ActiveAdmin for manage UI.
* Utilizing Sidekiq for background jobs.
* Plan to use mbleigh/acts-as-taggable-on for tagging

Development Status
-------------------

Early stage. Use the code at your own risk.

No rspec cover yet.

Implemented
-------------

* Add a user and automatically fetch info for repositories he/she is watching from Github APIs in the backgroud.
* Admin UI for users and repositories.

TODO
-----

* Fetch README for repositories, so we can know more without having to leave the app.
* Tagging
* ...

Licence
--------

MIT Licence, see LICENCE.
Copyright (c) 2011-2012 Utensil Song (https://github.com/utensil)
