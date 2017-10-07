# vim: ft=sls
# configure users
{%- from "users/map.jinja" import users with context -%}
{%- set options = dict() -%}
{%- set homedir = '' -%}

{%- if users.system.groups is defined %}
  {%- for groupname, groupopts in users.system.groups.items() %}

    {# Set defaults for system.groups #}
    {%- do groupopts.setdefault('state', 'absent') %}

    {# Build a dynamic list of arguments to pass to salt.states.user #}
    {%- set state_args = [ { 'name': groupname } ] %}

    {# Pop options from system.groups which should not be passed to salt.states.group #}
    {%- set state      = groupopts.pop('state') %}

    {# Pass through remaining options from system.groups to salt.states.group #}
    {%- for k, v in groupopts.items() %}
      {%- do state_args.append({ k: v }) %}
    {%- endfor %}

    {# Pass through options from directory.groups to salt.states.group #}
    {%- if state == 'present' %}
      {%- set options = users.directory.groups.get(groupname) %}
      {%- for k, v in options.items() %}
        {%- do state_args.append({ k: v }) %}
      {%- endfor %}
    {%- endif %}

group_{{ groupname }}_{{ state }}:
  group.{{ state }}: {{ state_args }}
  {%- endfor %}
{%- endif %}

{%- if users.system.users is defined %}
  {%- for username, useropts in users.system.users.items() %}

    {# Set defaults for system.users #}
    {%- do useropts.setdefault('state', 'absent') %}

    {# Build a dynamic list of arguments to pass to salt.states.user #}
    {%- set state_args = [ {'name': username} ] %}

    {# Pop options from system.users which should not be passed to salt.states.user #}
    {%- set state      = useropts.pop('state') %}

    {# Add defaults for salt.states.user.absent #}
    {% if state == 'absent' %}
      {% do useropts.setdefault('purge', True) %}
      {% do useropts.setdefault('force', True) %}
    {% endif %}

    {# Pass through remaining options from system.users to salt.states.user #}
    {% for k, v in useropts.items() %}
      {% do state_args.append({k: v}) %}
    {% endfor %}

    {% if state == 'present' %}
      {# Set defaults for directory.users #}
      {%- set options = users.directory.users.get(username, {})            %}
      {%- do options.setdefault('home', '/home/' + username )              %}
      {%- do options.setdefault('authorized_key_file', 'authorized_keys')  %}
      {%- do options.setdefault('configs', {})                             %}
      {%- do options.setdefault('google_2fa', {})                          %}
      {%- do options.setdefault('authorized_keys', [])                     %}
      {%- set homedir = options.home                                       %}

      {# Pop options from directory.users which should not be passed to salt.states.user #}
      {%- set authorized_key_file = options.pop('authorized_key_file')     %}
      {%- set configs = options.pop('configs')                             %}
      {%- set authorized_keys = options.pop('authorized_keys')             %}
      {%- set google_2fa = options.pop('google_2fa')                       %}

      {# Pass through remaining options from directory.users to salt.states.user #}
      {%- for k, v in options.items() %}
        {% do state_args.append({k: v}) %}
      {%- endfor %}
    {% endif %}

user_{{ username }}_{{ state }}:
  user.{{ state }}: {{ state_args }}

    {% if state == 'present' %}
user_{{ username }}_homedir_ensure_permissions:
  file.directory:
    - name: {{ homedir }}
    - user: {{ username }}
    - group: {{ username }}
    - mode: 700

      {%- for config, data in configs.items() %}
user_{{ username }}_config_{{ config }}:
  file.managed:
    - name: {{ homedir }}/.{{ config }}
        {#- If we have a data source, use it. #}
        {%- if data.source is defined %}
    - source: {{ data.source }}
        {# if no data source is available, but we have content #}
        {%- elif data.contents is defined %}
    - contents: {{ data.contents }}
        {# If no source or content is provided, use the default source location for template #}
        {%- else %}
    - source: salt://users/files/{{ username }}/{{ config }}
        {%- endif %}
        {%- if data.skip_verify is defined %}
    - skip_verify: {{ data.skip_verify }}
        {%- endif %}
        {%- if data.template is defined %}
    - template: {{ data.template }}
        {%- endif %}
        {%- if data.params is defined %}
    - params: {{ data.params }}
        {%- endif %}
        {%- if data.mode is defined %}
    - mode: {{ data.mode }}
        {% else %}
    - mode: 0640
        {%- endif %}
        {%- if data.user is defined %}
    - user: {{ data.user }}
        {%- else %}
    - user: {{ username }}
        {%- endif %}
        {%- if data.group is defined %}
    - group: {{ data.group }}
        {%- else %}
    - group: {{ username }}
        {% endif %}
      {%- endfor %}

      {%- if authorized_keys|length > 0 %}
user_{{ username }}_authorized_key_dir:
  file.directory:
    - name: {{ homedir }}/.ssh
    - user: {{ username }}
    - group: {{ username }}
    - mode: 700

user_{{ username }}_authorized_key_file:
  file.managed:
    - name: {{ homedir }}/.ssh/{{ authorized_key_file }}
    - source: salt://users/files/authorized_keys.j2
    - template: jinja
    - user: {{ username }}
    - group: {{ username }}
    - mode: 644
    - authorized_keys: {{ authorized_keys }}
      {%- endif %}

      {% set process_2fa = salt['pillar.get']('pam:google2fa:enabled', false) %}
      {%- if google_2fa|length > 0 and process_2fa %}
user_{{ username }}_google2fa_config_file_staticcontent:
  file.managed:
    - name: {{ homedir }}/.google_authenticator
    - contents:
      - 'CODE'
      - '" RATE_LIMIT 3 30'
      - '" WINDOW_SIZE 17'
      - '" DISALLOW_REUSE'
      - '" TOTP_AUTH'
    - unless: test -s {{ homedir }}/.google_authenticator

user_{{ username }}_google2fa_config:
  file.line:
    - name: {{ homedir }}/.google_authenticator
    - content: {{ google_2fa.secretkey }}
    - mode: replace
    - match: ^[\w\d]+
    - location: start
    - before: '\n" RATE_LIMIT 3 30'
    - show_changes: False

user_{{ username }}_google2fa_config_file_perms:
  file.managed:
    - name: {{ homedir }}/.google_authenticator
    - mode: 0400
    - user: {{ username }}
    - group: {{ username }}
    - replace: false

      {%- endif %}
    {%- endif %}
  {%- endfor %}
{%- endif %}

{% if users.system.aliases is defined %}
  {% for username, useropts in users.system.aliases.items() %}
    {%- do useropts.setdefault('state', 'absent') %}
    {% set state_args = [ {'name': username} ] %}
    {% set state = useropts.pop('state') %}
    {% for k, v in useropts.items() %}
      {% do state_args.append({k: v})%}
    {% endfor %}
user_aliases_{{ username }}_{{ state }}:
  alias.{{ state }}: {{ state_args }}
  {% endfor %}
{% endif %}
