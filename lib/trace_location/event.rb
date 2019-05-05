# frozen_string_literal: true

module TraceLocation
  class Event # :nodoc:
    CLASS_FORMAT = /\A#<Class\:(.+)?>\z/.freeze
    attr_reader :event, :path, :lineno, :method_id, :defined_class, :hierarchy

    def initialize(event:, path:, lineno:, method_id:, defined_class:, hierarchy:)
      @event     = event
      @path      = path
      @lineno    = lineno
      @method_id = method_id
      @defined_class = defined_class
      @hierarchy = hierarchy.to_i
    end

    def valid?
      hierarchy >= 0
    end

    def invalid?
      !valid?
    end

    def call?
      event == :call
    end

    def return?
      event == :return
    end

    def method_str
      match = defined_class.to_s.match(CLASS_FORMAT)

      if match
        "#{match[1]}.#{method_id}"
      else
        "#{defined_class}##{method_id}"
      end
    end
  end
end