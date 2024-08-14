import SwiftUI

public struct HexGrid<Data, ID, Content>: View where Data: RandomAccessCollection, Data.Element: OffsetCoordinateProviding, ID: Hashable, Content: View {
    public let data: Data
    public let id: KeyPath<Data.Element, ID>
    public let cornerRadius: CGFloat
    public let spacing: CGFloat
    public let fixedCellSize: CGSize?
    public let indentLine: HexGridIndentLine
    public let content: (Data.Element) -> Content

    @inlinable public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        spacing: CGFloat = .zero,
        cornerRadius: CGFloat,
        fixedCellSize: CGSize? = nil,
        indentLine: HexGridIndentLine = .even,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.spacing = spacing / 2
        self.cornerRadius = cornerRadius
        self.fixedCellSize = fixedCellSize
        self.indentLine = indentLine
        self.content = content
    }

    public var body: some View {
        HexLayout(fixedCellSize: fixedCellSize, indentLine: indentLine) {
            ForEach(data, id: id) { element in
                content(element)
                    .clipShape(HexagonShape(cornerRadius: cornerRadius))
                    .padding(.all, spacing)
                    .layoutValue(key: OffsetCoordinateLayoutValueKey.self,
                                 value: element.offsetCoordinate)
            }
        }
    }
}

public extension HexGrid where ID == Data.Element.ID, Data.Element: Identifiable {
    @inlinable init(
        _ data: Data,
        spacing: CGFloat = .zero,
        cornerRadius: CGFloat = 0,
        fixedCellSize: CGSize? = nil,
        indentLine: HexGridIndentLine = .even,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(data, id: \.id, spacing: spacing, cornerRadius: cornerRadius, fixedCellSize: fixedCellSize, indentLine: indentLine, content: content)
    }
}

public enum HexGridIndentLine {
    case odd
    case even
}
