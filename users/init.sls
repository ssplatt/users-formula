# vim: ft=sls
# Init users
{%- from "users/map.jinja" import users with context %}

{% if users.enabled %}
include:
  - users.config
{% else %}
'users-formula disabled':
  test.succeed_without_changes
{% endif %}

