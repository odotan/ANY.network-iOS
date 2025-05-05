import SwiftUI

private struct GetCellCenter: ViewModifier {
    @State private var isActive: Bool = true
    private var cellToGet: Int?
    private let thisCell: Int?
    private let onFirstReceiveOfPosition: (CGPoint) -> Void
    
    init(cellToGet: Int?, thisCell: Int?, onFirstReceiveOfPosition: @escaping (CGPoint) -> Void) {
        self.cellToGet = cellToGet
        self.thisCell = thisCell
        self.onFirstReceiveOfPosition = onFirstReceiveOfPosition
    }
    
    func body(content: Content) -> some View {
        if let cellToGet, let thisCell, cellToGet == thisCell && isActive {
            content
                .overlay {
                    GeometryReader { reader in
                        Color.clear.onAppear {
                            onFirstReceiveOfPosition(reader.frame(in: .global).centerPoint)
                            isActive = false
                        }
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
    func getCellCenter(cellToGet: Int?, thisCell: Int?, onFirstReceiveOfPosition: @escaping (CGPoint) -> Void) -> some View {
        self.modifier(GetCellCenter(cellToGet: cellToGet, thisCell: thisCell, onFirstReceiveOfPosition: onFirstReceiveOfPosition))
    }
}
