module Audit
  class SecurityEventDecorator < ApplicationDecorator
    delegate_all

    def event_type_icon
      type_map = {
        login: 'sign in',
        logout: 'sign out',
        login_blocked: 'remove',
        create_token: 'key',
        refresh_token: 'refresh'
      }
      h.content_tag(:i, '', class: [type_map[object.event_type.to_sym], 'icon'])
    end

    def event_type_name
      object.event_type.to_s.titleize
    end

    def user_or_comments
      if object.user.present?
        h.link_to_record object.user
      else
        object.comments
      end
    end

    def user_agent
      UserAgent.parse(object.user_agent)
    end

    def platform_icon
      app_map = {
        'curl' => 'terminal',
      }
      icon = app_map[user_agent.browser]

      type_map = {
        'Macintosh' => 'apple',
        'Windows'   => 'windows',
        'Linux'     => 'linux',
        'X11'       => 'linux',
        'Android'   => 'android',
        'iPhone'    => 'mobile',
        'iPad'      => 'tablet',
        'iPod'      => 'mobile'
      }
      icon ||= type_map[user_agent.platform]

      h.content_tag(:i, '', class: [icon, 'icon'])
    end

    def platform_class
      user_agent.platform.try(:underscore)
    end
  end
end
