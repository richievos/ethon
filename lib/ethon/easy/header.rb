module Ethon
  class Easy
    def self.build_header_finalizer(header_list)
      proc {
        Curl.slist_free_all(header_list)
      }
    end

    # This module contains the logic around adding headers to libcurl.
    #
    # @api private
    module Header
      # Return headers, return empty hash if none.
      #
      # @example Return the headers.
      #   easy.headers
      #
      # @return [ Hash ] The headers.
      def headers
        @headers ||= {}
      end

      HeaderHandleWrapper = Struct.new(:header_list)

      # Set the headers.
      #
      # @example Set the headers.
      #   easy.headers = {'User-Agent' => 'ethon'}
      #
      # @param [ Hash ] headers The headers.
      def headers=(headers)
        headers ||= {}
        header_list = nil
        headers.each {|k, v| header_list = Curl.slist_append(header_list, compose_header(k,v)) }
        Curl.set_option(:httpheader, header_list, handle)
        @header_handle_wrapper = HeaderHandleWrapper.new(header_list)
        ObjectSpace.define_finalizer(@header_handle_wrapper, Ethon::Easy.build_header_finalizer(header_list))
      end

      # Return header_list.
      #
      # @example Return header_list.
      #   easy.header_list
      #
      # @return [ FFI::Pointer ] The header list.
      def header_list
        @header_handle_wrapper && @header_handle_wrapper.header_list
      end

      # Compose libcurl header string from key and value.
      # Also replaces null bytes, because libcurl will complain about
      # otherwise.
      #
      # @example Compose header.
      #   easy.compose_header('User-Agent', 'Ethon')
      #
      # @param [ String ] key The header name.
      # @param [ String ] value The header value.
      #
      # @return [ String ] The composed header.
      def compose_header(key, value)
        Util.escape_zero_byte("#{key}: #{value}")
      end
    end
  end
end
