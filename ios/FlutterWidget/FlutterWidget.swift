//
//  FlutterWidget.swift
//  FlutterWidget
//
//  Created by StackApp Infotech on 23/02/21.
//

import WidgetKit
import SwiftUI
import Intents

struct FlutterData: Decodable, Hashable {
    let text: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: FlutterData?
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: FlutterData(text: "Moksha - Liberation"))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: FlutterData(text: "Moksha - Liberation"))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let sharedDefaults = UserDefaults.init(suiteName: "group.app.moksha")
        var flutterData: FlutterData? = nil
        
        if(sharedDefaults != nil) {
            do {
              let shared = sharedDefaults?.string(forKey: "widgetData")
              if(shared != nil){
                let decoder = JSONDecoder()
                flutterData = try decoder.decode(FlutterData.self, from: shared!.data(using: .utf8)!)
              }
            } catch {
              print(error)
            }
        }

        let currentDate = Date()
        let entryDate = Calendar.current.date(byAdding: .hour, value: 24, to: currentDate)!
        let entry = SimpleEntry(date: entryDate, configuration: flutterData)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
//    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
}



struct FlutterWidgetEntryView : View {
    var entry: Provider.Entry

//    var body: some View {
//        Text(entry.date, style: .time)
//    }
    private var FlutterDataView: some View {
      Text(entry.configuration!.text)
    }
    
    private var NoDataView: some View {
        
        ZStack{
            
            Color.black.ignoresSafeArea()
            
            
            Text("No quotes added yet! Please tap the home icon below quotes to add them in the widget")
            
                .foregroundColor(Color.white)
            
                .font(Font.custom("TravelingTypewriter", size: 22))
            
        }
        
      
    }
    
    var body: some View {
      if(entry.configuration == nil) {
        NoDataView
      } else {
        ZStack{
            Color.black.ignoresSafeArea()
            
            FlutterDataView
                
                .foregroundColor(Color.white)
            
                .font(Font.custom("TravelingTypewriter", size: 22))
            
            
        }
        
      }
    }
}

@main
struct FlutterWidget: Widget {
    let kind: String = "FlutterWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            FlutterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Moksha Home Widget")
        .description("Place your favorite quotes from Moksha to your home screen!")
    }
}

struct FlutterWidget_Previews: PreviewProvider {
    static var previews: some View {
        FlutterWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
