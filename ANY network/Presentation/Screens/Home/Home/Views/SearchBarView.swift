import SwiftUI

struct SearchBarView: View {
    @Binding var term: String
    var searchPressed: (() -> Void)
    var filterPressed: (() -> Void)

    var body: some View {
        HStack(spacing: 0) {
            Image(.lense)
                .resizable()
                .opacity(term.isEmpty ? 1 : 0.15)
                .frame(width: <->18, height: |18)
                .padding(.leading, <->20)

            Group {
                TextField("", text: $term)
                    .submitLabel(.search)
                    .onSubmit(searchPressed)
                    .overlay {
                        if term.isEmpty {
                            HStack {
                                Text("Search")
                                    .allowsHitTesting(false)
                                Spacer()
                            }
                        }
                    }
            }
            .foregroundColor(.white)
            .font(.montserat(size: |14))
            .frame(maxWidth: .infinity)
            .frame(height: |18)
            .padding(.horizontal, <->11)
            
            Color.appGray.opacity(0.18)
                .frame(width: <->1, height: |24)
            
            Button(action: filterPressed) {
                Image(.searchFilter)
                    .resizable()
                    .frame(width: <->17, height: |10)
                    .foregroundColor(.white)
                    .padding(.leading, <->16)
                    .padding(.trailing, <->20)
                    .padding(.top, |19.5)
                    .padding(.bottom, |17.5)
            }
        }
        .frame(height: |47)
        .background(.white.opacity(0.05))
        .cornerRadiusWithBorder(radius: |24, borderColor: .white.opacity(0.13))
    }
}

#Preview {
    VStack {
        SearchBarView(term: .constant(""), searchPressed: {}) { }
        SearchBarView(term: .constant("asd"), searchPressed: {}) { }
        Spacer()
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)

}
