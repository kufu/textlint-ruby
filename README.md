# textlint-ruby

Ruby AST parser for [textlint-ruby-plugin](https://github.com/alpaca-tc/textlint-ruby-plugin).

## Installation

**TODO: release gems**

Add this line to your application's Gemfile:

```ruby
gem 'textlint-ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install textlint-ruby

## Usage

Parse ruby to textlint AST

```sh
$ textlint-ruby ./path/to/file.rb
{"type":"Document","raw":"...","range":[0,465],"loc":{"start":{"line":1,"column":0},"end":{"line":26,"column":0}},"children":[...]}
```

### Supported nodes

These types are defined in `@textlint/ast-node-types`.
Supported node types are only `Document`, `Comment` and `Str` because this plugin is used to format strings embedded in ruby programs.

| Type name                       | Node type     | Supported                            |
| ------------------------------- | ------------- | ------------------------------------ |
| ASTNodeTypes.Document           | TxtParentNode | yes                                  |
| ASTNodeTypes.DocumentExit       | TxtParentNode |                                      |
| ASTNodeTypes.Paragraph          | TxtParentNode |                                      |
| ASTNodeTypes.ParagraphExit      | TxtParentNode |                                      |
| ASTNodeTypes.BlockQuote         | TxtParentNode |                                      |
| ASTNodeTypes.BlockQuoteExit     | TxtParentNode |                                      |
| ASTNodeTypes.List               | TxtParentNode |                                      |
| ASTNodeTypes.ListExit           | TxtParentNode |                                      |
| ASTNodeTypes.ListItem           | TxtParentNode |                                      |
| ASTNodeTypes.ListItemExit       | TxtParentNode |                                      |
| ASTNodeTypes.Header             | TxtParentNode |                                      |
| ASTNodeTypes.HeaderExit         | TxtParentNode |                                      |
| ASTNodeTypes.CodeBlock          | TxtParentNode |                                      |
| ASTNodeTypes.CodeBlockExit      | TxtParentNode |                                      |
| ASTNodeTypes.HtmlBlock          | TxtParentNode |                                      |
| ASTNodeTypes.HtmlBlockExit      | TxtParentNode |                                      |
| ASTNodeTypes.Link               | TxtParentNode |                                      |
| ASTNodeTypes.LinkExit           | TxtParentNode |                                      |
| ASTNodeTypes.Delete             | TxtParentNode |                                      |
| ASTNodeTypes.DeleteExit         | TxtParentNode |                                      |
| ASTNodeTypes.Emphasis           | TxtParentNode |                                      |
| ASTNodeTypes.EmphasisExit       | TxtParentNode |                                      |
| ASTNodeTypes.Strong             | TxtParentNode |                                      |
| ASTNodeTypes.StrongExit         | TxtParentNode |                                      |
| ASTNodeTypes.Break              | TxtNode       |                                      |
| ASTNodeTypes.BreakExit          | TxtNode       |                                      |
| ASTNodeTypes.Image              | TxtNode       |                                      |
| ASTNodeTypes.ImageExit          | TxtNode       |                                      |
| ASTNodeTypes.HorizontalRule     | TxtNode       |                                      |
| ASTNodeTypes.HorizontalRuleExit | TxtNode       |                                      |
| ASTNodeTypes.Comment            | TxtTextNode   | yes                                  |
| ASTNodeTypes.CommentExit        | TxtTextNode   |                                      |
| ASTNodeTypes.Str                | TxtTextNode   | yes                                  |
| ASTNodeTypes.StrExit            | TxtTextNode   |                                      |
| ASTNodeTypes.Code               | TxtTextNode   |                                      |
| ASTNodeTypes.CodeExit           | TxtTextNode   |                                      |
| ASTNodeTypes.Html               | TxtTextNode   |                                      |
| ASTNodeTypes.HtmlExit           | TxtTextNode   |                                      |

## Development

Run `bundle exec rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alpaca-tc/textlint-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alpaca-tc/textlint-ruby/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the `textlint-ruby` project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alpaca-tc/textlint-ruby/blob/master/CODE_OF_CONDUCT.md).
