import Foundation
import SwiftUI

final class HiUHomeViewModel: ViewModel {
    @Published private(set) var state: State
    @Published var gridModel: HiUScrollableHexGridModel = .init()

    private let coordinator: MainCoordinatorProtocol
    private let createXMTPClientUseCase: CreateXMTPClientUseCase
    
    init(coordinator: MainCoordinatorProtocol, createXMTPClientUseCase: CreateXMTPClientUseCase) {
        self.state = State()
        self.coordinator = coordinator
        self.createXMTPClientUseCase = createXMTPClientUseCase
    }
    
    func handle(_ event: Event) {
        switch event {
        case .setCellState(let coordinate, let model):
            state.cellQueue[coordinate] = model
            gridModel.refresh()
            
        case .updateLastTap(let time, let cell):
            state.lastTapTime = time
            state.lastTappedCell = cell
            
        case .stateUpdated(let hexState, let cell):
            print("ViewModel: State update requested for \(cell.offsetCoordinate) to state: \(hexState)")
            if let model = state.cellQueue[cell.offsetCoordinate] {
                var new = model
                new.state = hexState
                if hexState == .timerStarted {
                    new.startedAt = Date.now
                }
                state.cellQueue[cell.offsetCoordinate] = new
            } else {
                var model = HexFlowerModel(state: hexState)
                if hexState == .timerStarted {
                    model.startedAt = Date.now
                }
                state.cellQueue[cell.offsetCoordinate] = model
                state.cellQueueOrder.append(cell.offsetCoordinate)
            }
            
            let allReady = self.state.cellQueue.filter { $0.value.state == .selected }
            let animating = self.state.cellQueue.filter { $0.value.state == .animationStarted }

            gridModel.refresh()

            // Use the first element from our ordered list that is in ready state
            if let next = state.cellQueueOrder.first(where: { allReady.keys.contains($0) }), animating.isEmpty {
                guard var model = self.state.cellQueue[next] else { return }
                model.state = .animationStarted
                state.cellQueue[next] = model
                gridModel.refresh()
            }
            
        case .details(let cell):
            guard state.selectedCell == nil else { return }

            state.selectedCell = cell
            Task { @MainActor in
                gridModel.zoomAndCenter(to: cell.offsetCoordinate, scale: 8)
            }
            gridModel.refresh()
            
        case .moveBack:
            gridModel.zoom(to: 1)
            state.selectedCell = nil
            
            Task { @MainActor in
                gridModel.recenter(paddingBottom: 100)
            }
            gridModel.scrollEnabled = true
            gridModel.refresh()
            
        case .recenter:
            gridModel.recenter(paddingBottom: 100)
            
        case .initializeXMTP:
            Task {
                do {
                    print("🔐 [HiUHomeViewModel] Initializing XMTP client...")
                    try await createXMTPClientUseCase.createClient()
                    print("🔐 [HiUHomeViewModel] XMTP client initialized successfully!")
                    await MainActor.run {
                        state.xmtpClientInitialized = true
                    }
                } catch {
                    print("🔐 [HiUHomeViewModel] Failed to initialize XMTP client: \(error)")
                    await MainActor.run {
                        state.xmtpClientError = error.localizedDescription
                    }
                }
            }
            
        case .testClearAndInitialize:
            Task {
                do {
                    print("🔐 [HiUHomeViewModel] Clearing XMTP data and reinitializing...")
                    // Clear all XMTP data
                    createXMTPClientUseCase.clearAllData()
                    // Try to initialize again
                    try await createXMTPClientUseCase.createClient()
                    print("🔐 [HiUHomeViewModel] XMTP client reinitialized successfully!")
                    await MainActor.run {
                        state.xmtpClientInitialized = true
                        state.xmtpClientError = nil
                    }
                } catch {
                    print("🔐 [HiUHomeViewModel] Failed to reinitialize XMTP client: \(error)")
                    await MainActor.run {
                        state.xmtpClientError = error.localizedDescription
                    }
                }
            }
        }
    }
}
