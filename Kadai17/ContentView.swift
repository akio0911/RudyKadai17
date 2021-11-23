//
//  ContentView.swift
//  Kadai17
//

import SwiftUI
import Combine

struct FruitModel: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var isChecked: Bool
}

class FruitItems: ObservableObject {
    @Published var items: [FruitModel]

    init() {
        self.items = [
            FruitModel(name: "りんご", isChecked: false),
            FruitModel(name: "みかん", isChecked: true),
            FruitModel(name: "バナナ", isChecked: false),
            FruitModel(name: "パイナップル", isChecked: true)
            ]
    }
}

struct FruitList: View {
    @State var isShowInputView = false
    @State var edditingName = ""
    @ObservedObject var fruitItems: FruitItems = FruitItems()

    var body: some View {
        NavigationView {
            List {
                ForEach(fruitItems.items, id: \.self) {item in
                    FruitView(fruit: item)
                }
                .onDelete { offsets in
                    fruitItems.items.remove(atOffsets: offsets)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        edditingName = ""
                        isShowInputView = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .fullScreenCover(
                isPresented: $isShowInputView,
                content: { InputView(
                    text: $edditingName,
                    onCancel: {
                        isShowInputView = false
                    },
                    onSave: {
                        fruitItems.items.append(FruitModel(name: $0, isChecked: false))
                        isShowInputView = false
                    })
                })
        }
    }
}

struct FruitView: View {
    @State var fruit: FruitModel
    @State var isShowEditView = false
    @State var edditingName = ""

    var body: some View {
        HStack {
            HStack {
                CheckMark(isChecked: $fruit.isChecked)
                Text(fruit.name)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                fruit.isChecked.toggle()
            }

            Button {
                edditingName = fruit.name
                isShowEditView = true
            } label: {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                    .padding(5)
            }
            .fullScreenCover(isPresented: $isShowEditView,
                             content: { InputView(
                                text: $edditingName,
                                onCancel: {
                                    isShowEditView = false
                                },
                                onSave: {
                                    fruit.name = $0
                                    isShowEditView = false
                })
            })
        }
    }
}

struct InputView: View {
    @Binding var text: String
    var onCancel: () -> Void
    var onSave: (String) -> Void

    var body: some View {
        NavigationView {
            HStack {
                Text("名前")
                TextField("", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addIfPossible()
                    }
                }
            }
        }
    }
    private func addIfPossible() {
        let name = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        onSave(name)
    }
}

struct CheckMark: View {
    @Binding var isChecked: Bool

    var body: some View {
        Image(systemName: "checkmark")
            .foregroundColor(isChecked ? .red : .white)
            .font(.system(size: 20, weight: .bold))
    }
}

struct ContentView: View {
    var body: some View {
        FruitList()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
