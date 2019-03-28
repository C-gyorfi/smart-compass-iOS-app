
import XCTest
@testable import Compass
import CoreLocation

class CalculationsTest: XCTestCase {
    
    let calc = Calculations()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
//       let degree = calc.getBearingBetweenTwoPoints1(point1: CLLocation(latitude: 0, longitude: 0), point2: CLLocation(latitude: 1, longitude: 1))
        
      //  XCTAssertEqual(degree, 45)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
