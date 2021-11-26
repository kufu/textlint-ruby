# frozen_string_literal: true

RSpec.describe Textlint::Nodes do
  describe Textlint::Nodes::TxtNode do
    describe '#as_textlint_json' do
      subject do
        instance.as_textlint_json
      end

      let(:instance) do
        described_class.new(
          type: Textlint::Nodes::DOCUMENT,
          raw: 'raw',
          range: Textlint::Nodes::TxtNodeRange.new(0, 2),
          loc: Textlint::Nodes::TxtNodeLineLocation.new(
            start: Textlint::Nodes::TxtNodePosition.new(
              line: 1,
              column: 0
            ),
            end: Textlint::Nodes::TxtNodePosition.new(
              line: 1,
              column: 0
            )
          )
        )
      end

      it do
        is_expected.to eq(
          type: Textlint::Nodes::DOCUMENT,
          raw: 'raw',
          range: [0, 2],
          loc: {
            start: {
              line: 1,
              column: 0
            },
            end: {
              line: 1,
              column: 0
            }
          }
        )
      end
    end
  end

  describe Textlint::Nodes::TxtParentNode do
    describe '#as_textlint_json' do
      subject do
        instance.as_textlint_json
      end

      let(:instance) do
        described_class.new(
          type: Textlint::Nodes::DOCUMENT,
          raw: 'raw',
          range: Textlint::Nodes::TxtNodeRange.new(0, 2),
          loc: Textlint::Nodes::TxtNodeLineLocation.new(
            start: Textlint::Nodes::TxtNodePosition.new(
              line: 1,
              column: 0
            ),
            end: Textlint::Nodes::TxtNodePosition.new(
              line: 1,
              column: 0
            )
          ),
          children: [
            Textlint::Nodes::TxtTextNode.new(
              type: Textlint::Nodes::STR,
              raw: 'raw',
              range: Textlint::Nodes::TxtNodeRange.new(0, 2),
              loc: Textlint::Nodes::TxtNodeLineLocation.new(
                start: Textlint::Nodes::TxtNodePosition.new(
                  line: 1,
                  column: 0
                ),
                end: Textlint::Nodes::TxtNodePosition.new(
                  line: 1,
                  column: 0
                )
              ),
              value: 'raw'
            )
          ]
        )
      end

      it do
        is_expected.to eq(
          type: Textlint::Nodes::DOCUMENT,
          raw: 'raw',
          range: [0, 2],
          loc: {
            start: {
              line: 1,
              column: 0
            },
            end: {
              line: 1,
              column: 0
            }
          },
          children: [
            {
              type: Textlint::Nodes::STR,
              raw: 'raw',
              range: [0, 2],
              loc: {
                start: {
                  line: 1,
                  column: 0
                },
                end: {
                  line: 1,
                  column: 0
                }
              },
              value: 'raw'
            }
          ]
        )
      end
    end
  end
end
