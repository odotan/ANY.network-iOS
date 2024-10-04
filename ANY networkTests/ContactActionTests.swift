import XCTest
@testable import ANY_network

final class ContactActionTest: XCTestCase {
    func testWithValidPhoneNumber() throws {
        let phoneAction = PhoneNumberAction(value: "555 478-7672")
        XCTAssertNoThrow(try phoneAction.performAction()) // Will throw error if run on simulator, run on a real device to get a genuine result
    }

    func testWithNoPhoneNumber() throws {
        let phoneAction = PhoneNumberAction(value: "")
        XCTAssertThrowsError(try phoneAction.performAction()) { error in
            let actionError = error as? ContactActionError
            XCTAssertTrue(actionError != nil && actionError == ContactActionError.noValue)
        }
    }

    func testWithInvalidPhoneNumber() throws {
        let phoneAction = PhoneNumberAction(value: "asdf")
        XCTAssertThrowsError(try phoneAction.performAction()) { error in
            let actionError = error as? ContactActionError
            XCTAssertTrue(actionError != nil && actionError == ContactActionError.invalidValue)
        }
    }

    func testWithValidEmail() throws {
        let phoneAction = EmailAction(value: "test@testmail.com")
        XCTAssertNoThrow(try phoneAction.performAction()) // Will throw error if run on simulator, run on a real device to get a genuine result
    }

    func testWithNoEmail() throws {
        let phoneAction = PhoneNumberAction(value: "")
        XCTAssertThrowsError(try phoneAction.performAction()) { error in
            let actionError = error as? ContactActionError
            XCTAssertTrue(actionError != nil && actionError == ContactActionError.noValue)
        }
    }

    func testWithInvalidEmail() throws {
        let phoneAction = PhoneNumberAction(value: "asdf")
        XCTAssertThrowsError(try phoneAction.performAction()) { error in
            let actionError = error as? ContactActionError
            XCTAssertTrue(actionError != nil && actionError == ContactActionError.invalidValue)
        }
    }
}
