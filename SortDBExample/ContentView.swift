//
//  ContentView.swift
//  SortDBExample
//
//  Created by Khan Winter on 8/7/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.order, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    Text("Item order: \(item.order)")
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: { source, destination in
                    /**
                     # This is where we do most of our work
                     */
                    
                    // Get all the items we're moving
                    let sourceItems = source.map { items[$0] }
                    
                    var upper: Double
                    var lower: Double
                    
                    // If the destination is at the end of the list, or the begining we do something different
                    if destination == items.count {
                        print("Appending to the end of the list")
                        lower = items.last!.order
                        upper = items.last!.order + 100.0
                    } else if destination == 0 {
                        print("Inserting into the begining")
                        lower = 0.0
                        upper = items.first?.order ?? 100.0
                    } else {
                        print("Inserting into the middle of the list")
                        // Find the upper and lower sort around the destination and make some sort orders
                        upper = items[destination - 1].order
                        lower = items[destination].order
                    }
                    
                    var newOrders: [Double] = stride(from: lower, to: upper, by: (upper - lower)/Double(sourceItems.count + 1)).map { $0 }
                    newOrders.remove(at: 0)
                    
                    var i = 0
                    source.forEach { index in
                        items[index].order = newOrders[i]
                        i += 1
                    }
                    
                    try! viewContext.save()
                    
                })
            }
            .navigationTitle("Sort Items")
            .navigationBarItems(leading: Button(action: addItem) {
                Label("Add Item", systemImage: "plus")
            },
            trailing: EditButton())
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            if items.count > 0 {
                newItem.order = items.last!.order + 25.0
            } else {
                newItem.order = 100.0
            }

            try! viewContext.save()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            try! viewContext.save()
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

