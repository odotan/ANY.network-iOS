import XCTest
@testable import ANY_network

final class ContactMethodCreatorTests: XCTestCase {
    private var creator: ContactMethodCreator!

    override func setUpWithError() throws {
        creator = .init()
    }

    override func tearDownWithError() throws {
        creator = nil
    }

    func testCreatingFacebook() throws {
        let labeled = LabeledValue(id: "Facebook", label: "Facebook", value: "Facebook")
        let result = creator.createContactMethod(ofType: .socialProfiles, value: labeled)
        XCTAssertTrue(result is Facebook && result?.id == "Facebook" && result?.value == "Facebook")
    }

    func testCreatingTwitter() throws {
        let labeled = LabeledValue(id: "Twitter", label: "Twitter", value: "Twitter")
        let result = creator.createContactMethod(ofType: .socialProfiles, value: labeled)
        XCTAssertTrue(result is Twitter && result?.id == "Twitter" && result?.value == "Twitter")
    }

    func testCreatingInstagram() throws {
        let labeled = LabeledValue(id: "Instagram", label: "Instagram", value: "Instagram")
        let result = creator.createContactMethod(ofType: .socialProfiles, value: labeled)
        XCTAssertTrue(result is Instagram && result?.id == "Instagram" && result?.value == "Instagram")
    }

    func testCreatingTelegram() throws {
        let labeled = LabeledValue(id: "Telegram", label: "Telegram", value: "Telegram")
        let result = creator.createContactMethod(ofType: .instantMessageAddresses, value: labeled)
        XCTAssertTrue(result is Telegram && result?.id == "Telegram" && result?.value == "Telegram")
    }

    func testCreatingBlackbery() throws {
        let labeled = LabeledValue(id: "Blackbery", label: "Blackbery", value: "Blackbery")
        let result = creator.createContactMethod(ofType: .instantMessageAddresses, value: labeled)
        XCTAssertTrue(result is Blackbery && result?.id == "Blackbery" && result?.value == "Blackbery")
    }

    func testCreatingSocialMediaWithIncorrectLabel() throws {
        let labeled = LabeledValue(id: "", label: "label", value: "")
        let result = creator.createContactMethod(ofType: .instantMessageAddresses, value: labeled)
        XCTAssertNil(result)
    }

    func testCreatingPhoneNumber() throws {
        let labeled = LabeledValue(id: "Phone", label: "Phone", value: "1234567890")
        let result = creator.createContactMethod(ofType: .phoneNumbers, value: labeled)
        XCTAssertTrue(result is PhoneNumber && result?.id == "Phone" && result?.value == "1234567890")
    }

    func testCreatingEmail() throws {
        let labeled = LabeledValue(id: "Email", label: "Email", value: "test@email.com")
        let result = creator.createContactMethod(ofType: .emailAddresses, value: labeled)
        XCTAssertTrue(result is EmailAddress && result?.id == "Email" && result?.value == "test@email.com")
    }

    func testCreatingPostalAddress() throws {
        let labeled = LabeledValue(id: "Postal", label: "Postal", value: "street")
        let result = creator.createContactMethod(ofType: .postalAddresses, value: labeled)
        XCTAssertNil(result)
    }

    func testCreatingURLAddress() throws {
        let labeled = LabeledValue(id: "URL", label: "URL", value: "www.test.com")
        let result = creator.createContactMethod(ofType: .urlAddresses, value: labeled)
        XCTAssertNil(result)
    }

    func testCreatingMultiplePhoneNumbers() throws {
        let labeled = [
            LabeledValue(id: "Phone", label: "Phone", value: "1234567890"),
            LabeledValue(id: "Phone2", label: "Phone2", value: "12345678901"),
        ]

        let result = creator.createContactMethods(ofType: .phoneNumbers, values: labeled)

        let typeContdition = result.count == 2 && result[0] is PhoneNumber && result[1] is PhoneNumber
        XCTAssertTrue(typeContdition)
    }

    func testCreatingMultipleWithEmptyArray() throws {
        let labeled: [LabeledValue] = []

        let result = creator.createContactMethods(ofType: .phoneNumbers, values: labeled)
        XCTAssertTrue(result.isEmpty)
    }

    func testGetFirstMethodForAllTypes() throws {
        let dict: [ContactMethodType: [LabeledValue]] = [
            .phoneNumbers: [
                .init(id: "Phone1", label: "Phone1", value: "Phone1"),
                .init(id: "Phone2", label: "Phone2", value: "Phone2"),
            ],
            .emailAddresses: [
                .init(id: "Email1", label: "Email1", value: "Email1"),
                .init(id: "Email2", label: "Email2", value: "Email2"),
            ],
            .postalAddresses: [
                .init(id: "Post", label: "Post", value: "Post"),
            ],
            .urlAddresses: [
                .init(id: "URL", label: "URL", value: "URL"),
            ],
            .socialProfiles: [
                .init(id: "Facebook", label: "Facebook", value: "Facebook"),
                .init(id: "Facebook1", label: "Facebook", value: "Facebook1"),
                .init(id: "Twitter", label: "Twitter", value: "Twitter"),
                .init(id: "Twitter2", label: "Twitter", value: "Twitter2"),
                .init(id: "Instagram", label: "Instagram", value: "Instagram"),
                .init(id: "Instagram2", label: "Instagram", value: "Instagram2"),
            ],
            .instantMessageAddresses: [
                .init(id: "Blackbery", label: "Blackbery", value: "Blackbery"),
                .init(id: "Blackbery1", label: "Blackbery", value: "Blackbery1"),
                .init(id: "Telegram", label: "Telegram", value: "Telegram"),
                .init(id: "Telegram1", label: "Telegram", value: "Telegram1"),
            ]
        ]

        let result = creator.getFirstMethodForAllTypes(using: dict)
        let expectedResult: [any ContactMethod] = [
            PhoneNumber(id: "Phone1", value: "Phone1"),
            EmailAddress(id: "Email1", value: "Email1"),
            Facebook(id: "Facebook", value: "Facebook"),
            Twitter(id: "Twitter", value: "Twitter"),
            Instagram(id: "Instagram", value: "Instagram"),
            Blackbery(id: "Blackbery", value: "Blackbery"),
            Telegram(id: "Telegram",  value: "Telegram"),
        ]

        XCTAssertTrue(result.count == expectedResult.count && result.contains(expectedResult))
    }
}
