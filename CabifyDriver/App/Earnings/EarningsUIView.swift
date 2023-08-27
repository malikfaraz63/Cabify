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
    let earningsData = [
        EarningsDataPoint(key: "Mon", earnings: 132.16),
        EarningsDataPoint(key: "Tue", earnings: 92.44),
        EarningsDataPoint(key: "Wed", earnings: 181.92),
        EarningsDataPoint(key: "Thu", earnings: 164.37),
        EarningsDataPoint(key: "Fri", earnings: 128.73),
        EarningsDataPoint(key: "Sat", earnings: 74.57),
        EarningsDataPoint(key: "Sun", earnings: 34.11),
    ]
    
    var totalEarnings: Double {
         return earningsData
            .map { $0.earnings }
            .reduce(0.0) { $0 + $1 }
    }
    
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
                    Text("Wallet Balance")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color(uiColor: .systemGray2))
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(getMoney(2114))
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
                Text("Dec 7-14")
                    .foregroundColor(Color(uiColor: .systemGray2))
                    .font(.caption)
                    .fontWeight(.medium)
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Text(getMoney(totalEarnings))
                        .font(.custom("Helvetica Neue", size: 24))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Chart {
                    ForEach(earningsData) { dataPoint in
                        BarMark(x: .value("Weekday", dataPoint.key), y: .value("Earnings", dataPoint.earnings))
                            .cornerRadius(5)
                            
                    }
                    
                    let average = totalEarnings / Double(earningsData.count)
                    
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
                        Text("140")
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
                        Text("88")
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
                            Text("4.34")
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
    }}
    
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
