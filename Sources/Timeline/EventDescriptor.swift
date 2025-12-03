import Foundation
import UIKit

public protocol EventDescriptor: AnyObject {
    var dateInterval: DateInterval {get set}
    var isAllDay: Bool {get}
    var text: String {get}
    var attributedText: NSAttributedString? {get}
    var lineBreakMode: NSLineBreakMode? {get}
    var font : UIFont {get}
    var color: UIColor {get}
    var textColor: UIColor {get}
    var backgroundColor: UIColor {get}
    var editedEvent: EventDescriptor? {get set}
    var isTimeOff: Bool {get set}
    var isCounterEvent: Bool {get set}
    var apptsCount: Int {get set}
    var timeOffColor: UIColor {get set}
    var appointmentIds: [Int] {get set}
    var isUnassigned: Bool {get set}
    var isMyAppointment : Bool {get set}
    func makeEditable() -> Self
    func commitEditing()
}
