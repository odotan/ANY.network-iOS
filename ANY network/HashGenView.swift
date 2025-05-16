import SwiftUI

struct HashGenView: View {
    @StateObject private var viewModel = HashSearchViewModel()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("Message", text: $viewModel.message)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Requirement", text: $viewModel.requirement)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Hashes", text: $viewModel.numberOfHashesString)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 50)
                
                Button(viewModel.sorting.title) {
                    viewModel.actionSheet.toggle()
                }
                .padding(6)
                .foregroundColor(.white)
                .background(.blue)
                .cornerRadius(10)
            }
            .padding(5)

            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("Hashes/sec (instant): \(Int(viewModel.instantSpeed))")
                    Text("Hashes/sec (avg): \(Int(viewModel.averageSpeed))")
                    Text("Total hashes: \(viewModel.totalHashes)")
                    Text("Estimated required: \(viewModel.estimatedRequired)")
                    Text("Total time: \(String(format: "%.3f", viewModel.results.last?.timeElapsed ?? 0)) seconds")
                    if let timeElapsed = viewModel.results.last?.timeElapsed, timeElapsed > 0 {
                        Text("Avarage time/hash: \(String(format: "%.3f", timeElapsed / Double(viewModel.results.count))) seconds")
                    }
                }
                
                VStack {
                    Button(viewModel.isBase64 ? "Base64" : "Hex") {
                        viewModel.isBase64.toggle()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(.blue)
                    .cornerRadius(10)
                    
                    Button(viewModel.isRunning ? "Stop" : "Start") {
                        viewModel.isRunning ? viewModel.stop() : viewModel.start()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isRunning ? .red : .green)
                    .cornerRadius(10)
                }
            }
            .padding(5)

            List {
                ForEach(viewModel.results.indices, id: \.self) { idx in
                    let result = viewModel.results[idx]
                    Text(
                        String(format: "%d. Nonce: %d | Time: %.3f sec | Hash: %@",
                                idx, result.nonce, result.timeElapsed, result.hash)
                    )
                        .font(.system(size: 12, design: .monospaced))
                }
            }
        }
        .padding(5)
        .actionSheet(isPresented: $viewModel.actionSheet) {
            ActionSheet(title: Text("Sorting"), message: nil, buttons: [
                .default(Text("Prefix"), action: {
                    viewModel.sorting = .prefix
                }),
                .default(Text("h, i, u"), action: {
                    viewModel.sorting = .symbols
                }),
                .default(Text("hiu"), action: {
                    viewModel.sorting = .literal
                }),
                .cancel()
            ])
        }
    }
}

