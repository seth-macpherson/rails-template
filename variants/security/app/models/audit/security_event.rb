module Audit
  # Represents a logged instance of a security event such as a login or logout
  class SecurityEvent < ApplicationRecord
    belongs_to :user

    validates :time, presence: true

    enum event_type: %i(login logout change_password failed_login create_token refresh_token)

    # Init the timestamp column which isn't nullable
    after_initialize :set_timestamp!

    default_scope { order(time: :desc) }

    attr_accessor :force_writable

    LOCAL_ADDRS = %w(127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 ::1).freeze

    def readonly?
      persisted? && !@force_writable
    end

    def self.public_ips
      query = LOCAL_ADDRS.map { |b| "ip << '#{b}'" }.join(' OR ')
      where.not("ip IS NULL OR #{query}")
    end

    def private_ip?
      LOCAL_ADDRS.any? { |s| IPAddr.new(s).include?(ip) }
    end

    protected

    def set_timestamp!
      self.time ||= Time.now.utc
    end
  end
end
