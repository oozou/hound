require 'fast_spec_helper'
require 'rubocop'
require 'active_support/core_ext/string/strip'
require 'app/models/style_guide'

describe StyleGuide, '#violations' do
  context 'with default configuration' do
    context 'for inline comment' do
      it 'returns violation' do
        expect(violations_in(<<-CODE)).not_to be_empty
puts 'test' # inline comment
        CODE
      end
    end

    context 'for long line' do
      it 'returns violation' do
        expect(violations_in('a' * 80)).not_to be_empty
      end
    end

    context 'for trailing whitespace' do
      it 'returns violation' do
        expect(violations_in('one = 1   ')).not_to be_empty
      end
    end

    context 'for spaces after (' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
puts( 'test')
        CODE
      end
    end

    context 'for spaces before )' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
puts('test' )
        CODE
      end
    end

    context 'for spaces after [' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
a[ 'test']
        CODE
      end
    end

    context 'for spaces before ]' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
a['test' ]
        CODE
      end
    end

    context 'for vertically aligned tokens' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
puts :one,   :two
puts :three, :four
        CODE
      end
    end

    context 'for paren for a multi-line argument list not on its own line' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
puts(
  :one,
  :two)
        CODE
      end
    end

    context 'for brace for a multi-line hash not on its own line' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
test = {
  :one,
  :two}
        CODE
      end
    end

    context 'for continued lines indented more than two spaces' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
puts(
    :one,
    :two
)
        CODE
      end
    end

    context 'for private methods indented more than public methods' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
def one
  1
end

private

  def two
    2
  end
        CODE
      end
    end

    context 'for leading dot used for multi-line method chain' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
one
  .two
  .three
        CODE
      end
    end

    context 'for tab indentation' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
def test
\tputs 'test'
end
        CODE
      end
    end

    context 'for two methods without newline separation' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
def one
  1
end
def two
  2
end
        CODE
      end
    end

    context 'for two multi-line blocks without newline separation' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
[].each do
  puts 'test'
end
[].each do
  puts 'test'
end
        CODE
      end
    end

    context 'for operator without surrounding spaces' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
two = 1+1
        CODE
      end
    end

    context 'for comma without trailing space' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
puts :one,:two
        CODE
      end
    end

    context 'for colon without trailing space' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
{one:1}
        CODE
      end
    end

    context 'for semicolon without trailing space' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
puts :one;puts :two
        CODE
      end
    end

    context 'for opening brace without leading space' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
a ={ one: 1 }
        CODE
      end
    end

    context 'for opening brace without trailing space' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
a = {one: 1 }
        CODE
      end
    end

    context 'for closing brace without leading space' do
      it 'returns violations' do
        expect(violations_in(<<-CODE)).not_to be_empty
a = { one: 1}
        CODE
      end
    end

    context 'for non-Unix style line endings' do
      it 'returns violations'
    end

    context 'for lowercase SQL keywords' do
      it 'returns violations'
    end
  end

  context 'with custom configuration' do
    it 'finds only one violation' do
      content = <<-TEXT.strip_heredoc
        def test_method()
          "hello world"
        end
      TEXT
      config = <<-TEXT.strip_heredoc
        StringLiterals:
          EnforcedStyle: double_quotes
          Enabled: true
      TEXT
      style_guide = StyleGuide.new(config)

      violations = style_guide.violations(content)

      expect(violations.map(&:message)).to eq [
        "Omit the parentheses in defs when the method doesn't accept any arguments."
      ]
    end
  end


  private

  def violations_in(content)
    unless content.end_with?("\n")
      content += "\n"
    end
    StyleGuide.new.violations(content).map(&:message)
  end
end
