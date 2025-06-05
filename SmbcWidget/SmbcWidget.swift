//
// Copyright 2025 Marco S Hyman
// https://www.snafu.org/
//

import OSLog
import Cache
import Schedule
import SwiftUI
import WidgetKit

struct WidgetData {
    let rides: [Ride]
    let restaurants: [Restaurant]

    init() {
        let state = ScheduleState()
        rides = state.rideModel.rides
        restaurants = state.restaurantModel.restaurants
        Logger(subsystem: "WidgetData", category: "user").notice("Widget data initialized")
    }

    func next(after date: Date) -> Restaurant {
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)

        // return the "next" restarant to visit.  Next is defined as
        // the restaurant to be visited on the given data or later

        if let index = rides.firstIndex(where: {
            ($0.month > month || ($0.month == month && $0.day >= day))
            && $0.restaurant != nil
        }) {
            if index < rides.endIndex {
                if let restaurant = restaurants.first(where: {
                    $0.id == rides[index].restaurant
                }) {
                    return restaurant
                }
            }
        }
        return WidgetData.sampleRest
    }

    static let sampleRest =  Restaurant(
        id: "beachstreet",
        name: "Beach Street Restaurant",
        address: "435 W. Beach Street",
        route: "101/92/280/85/17/1",
        city: "Watsonville",
        phone: "831-722-2233",
        status: "open",
        eta: "8:17",
        lat: 37.113013,
        lon: -121.637845
    )
}

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), restaurant: WidgetData.sampleRest)
    }

    func getSnapshot(in context: Context,
                     completion: @escaping (SimpleEntry) -> Void) {
        let data = WidgetData()
        let today = Date.now
        let restaurant = data.next(after: today)

        let entry = SimpleEntry(date: today, restaurant: restaurant)
        completion(entry)
    }

    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<Entry>) -> Void) {
        let data = WidgetData()
        let today = Date.now
        let restaurant = data.next(after: today)

        let entry = SimpleEntry(date: Date(), restaurant: restaurant)

        let calendar = Calendar.current
        let monday = 2 // second day of week
        let components = DateComponents(weekday: monday)
        let nextMonday = calendar.nextDate(after: Date.now,
            matching: components,
            matchingPolicy: .nextTime) ?? Date.now.addingTimeInterval(12*60*60)
            // above uses 12 hours as a safety fallback

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
                    Text("Next SMBC Breakfast:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 5)
                    Spacer()
                }
                VStack(alignment: .leading){
                    Text(entry.restaurant.name)
                        .bold()
                        .lineLimit(nil)
                        .padding(.bottom, 2)
                    Text(entry.restaurant.city)
                        .font(.callout)
                        .padding(.leading, 0)
                }
                Spacer()
                Text("ETA: \(entry.restaurant.eta)")
                    .font(.caption2)
            }
            .padding()
            .widgetURL(URL(string: "Smbc://"))
        }
    }
}

struct SmbcWidget: Widget {
    let kind: String = "SmbcWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SmbcWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Smbc Widget")
        .description("Next SMBC ride destination")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    SmbcWidget()
} timeline: {
        SimpleEntry(date: .now, restaurant: WidgetData.sampleRest)
}
