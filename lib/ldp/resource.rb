module Ldp
  class Resource
    require 'ldp/resource/binary_source'
    require 'ldp/resource/rdf_source'

    attr_reader :client, :subject

    def initialize client, subject
      @client = client
      @subject = subject
    end

    ##
    # Get the graph subject as a URI
    def subject_uri
      @subject_uri ||= RDF::URI.new subject
    end

    ##
    # Reload the LDP resource
    def reload
      self.class.new client, subject, @get
    end

    ##
    # Is the resource new, or does it exist in the LDP server?
    def new?
      subject.nil? || !client.head(subject)
    rescue Ldp::NotFound
      true
    end

    ##
    # Have we retrieved the content already?
    def retrieved_content?
      @get
    end

    ##
    # Get the resource
    def get
      @get ||= client.get(subject)
    end

    ##
    # Delete the resource
    def delete
      client.delete subject do |req|
        req.headers['If-Match'] = get.etag if retrieved_content?
      end
    end
    
    def current? response = nil
      response ||= @get
      return true if new? and subject.nil?
      
      new_response = client.head(subject)

      response.headers['ETag'] &&
        response.headers['Last-Modified'] &&
        new_response.headers['ETag'] == response.headers['ETag'] &&
        new_response.headers['Last-Modified'] == response.headers['Last-Modified']
    end

  end
end
