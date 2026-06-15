import Foundation

struct PublicHoliday {
    let name: String
    let date: Date
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter
}()

func getAllHolidays(year: Int) -> [PublicHoliday] {
    var holidays = [PublicHoliday]()
    holidays.append(fixedPublicHolidays[0]) // "New Year's Day"
    holidays.append(PublicHoliday(name: "Martin Luther King Jr. Day", date: calculateMartinLutherKingJrDay(year: year)))
    holidays.append(PublicHoliday(name: "Presidents' Day", date: calculatePresidentsDay(year: year)))
    holidays.append(PublicHoliday(name: "Memorial Day", date: calculateMemorialDay(year: year)))
    holidays.append(fixedPublicHolidays[1]) // "Independence Day"
    holidays.append(PublicHoliday(name: "Labor Day", date: calculateLaborDay(year: year)))
    holidays.append(PublicHoliday(name: "Thanksgiving", date: calculateThanksgivingDay(year: year)))
    holidays.append(PublicHoliday(name: "Day after Thanksgiving", date: calculateDayAfterThanksgiving(year: year)))
    holidays.append(fixedPublicHolidays[2]) // "Christmas Day"
    return holidays
}

private let fixedPublicHolidays: [PublicHoliday] = [
    PublicHoliday(name: "New Year's Day", date: dateFormatter.date(from: "2023/01/01")!),
    PublicHoliday(name: "Independence Day", date: dateFormatter.date(from: "2023/07/04")!),
    PublicHoliday(name: "Christmas Day", date: dateFormatter.date(from: "2023/12/25")!)
]

private func calculateFloatingPublicHolidayDates(year: Int) -> [Date] {
    let martinLutherKingJrDay = calculateMartinLutherKingJrDay(year: year)
    let presidentsDay = calculatePresidentsDay(year: year)
    let memorialDay = calculateMemorialDay(year: year)
    let laborDay = calculateLaborDay(year: year)
    let thanksgivingDay = calculateThanksgivingDay(year: year)
    let dayAfterThanksgiving = calculateDayAfterThanksgiving(year: year)

    return [martinLutherKingJrDay, presidentsDay, memorialDay, laborDay, thanksgivingDay, dayAfterThanksgiving]
}

private func addDaysToDate(date: Date, days: Int) -> Date {
    var dateComponents = DateComponents()
    dateComponents.day = days
    let calendar = Calendar.current
    return calendar.date(byAdding: dateComponents, to: date)!
}

// Thanksgiving
private func calculateThanksgivingDay(year: Int) -> Date {
    let novemberFirst = dateFormatter.date(from: "\(year)/11/01")!
    let calendar = Calendar.current
    
    let weekday = calendar.component(.weekday, from: novemberFirst)
    let daysToAdd = (5 - weekday + 7) % 7 + 7 * 3
    return addDaysToDate(date: novemberFirst, days: daysToAdd)
}

// Day after Thanksgiving
private func calculateDayAfterThanksgiving(year: Int) -> Date {
    let thanksgivingDay = calculateThanksgivingDay(year: year)
    return addDaysToDate(date: thanksgivingDay, days: 1)
}

private func calculateMartinLutherKingJrDay(year: Int) -> Date {
    let januaryFirst = dateFormatter.date(from: "\(year)/01/01")!
    let calendar = Calendar.current

    let weekday = calendar.component(.weekday, from: januaryFirst)
    let daysToAdd = (2 - weekday + 7) % 7 + 7 * 2
    return addDaysToDate(date: januaryFirst, days: daysToAdd)
}

private func calculatePresidentsDay(year: Int) -> Date {
    let februaryFirst = dateFormatter.date(from: "\(year)/02/01")!
    let calendar = Calendar.current

    let weekday = calendar.component(.weekday, from: februaryFirst)
    let daysToAdd = (2 - weekday + 7) % 7 + 7 * 2
    return addDaysToDate(date: februaryFirst, days: daysToAdd)
}

private func calculateMemorialDay(year: Int) -> Date {
    let mayFirst = dateFormatter.date(from: "\(year)/05/01")!
    let calendar = Calendar.current

    let weekday = calendar.component(.weekday, from: mayFirst)
    let daysToAdd = (2 - weekday + 7) % 7 + 7 * 3
    return addDaysToDate(date: mayFirst, days: daysToAdd)
}

private func calculateLaborDay(year: Int) -> Date {
    let septemberFirst = dateFormatter.date(from: "\(year)/09/01")!
    let calendar = Calendar.current

    let weekday = calendar.component(.weekday, from: septemberFirst)
    let daysToAdd = (2 - weekday + 7) % 7
    return addDaysToDate(date: septemberFirst, days: daysToAdd)
}
