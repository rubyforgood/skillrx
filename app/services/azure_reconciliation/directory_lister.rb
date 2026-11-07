# Lists every file in one Azure File Share directory.
#
# The azure_file_shares gem's `list` returns only the first page (up to 5,000
# entries) and drops the continuation marker, so it undercounts large folders.
# This follows NextMarker until the listing is complete, reusing the gem's
# request signing.
module AzureReconciliation
  class DirectoryLister
    class Error < StandardError; end

    PAGE_SIZE = 5000

    def initialize(share:, files: AzureFileShares.client.files, connection: nil)
      @share = share
      @files = files
      @connection = connection
    end

    # Returns { file_name => byte_size }, or nil if the directory does not exist.
    def files_in(directory)
      result = {}
      marker = nil

      loop do
        body = fetch_page(directory, marker)
        return nil if body.nil?

        xml = Nokogiri::XML(body)
        xml.xpath("//Entries/File").each do |file|
          result[file.at_xpath("Name").text] = file.at_xpath("Properties/Content-Length")&.text.to_i
        end

        marker = xml.at_xpath("//NextMarker")&.text.presence
        break if marker.nil?
      end

      result
    end

    private

    attr_reader :share, :files

    def fetch_page(directory, marker)
      path = "/#{share}/#{encode_path(directory)}"
      query = { restype: "directory", comp: "list", maxresults: PAGE_SIZE.to_s }
      query[:marker] = marker if marker

      headers = {
        "x-ms-date" => Time.now.utc.httpdate,
        "x-ms-version" => files.client.api_version,
      }
      headers["Authorization"] = files.send(:calculate_authorization_header, :get, path, headers, query)

      response = connection.get("#{files.file_base_url}#{path}?#{URI.encode_www_form(query)}", nil, headers)

      return nil if response.status == 404
      return response.body if response.success?

      raise Error, "Listing #{directory} failed with #{response.status} #{error_detail(response.body)}"
    end

    # Azure's AuthenticationErrorDetail holds the string it signed, which is
    # what to compare against when a signature is rejected.
    def error_detail(body)
      xml = Nokogiri::XML(body.to_s.sub(/\A﻿/, ""))
      parts = %w[Code Message AuthenticationErrorDetail].filter_map { |tag| xml.at_xpath("//Error/#{tag}")&.text&.strip }
      parts.any? ? parts.join("\n") : body.to_s[0, 500]
    end

    def encode_path(directory)
      directory.split("/").reject(&:blank?).map { |segment| ERB::Util.url_encode(segment) }.join("/")
    end

    def connection
      @connection ||= files.send(:create_file_connection)
    end
  end
end
