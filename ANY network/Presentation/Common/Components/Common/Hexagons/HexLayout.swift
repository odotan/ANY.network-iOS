import SwiftUI

struct HexLayout: Layout {
    let fixedCellSize: CGSize?
    let indentLine: HexGridIndentLine

    func makeCache(subviews: Subviews) -> CGRect {
        let coordinates = subviews.compactMap { $0[OffsetCoordinateLayoutValueKey.self] }

        return hexLayoutNormalizedBounds(coordinates: coordinates, indentLine: indentLine)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout CGRect) -> CGSize {
        if cache.isEmpty { return .zero }

        let proposalSize = proposal.replacingUnspecifiedDimensions()
        var cellStep =  hexLayoutCellStep(proposal: proposalSize, normalizedSize: cache.size)
        if let fixedCellSize = fixedCellSize {
            cellStep = CGSize(width: fixedCellSize.width, height: fixedCellSize.height * 3 / 4)
        }
        return CGSize(width: cellStep.width * cache.width, height: cellStep.height * cache.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout CGRect) {
        if cache.isEmpty { return }

        let proposalSize = proposal.replacingUnspecifiedDimensions()
        var cellStep =  hexLayoutCellStep(proposal: proposalSize, normalizedSize: cache.size)
        if let fixedCellSize = fixedCellSize {
            cellStep = CGSize(width: fixedCellSize.width, height: fixedCellSize.height * 3 / 4)
        }
        let cellSize = fixedCellSize ?? hexLayoutCellSize(cellStep: cellStep)
        let subviewProposal = ProposedViewSize(width: cellSize.width, height: cellSize.height)

        for subview in subviews {
            guard let coordinate = subview[OffsetCoordinateLayoutValueKey.self] else { continue }

            let cellCenter = hexLayoutCellCenter(coordinate: coordinate, normalizedOrigin: cache.origin, cellStep: cellStep, indentLine: indentLine)
            let point = CGPoint(x: bounds.minX + cellCenter.x, y: bounds.minY + cellCenter.y)
            subview.place(at: point, anchor: .center, proposal: subviewProposal)
        }
    }
}

func hexLayoutNormalizedBounds(coordinates: [OffsetCoordinate], indentLine: HexGridIndentLine) -> CGRect {
    if coordinates.isEmpty { return .zero }

    let normalizedX = coordinates.map { CGFloat($0.col) }
    let normalizedY = coordinates.map { CGFloat($0.row) + 1 / 2 * CGFloat($0.col & 1) }

    let minX: CGFloat = normalizedX.min()!
    let maxX: CGFloat = normalizedX.max()!
    let param: CGFloat = indentLine == .even ? 0 : 1//4 / 3
    let width = maxX - minX + param //+ 1 / 2 //+ 4 / 3

    let minY: CGFloat = normalizedY.min()!
    let maxY: CGFloat = normalizedY.max()!
    let height = maxY - minY + 1
    return CGRect(x: CGFloat(minX), y: CGFloat(minY), width: width, height: height)
}

func hexLayoutCellStep(proposal size: CGSize, normalizedSize: CGSize) -> CGSize {
    let scaleX: CGFloat = min(size.width / normalizedSize.width, size.height / normalizedSize.height / HexagonShape.aspectRatio)
    return CGSize(width: scaleX, height: scaleX * HexagonShape.aspectRatio)
}

func hexLayoutCellSize(cellStep: CGSize) -> CGSize {
    return CGSize(width: cellStep.width, height: cellStep.height * 4 / 3)
}

func hexLayoutCellCenter(coordinate: OffsetCoordinate, normalizedOrigin: CGPoint, cellStep: CGSize, indentLine: HexGridIndentLine) -> CGPoint {
    let param = indentLine == .even ? 1 : 0
    let normalizedX = CGFloat(coordinate.col) - normalizedOrigin.x + 1 / 2 * CGFloat((coordinate.row + param) % 2)
    let normalizedY = CGFloat(coordinate.row) - normalizedOrigin.y + 2 / 3
    return CGPoint(x: cellStep.width * normalizedX, y: cellStep.height * normalizedY)
}

struct OffsetCoordinateLayoutValueKey: LayoutValueKey {
    static let defaultValue: OffsetCoordinate? = nil
}
