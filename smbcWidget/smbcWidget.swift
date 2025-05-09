//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import WidgetKit
import SwiftUI

private let testRest =  Restaurant(
    id: "beachstreet",
    name: "Beach Street",
    address: "435 W. Beach Street",
    route: "101/92/280/85/17/1",
    city: "Watsonville",
    phone: "831-722-2233",
    status: "open",
    eta: "8:17",
    lat: 37.113013,
    lon: -121.637845
)

@MainActor
struct WidgetState {
    static var state = ProgramState()

    static var nextRestaurant: Restaurant {
        if let nextRide = Self.state.rideModel.nextRide() {
            if let id = nextRide.restaurant {
                return Self.state.restaurantModel.idToRestaurant(id: id)
            }
        }
        return testRest
    }
}

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), restaurant: testRest)
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), restaurant: testRest )
        completion(entry)
    }

    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: Date(), restaurant: testRest )

        let calendar = Calendar.current
        let monday = 2 // second day of week
        let components = DateComponents(weekday: monday)
        let nextMonday = calendar.nextDate(after: Date.now,
            matching: components,
            matchingPolicy: .nextTime) ?? Date.now.addingTimeInterval(12*60*60)

        let timeline = Timeline(entries: [entry], policy: .after(nextMonday))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let restaurant: Restaurant
}

struct SmbcWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color.widgetBackground
            VStack {
                HStack {
                    Text("SMBC Next Ride:")
                        .font(.caption)
                        .padding(.bottom)
                    Spacer()
                }
                Text(entry.restaurant.name)
                    .bold()
                    .padding(.bottom)
                Text(entry.restaurant.city)
                    .font(.callout)
                Spacer()
                Text("ETA: \(entry.restaurant.eta)")
                    .font(.caption2)
            }
            .padding()
            .widgetURL(URL(string: "smbc://"))
        }
    }
}

struct SmbcWidget: Widget {
    let kind: String = "smbcWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SmbcWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("SMBC Widget")
        .description("Next SMBC ride destination")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    SmbcWidget()
} timeline: {
        SimpleEntry(date: .now, restaurant: testRest)
}
