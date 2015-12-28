require 'bowser/event_target'

module Bowser
  class Element
    include EventTarget

    def initialize native
      @native = native
    end

    def inner_dom= node
      clear
      append node
    end

    def inner_html
      `#@native.innerHTML`
    end

    def clear
      %x{
          var native = #@native;

          if(native.nodeName === 'INPUT' || native.nodeName === 'TEXTAREA') {
            native.value = null;
          } else {
            var children = native.children;
            for(var i = 0; i < children.length; i++) {
              children[i].remove();
            }
          }
      }
      self
    end

    def append node
      `#@native.appendChild(node)`
      self
    end

    # Form input methods
    def checked?
      `!!#@native.checked`
    end

    def value
      `#@native.value`
    end
  end
end
