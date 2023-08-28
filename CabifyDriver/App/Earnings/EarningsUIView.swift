//
//  EarningsUIView.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 23/08/2023.
//

import SwiftUI
import Charts

struct EarningsDataPoint: Identifiable, Equatable {
    let key: String
    let earnings: Double
    var id: String { key }
}

struct EarningsUIView: View {
    @ObservedObject
    var viewManager = EarningsViewManager()
    
    func getMoney(_ money: Double) -> String {
        return String(format: "£%.2f", money)
    }
    
    var body: some View { VStack {
        VStack {
            Text("My Earnings")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                VStack {
                    Text("Earnings")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(uiColor: .systemGray2))
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(getMoney(viewManager.driver?.earnings ?? 0))
                        .font(.custom("Helvetica Neue", size: 24))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.frame(maxWidth: UIScreen.screenWidth / 3, alignment: .leading)
                Button("WITHDRAW") {
                    print("EE")
                }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .frame(maxWidth: UIScreen.screenWidth / 3, alignment: .center)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
                .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
                .frame(maxWidth: UIScreen.screenWidth - 32, alignment: .center)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(10)
        }
        .padding(.bottom)
        
        VStack {
            VStack {
                Text(viewManager.currentWeekDescription)
                    .foregroundColor(Color(uiColor: .systemGray2))
                    .font(.caption)
                    .fontWeight(.medium)
                HStack {
                    Button {
                        viewManager.jumpBackWeek()
                    } label: {
                        Image(systemName: "chevron.left")
                    }.disabled(!viewManager.hasPreviousWeek)
                    Text(getMoney(viewManager.totalEarnings))
                        .font(.custom("Helvetica Neue", size: 24))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Button {
                        viewManager.jumpForwardWeek()
                    } label: {
                        Image(systemName: "chevron.right")
                    }.disabled(!viewManager.hasNextWeek)
                }
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Chart {
                    ForEach(viewManager.earningsData) { dataPoint in
                        BarMark(x: .value("Weekday", dataPoint.key), y: .value("Earnings", dataPoint.earnings))
                            .cornerRadius(5)
                            
                    }
                    
                    let average = viewManager.totalEarnings / Double(viewManager.earningsData.count)
                    
                    RuleMark(y: .value("Average", average))
                        .foregroundStyle(Color(uiColor: .systemGray3))
                        .opacity(0.5)
                        .annotation(position: .automatic, alignment: .bottomTrailing) {
                            Text("\(getMoney(average)) ")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color(uiColor: .systemGray2))
                        }
                }
                    .frame(maxHeight: UIScreen.screenHeight / 3)
                    .padding(.bottom)
                Divider()
                
                HStack {
                    VStack {
                        Text("Total Trips")
                            .foregroundColor(Color(uiColor: .systemGray2))
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(viewManager.driver?.ridesCount ?? 0)")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 4)
                    
                    VStack {
                        Text("Ride Reviews")
                            .foregroundColor(Color(uiColor: .systemGray2))
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(viewManager.driver?.ratings.count ?? 0)")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 4)
                    
                    VStack {
                        Text("Average Rating")
                            .foregroundColor(Color(uiColor: .systemGray2))
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            Image(systemName: "star.fill")
                                .imageScale(.small)
                            Text(String(format: "%.2f", viewManager.driver?.ratings.average ?? 0))
                                .fontWeight(.semibold)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: UIScreen.screenWidth / 4)
                }
                .frame(maxWidth: .infinity)
            }
        }
            .padding(EdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10))
            .frame(maxWidth: UIScreen.screenWidth - 32, alignment: .center)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(10)
    }.onAppear(perform: viewManager.setupFromCurrentWeek)}
    
}

struct EarningsUIViewPreview: PreviewProvider {
    static var previews: some View {
        EarningsUIView()
    }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
