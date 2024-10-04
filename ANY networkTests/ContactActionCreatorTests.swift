import XCTest
@testable import ANY_network

final class ContactActionCreatorTests: XCTestCase {
    private var creator: ContactActionCreator!

    override func setUpWithError() throws {
        creator = .init()
    }

    override func tearDownWithError() throws {
        creator = nil
    }

    func testCreatingPhoneAction() throws {
        let phoneNumber = PhoneNumber(value: "(857) 995-7085")
        let contactAction = creator.createAction(for: phoneNumber)
        XCTAssertTrue(contactAction != nil && contactAction is PhoneNumberAction)
    }

    func testCreatingEmailAction() throws {
        let email = EmailAddress(value: "test@testmail.com")
        let contactAction = creator.createAction(for: email)
        XCTAssertTrue(contactAction != nil && contactAction is EmailAction)
    }
}
