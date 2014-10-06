module MESH

  class Entry

    include Comparable
    attr_accessor :id, :heading, :term, :semantic_types, :semantic_relationship, :lexical_type, :regex, :case_sensitive,
                  :downcased, :locales, :loose_match_term

    class << self
      attr_accessor :last_id
    end
    @last_id = 0
    @@wordy_characters = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a

        def <=> other
      self.term <=> other.term
    end

    def initialize(heading, entry_text, locale)
      @id = (Entry.last_id += 1)
      @heading = heading
      @locales = Set.new
      @locales << locale
      @semantic_types = []
      parts = entry_text.split('|')
      if entry_text.include? '|'
        key = parts.pop
        parts.each_with_index do |part, i|
          case key[i]
            when 'a' # the term itself
              @term = part
            when 'b' # semantic type*
              @semantic_types << MESH::SemanticTypes[part]
            when 'c' # lexical type*
              @lexical_type = MESH::LexicalTypes[part]
            when 'd' # semantic relation*
              @semantic_relationship = MESH::SemanticRelationshipTypes[part]
            when 'e' # thesaurus id
            when 'f' # date
            when 's' # sort version
            when 'v' # entry version
          end
        end
      else
        @term = entry_text
      end
      if /^[A-Z0-9]+$/ =~ @term
        @regex = /(^|\W)#{Regexp.quote(@term)}(\W|$)/
        @case_sensitive = true
      else
        @regex = /(^|\W)#{Regexp.quote(@term)}(\W|$)/i
        @case_sensitive = false
      end

      @downcased = @term.downcase
      @loose_match_term = Entry.loose_match(@term)

    end

    def self.loose_match(term)
      term.gsub(/\W+/, ' ').upcase
    end

    # def match_in_text_2(text, downcased)
    #   return nil if text.nil? || text.empty?
    #   matches = []
    #
    #   offset = 0
    #   while offset < text.length
    #     found_at = @case_sensitive ? text.index(@term, offset) : downcased.index(@downcased, offset)
    #     if found_at
    #       found_end = found_at + term.length - 1
    #       whitespace_before = found_at.zero? ? true : (!@@wordy_characters.include? text[found_at - 1])
    #       whitespace_after = (found_end == text.length) ? true : (!@@wordy_characters.include? text[found_end + 1])
    #       if whitespace_before && whitespace_after
    #         matches << {heading: @heading, matched: self, index: [found_at, found_end]}#, source: text[found_at, term.length]}
    #       end
    #       offset = found_end + 1
    #     else
    #       offset = text.length
    #     end
    #   end
    #
    #   matches.empty? ? nil : matches
    #
    # end

    def match_in_text(text, downcased)
      return nil if text.nil? || text.empty?
      matches = []

      loose_match = @case_sensitive ? (text.include? @term) : (downcased.include? @downcased)
      if loose_match
        text.to_enum(:scan, @regex).map do |m,|
          match = Regexp.last_match
          matches << {heading: @heading, matched: self, index: match.offset(0)}
        end
      end

      matches.empty? ? nil : matches

    end

  end

end
